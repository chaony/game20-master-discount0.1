local M = class("HotelControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Hotel.Guide"
end

--[[function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(60, 0)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end]]--

function M:onHandle(msg, data)
    if msg == 99999 or msg == "close_new_btn" then -- 关闭
        self:closeView()
    elseif msg == "help_btn" then
        local desc = Language:getTextByKey("tid#RestaurantDescription_101")
        local params = {title = "lakes_love_text_006", content = desc}
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "mask_btn" then
        self.m_view:showOption(0)
    elseif msg == "room_btn_1" then
        self.m_view:showOption(1)
    elseif msg == "room_btn_2" then
        self.m_view:showOption(2)
    elseif msg == "room_btn_3" then
        self.m_view:showOption(3)
    elseif msg == "game1_btn" then
        self:openGame(1, 1)
    elseif msg == "game2_btn" then
        self:openGame(2, 1)
    elseif msg == "game3_btn" then
        self:openGame(3, 1)
    elseif msg == "game4_btn" then
        self:openView("Hotel.Fate")
    elseif msg == "reward_btn" then
        self:openView("Hotel.HotelReward", {level = self.m_model.m_level, is_point = self.m_model.m_is_daily_reward})
    elseif msg == "hall_btn" then
        local params = {hotel_level = self.m_model.m_level, his_run_times = self.m_model.m_his_run_times, times = self.m_model.m_times, spine_res = self.m_model.m_back_spine_res}
        self:openView("Hotel.HotelHall", params)
    elseif msg == "info_btn" then
        local text = Language:getTextByKey("hotel_text_010", self.m_model:getRunDay(), self.m_model.m_his_coin)
        GameUtil:lookInfoTips(self.m_control, {click_transform = self.m_view.m_info_obj.transform, msg = text})
    elseif msg == "get_daily_reward" then
        self.m_model:updateDailyRewardState()
        self.m_view:refreshDailyRewardPoint()
    elseif msg == "update_level" then
        local level = self.m_model.m_level
        self.m_model:updateLevel(data)
        if level == self.m_model.m_level then
            return --酒楼等级未变化
        end
        self.m_view:refreshUI() --刷新等级
        local new_spine_res = self.m_model:getBackSpineRes(self.m_model.m_level)
        if new_spine_res == self.m_model.m_back_spine_res then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_037", self.m_model.m_level), delay_close = 2})
            return --酒楼背景spine未变化，只飘字
        end
        --酒楼背景spine变化，关闭大厅界面，播放背景切换效果，并飘字
        self.m_model.m_back_spine_res = new_spine_res
        self:closeView("Hotel.HotelHall")
        self.m_view:changeStage()
    elseif msg == "update_times" then
        self.m_model:updateTimesAndCoin(data.times, data.his_coin, data.his_run_times)
        self.m_view:refreshUI()
    elseif msg == "refresh_red_point" then
        self.m_view:refreshRedPoint()
    elseif msg == "gacha1_btn" then --房间1抽卡
    elseif msg == "gacha2_btn" then --房间2抽卡
        self:openGacha(2)
    elseif msg == "gacha3_btn" then --房间3抽卡
        self:openGacha(3)
    elseif msg == "update_room_lv" then --更新房间等级
        local room_id = data.room_id
        local room_lv = data.room_lv
        self.m_model.m_rooms_lv[room_id] = room_lv
        local cfg = self.m_model:getRoomCfg(room_id)
        if cfg.open_gacha_room_level ~= nil then
            self.m_view:refreshGachaOption(room_id, room_lv, cfg.open_gacha_room_level[1]) --刷新抽卡入口
        end
    elseif msg == "refresh_gacha_red_point" then
        self.m_view:refreshGachaRedPoint()
    end
end

--打开小游戏
function M:openGame(room_id, index)
    local cfg = self.m_model:getRoomCfg(room_id)
    local game_group_id = cfg.game_street_groups[index]
    self:openView("LittleGames", {group_id = game_group_id, title = cfg.name})
end

--打开抽卡
function M:openGacha(room_id)
    local cfg = self.m_model:getRoomCfg(room_id)
    local open_gacha_lv = cfg.open_gacha_room_level[1]
    local room_level = self.m_model.m_rooms_lv[room_id]
    if room_level < open_gacha_lv then
        GameUtil:lookInfoTips(static_rootControl, {msg = cfg.name .. Language:getTextByKey("hotel_text_043", open_gacha_lv), delay_close = 2})
        return
    end
    self:openView("Hotel.HotelGacha", {room_id = room_id, room_lv = room_level})
end

function M:destroy()
    M.super.destroy(self)
end

return M