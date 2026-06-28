local M = class("HotelGachaControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "help_btn" then
        local desc = Language:getTextByKey(self.m_model.m_room_id == 2 and "tid#RestaurantDescription_107" or "tid#RestaurantDescription_108")
        local params = {title = "lakes_love_text_006", content = desc}
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "open_hero_btn" or msg == "blank_btn1" or msg == "blank_btn2" then
        self.m_view:showHeroList()
    elseif msg == "close_hero_btn" then
        self.m_view:closeHeroList()
    elseif msg == "gacha_btn" then
        self:requestGacha()
    elseif msg == "reward_btn" then
        local params = {cfg = self.m_model.m_cfg, room_lv = self.m_model.m_room_lv, attr = self.m_model.m_total_attr}
        self:openView("Hotel.HotelGacha.HotelGachaProbabilityPop", params)
    elseif msg == "hero_click_btn1" then
        self.m_up_hero_index = 1
        self:requestHeroDispatch(0, "")
    elseif msg == "hero_click_btn2" then
        self.m_up_hero_index = 2
        self:requestHeroDispatch(1, "")
    elseif msg == "up_hero" then
        local isUnique = self.m_model:isUniqueHeroInGacha(data.oid)
        if isUnique == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_035"), delay_close = 2})
            return
        end
        local heroes = self.m_model.m_heroes
        for i = 1, #heroes do
            if heroes[i] == "" then
                if self.m_model:isHeroPosOpen(i) == true then
                    self:requestHeroDispatch(i - 1, data.oid)
                    self.m_up_hero_index = i
                else
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_053"), delay_close = 2})
                end
                return
            end
        end
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hotel_text_023", 2), delay_close = 2})
    end
end

--更换侠客
function M:requestHeroDispatch(pos, hero_oid)
    local function netCallback(response)
        if response then
            self.m_model:updateHeroes(response.heros)
            local index = self.m_up_hero_index
            self.m_view:refreshHero(index, self.m_model.m_heroes[index])
            self.m_view:refreshHeroList() --刷新列表
        end
    end
    local params = {room = self.m_model.m_room_id, pos = pos, h_oid = hero_oid}
    self.m_model:getNetData("hotel_gacha_hero", params, netCallback)
end

--抽卡
function M:requestGacha()
    local function netCallback(response)
        if response then
            self.m_model:updateGacha(response.remain_times, response.reward)
            self.m_view:refreshUI()
            self:updateMsg("refresh_gacha_red_point", nil, "Hotel") --刷新抽卡入口红点
            local function callback()
                RewardUtil:rewardTipsByData(response.reward) --展示奖励
            end
            --对话事件
            --response.dialogue = 300001
            if response.dialogue and response.dialogue > 0 then
                self:openView("Guide.GuideDrama", {dialog_id = response.dialogue, callback = callback})
            else
                callback()
            end
        end
    end
    local params = {room = self.m_model.m_room_id}
    self.m_model:getNetData("hotel_gacha_done", params, netCallback)
end

return M