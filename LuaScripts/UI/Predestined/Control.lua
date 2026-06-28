local M = class("PredestinedControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Predestined.Guide"
    --toggle4 倒计时
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:startGuide()
    --M.super.startGuide(self)
    self:triggerGuide()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_red_point", nil, "parent")
        self:closeView()
        self:updateMsg(99999, nil, "Pub")
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 71})
    elseif msg == "change_hero_btn" or msg == "add_hero_btn" then
        local params = {}
        params.arm_hero = self.m_model.m_data.aim_hero
        params.times = self.m_model.m_data.guarantee_times
        params.is_sp = self.m_model.m_is_sp
        self:openView("Predestined.PredestinedHeroSelectPop", params)
    elseif msg == "set_hero" then
        local flag,times,name =  self.m_model:changeHeroControl(data)
        if flag then
            local str = ""
            if times > 0 then
                str = Language:getTextByKey("predestined_str_014", name, times)
            else
                str = Language:getTextByKey("predestined_str_015", name)
            end

            local params =
            {
                on_ok_call = function(msg)
                    self:requestSetHero(data)
                end,
                text = str
            }
            self:openView("Pops.CommonPop", params)
        else
            self:requestSetHero(data)
        end
    elseif msg == "probability_btn" then
        local params = {}
        params.arm_hero = self.m_model.m_data.aim_hero
        params.gacha_id = self.m_model.m_gacha_id
        params.is_sp = self.m_model.m_is_sp
        self:openView("Predestined.PredestinedProbabilityPop", params)
    elseif msg == "help_btn" then
        local params = {}
        if self.m_model.m_is_sp then
            params.title = "predestined_str_017"
            params.content = "tid#Bridge_2"
        else
            params.title = "predestined_str_001"
            params.content = "tid#Bridge_1"
        end
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "one_btn" then
        self:gacha(1)
    elseif msg == "ten_btn" then
        self:gacha(10)
    elseif msg == "toggle1" then
        self:closeView()
        self:updateMsg("switch_toggle", 1, "Pub")
    elseif msg == "toggle2" then
        self:closeView()
        self:updateMsg("switch_toggle", 2, "Pub")
    elseif msg == "toggle3" then
        self:closeView()
        self:updateMsg("switch_toggle", 3, "Pub")
    elseif msg == "wish_help_btn" then
        self:openView("Predestined.PredestinedWashHelpPop")
    end
end

function M:requestSetHero(msg)
    local function setCallback(response)
        self.m_model:setArmHero(response)
        self.m_view:refreshUI()
        self.m_view:refreshHeroSpine()
        self.m_view:refreshItem()
    end
    local params = {}
    params.hero_id = msg
    if self.m_model.m_is_sp == true then
        self.m_model:getNetData("high_gacha_sp_set_aim_hero", params, setCallback)
    else
        self.m_model:getNetData("high_gacha_set_aim_hero", params, setCallback)
    end
end

function M:gacha(times)
    --if self.m_model:isMaxTime() then
    --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
    --    return
    --end
    local flag, item_num = self.m_model:getItemCount(times)
    if flag == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(self.m_model.m_is_sp and "compass_str_002" or "Pub_str_0029"), delay_close = 2})
        return
    end
    if item_num >= times then
        self:gachaRequest(times)
    elseif item_num <= 0 then
        self:gachaRequest(times)
    else
        if self.m_model.m_is_sp then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
            return
        end
        local buy_num = times - item_num
        local price = ConfigManager:getCommonValueById(343, 500)
        local diamond_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 1})
        local item_data =  RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, 1011, 1}) --sp抽卡道具id 1434
        local params =
        {
            on_ok_call = function(msg)
                local diamond_num = UserDataManager.user_data:getUserStatusDataByKey("diamond") or 0
                if diamond_num < price*buy_num then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Pub_str_0029"), delay_close = 2})
                else
                    self:gachaRequest(times)
                end
            end,
            text = string.format(Language:getTextByKey("predestined_str_011"),buy_num*price,diamond_data.name, buy_num,item_data.name)
        }
        self:openView("Pops.CommonPop", params)
    end
end

function M:gachaRequest(times)
    local function gachaCallback(response)
        self.m_view:lockTouch()
        self.m_view:palyGachaAnimCallback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
        self.m_view:refreshHeroSpine()
    end
    local params = {}
    params.pool_id = self.m_model.m_gacha_id
    params.gacha_type = times
    if  self.m_model.m_is_sp then
        self.m_model:getNetData("high_gacha_sp_get_gacha", params, gachaCallback)
    else
        self.m_model:getNetData("high_gacha_get_gacha", params, gachaCallback)
    end
end

function M:gachaVedio(response)
    audio:PauseMusicBusVol()
    --local gacha_sound = "Gacha_Long"
    --local gacha_sound = audio:SendEvtUI(gacha_sound)
    self:openView("Pops.VedioPlayerPop", {callback = function()
        audio:ResumeMusicBusVol()
        --audio:StopPlayingID(gacha_sound)
        RewardUtil:rewardTipsByRewards(response.reward_show)
        self.m_view:unlockTouch()
    end, vedio_name = "predestined_bg.mp4", no_close_btn = false, close_btn_type = 1})
end

function M:triggerGuide()
    if self.m_model.m_data == nil or self.m_model.m_data.aim_hero == nil or self.m_model.m_data.aim_hero <= 0 then
        --local guide_info = UserDataManager.guide_data:getCurGuideInfo()
        --if guide_info == nil or guide_info.key ~= "Predestined" then
        --    local id = ConfigManager:getCommonValueById(389)
        --    UserDataManager.guide_data:setAnyTeamGuide(id)
        --    self.m_guide:checkGuide()
        --end
        local have_guide = UserDataManager.guide_data:setAnyTeamGuide(50, 2)
        if have_guide then
            if self.m_guide then
                self.m_guide:start()
            end
        end
    end
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M