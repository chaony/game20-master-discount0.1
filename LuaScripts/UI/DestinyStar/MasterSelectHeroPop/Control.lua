local M = class("MasterSelectHeroPopControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "select_hero" then
        self:clickHero(data)
    elseif msg == "help_btn" then
        self:openHelpPop()
    elseif msg == "sure_btn" then
        if self.m_model.m_old_hero_id ~= "" and self.m_model.m_select_hero_id ~= "" and self.m_model.m_select_hero_id ~= self.m_model.m_old_hero_id and self.m_model.m_open_type == "master" then
           self:popCostTips()
        elseif self.m_model.m_select_hero_id == self.m_model.m_old_hero_id or self.m_model.m_select_hero_id == "" then
            self:closeView()
        else
            self:requestUrl()
        end 
        
    elseif msg == "tab_btn" then
        self.m_view.m_scroll_view_update_move_flag = false
        self.m_view.race_hero = self.m_model:switchHeroList(data.value.race)
        self.m_view:refreshUI()
        self.m_view.m_scroll_view_update_move_flag = true
    end
end

function M:popCostTips()
    local cost_reward = ConfigManager:getCommonValueById(724,{})
    local reward_data = RewardUtil:getProcessRewardData(cost_reward[1])
    if reward_data then
        if reward_data.user_num >= reward_data.data_num then
            local tips_des = Language:getTextByKey("fate_building_text_0011", reward_data.data_num, reward_data.name)
            local params =
            {
                on_ok_call = function(msg)
                    self:requestUrl()
                end,
                on_cancel_call = function (msg)

                end,
                no_close_btn = false,
                tow_close_btn = true,
                text = tips_des
            }
            static_rootControl:openView("Pops.CommonPop", params, nil, true)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("fate_building_text_0015", reward_data.name), delay_close = 2})
        end
    else
        Logger.logError("--------common id 724 is not a reward data--------")
    end
    
end

function M:requestUrl()
    local url = ""
    local params = {}
    params.master_id = self.m_model.m_master_id
    params.hero_oid = self.m_model.m_select_hero_id or ""
    if self.m_model.m_open_type == "master" then
        url = "hero_fate_master_add_major_hero"
    elseif self.m_model.m_open_type == "slaves" then
        params.pos = self.m_model.m_slaves_pos - 1
        url = "hero_fate_master_add_slaves_hero"
    end
    local function netCallback(response)
        UserDataManager:updateFateMaster(response)
        self:updateMsg("refreshUi", nil, "DestinyStar")
        self:closeView()
    end
    self.m_model:getNetData(url, params, netCallback)
end

function M:destroy()
    M.super.destroy(self)
end

return M;
