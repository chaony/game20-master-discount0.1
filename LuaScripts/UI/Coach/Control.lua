local M = class("CoachPopControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("Amb_2D_indoor_fire")
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
        self:updateMsg("common_refresh", nil, "HeroBag")
    elseif msg == "tab_back_btn" then
        self.m_model:setTabIndex(1)
        self.m_view:refreshUI()
        self.m_view:resetToggle()
    elseif msg == "tab_delete_btn" then
        self.m_model:setTabIndex(2)
        self.m_view:refreshUI()
        self.m_view:resetToggle()
    elseif msg == "tab_reset_btn" then
        self.m_model:setTabIndex(3)
        self.m_view:refreshUI()
        self.m_view:resetToggle()
    elseif msg == "tab_role_reset_btn" then
        self.m_model:setTabIndex(4)
        self.m_view:refreshUI()
        self.m_view:resetToggle()
    elseif msg == "hero_back_btn" then  -- 回退品质
        if #self.m_model.m_select_heros <= 0 then
            return
        end
        
        local has_times = self.m_model:getBackTimes()
        if has_times > 0 then
            --local params =
            --{
            --    on_ok_call = function(msg)
            --        self.m_view:playEffect(function()
                        self:backRequest()
            --        end)
            --    end,
            --    no_close_btn = false,
            --    text = Language:getTextByKey("coach_str_0023", has_times)
            --}
            --static_rootControl:openView("Pops.CommonPop", params)
        else
            if self.m_model:isMaxTime() then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
                return
            end
            local reset_cost =  ConfigManager:getCommonValueById(59, 99999)
            if reset_cost and reset_cost > 0 then
                local user_data = UserDataManager.user_data
                local diamond = user_data:getUserStatusDataByKey("diamond")
                if diamond < reset_cost then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("coach_str_0013"), delay_close = 2})
                    return
                end
                local params =
                {
                    on_ok_call = function(msg)
                        self.m_view:playEffect(function()
                            self:backRequest()
                        end)
                    end,
                    no_close_btn = false,
                    cost = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0,diamond},
                    consume = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0,reset_cost},
                    text = Language:getTextByKey("coach_str_0012")
                }
                static_rootControl:openView("Pops.CommonPop", params)
            else
                self:backRequest()
            end
        end
    elseif msg == "reset_btn" then -- 等级
        if #self.m_model.m_select_heros <= 0 then
            return
        end
        local reset_cost = ConfigManager:getCommonValueById(21,99999)
        if reset_cost and reset_cost > 0 then
            local user_data = UserDataManager.user_data
            local diamond = user_data:getUserStatusDataByKey("diamond")

            local params =
            {
                on_ok_call = function(msg)
                    self:resetRequest()
                end,
                on_cancel_call = function (msg)

                end,
                no_close_btn = false,
                cost = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0,diamond},
                consume = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0,reset_cost},
                text = Language:getTextByKey("coach_str_0007"),
            }
            static_rootControl:openView("Pops.CommonPop", params)
        else
            self:resetRequest()
        end
    elseif msg == "one_key_select_btn" then
        if #self.m_model.m_select_heros >= #self.m_model.m_list_data then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("coach_str_0002"), delay_close = 2})
        elseif #self.m_model.m_select_heros >= self.m_model.m_select_max then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("coach_str_0009"), delay_close = 2})
        else
            self.m_model:oneKeyAddHero()
            self.m_view:refreshUI()
        end
    elseif msg == "delete_btn" then
        if #self.m_model.m_select_heros <= 0 then
            return
        end
        local itemsData = self.m_model:getDeleteReturnData()
        local params =
        {
            on_ok_call = function(msg)
                self.m_view:playEffect(function()
                    self:deleteRequest()
                end)
            end,
            title = Language:getTextByKey("coach_str_0008"),
            items = itemsData,
        }
        static_rootControl:openView("Pops.CommonItemsPop", params)
        
    elseif msg == "gacha_delete" then
        self.m_model:setGachaDelete(data)
    elseif msg == "tab_btn" then
        self.m_model:setMartial(data)
        self.m_view:updateListScroll()
        self.m_view:refreshTabUI()
    elseif msg == "select_hero" then
        local hero_data, cfg = UserDataManager.hero_data:getHeroDataById(data)
        if hero_data.lock == true then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("coach_str_0015"), delay_close = 2})
            return
        end
        if self.m_model:AddHero(data) then
            self.m_view:refreshUI()
            self.m_view:updateSelectDeleteScroll()
            self.m_view:refreshResetList()
        else
            if self.m_model.m_tab_index == 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("coach_str_0014"), delay_close = 2})
            elseif self.m_model.m_tab_index == 3 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("coach_str_0010"), delay_close = 2})
            end
        end
    elseif msg == "help_btn" then
        self:openHelpPop()
    elseif msg == "shop_btn" then
        self:openView("Shop", { shop_type = 3})
    elseif msg == "race_toggle_btn" then
        self.m_view:setToggleActive(not self.m_view.m_race_toggle_flag)
    elseif msg == "race_toggle_bg" then
        self.m_view:setToggleActive(false)
    elseif msg == "update_rollback_times" then
        self.m_view:refreshTabUI()
    elseif msg == "update_reset_times" then
        self.m_view:refreshTabUI()
    elseif msg == "role_reset_btn" then
        local params =
        {
            on_ok_call = function(msg)
                self:resetRoleRequest()
            end,
            on_cancel_call = function (msg)
            end,
            no_close_btn = false,
            text = Language:getTextByKey("hero_role_upgrade_text6"),
        }
        static_rootControl:openView("Pops.CommonPop", params)
    end
end

function M:deleteRequest()
    Logger.log(UserDataManager.hero_data:getHerosCount(),"deleteRequest 000 ===")
    local function deleteCallback(response)
        Logger.log(UserDataManager.hero_data:getHerosCount(),"deleteRequest 111 ===")
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:reset()
        self.m_view:refreshUI()
    end
    local params = {}
    params.material = self.m_model.m_select_heros
    if #params.material > 0 then
        self.m_model:getNetData("hero_resolve", params, deleteCallback, nil, nil, GlobalConfig.POST)
    end
end

function M:resetRequest()
    local function resetCallback(response)
        self.m_view:playEffect(function()
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:reset()
            self.m_view:playIconEffect()
        end)
    end
    local params = {}
    params.hero_oid = self.m_model.m_select_heros[1]
    if params.hero_oid then
        GameUtil:heroInLocalArenaDefenseTips({params.hero_oid}, function()
            self.m_model:getNetData("hero_reset", params, resetCallback)
        end, "new_str_0651")
    end
end
-- 侠客返濮
function M:resetRoleRequest()
    local function resetCallback(response)
        self.m_view:playEffect(function()
            RewardUtil:rewardTipsByData(response.reward)
            self:updateMsg(99999, nil, "Pops.HeroLookInfo")
            self.m_model:reset()
            self.m_view:playIconEffect()
        end)
    end
    local params = {}
    params.hero_oid = self.m_model.m_select_heros[1]
    self.m_model:getNetData("hero_book_reset", params, resetCallback)
end

function M:backRequest()
    local function backCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        UserDataManager.reset_times = response.reset_times
        self.m_model:reset()
        self.m_view:playIconEffect()
    end
    local params = {}
    params.hero_oid = self.m_model.m_select_heros[1]
    if params.hero_oid then
        self.m_model:getNetData("hero_rollback", params, backCallback)
    end
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "update_rollback_times" or curEvent == "update_reset_times" then
        self.m_view:refreshTabUI()
    end
end

function M:openHelpPop()
    local params = {}
    if self.m_model.m_tab_index == 1 then
        params.title = "tid#Fun_Libielou_Name"
        params.content = "tid#Fun_Libielou_Des"
    elseif self.m_model.m_tab_index == 2 then
        params.title = "coach_str_0003"
        params.content = "tid#boat_sell2"
        -- params.history = "tid#boat_sell3"
    elseif self.m_model.m_tab_index == 3 then
        params.title = "coach_str_0004"
        params.content = "tid#boat_reset2"
        -- params.history = "tid#boat_reset3"
    elseif self.m_model.m_tab_index == 4 then
        params.title = "hero_role_upgrade_text5"
        params.content = "tid#HeroroleTips_2"
    end
    self:openView("Pops.CommonHelpPop", params)
end


function M:destroy()
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M;
