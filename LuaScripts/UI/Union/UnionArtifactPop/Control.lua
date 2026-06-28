local M = class("UnionArtifactPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "type_btn_1" or msg == "type_bg_btn_1" then
        self.m_model.m_select_index = 1
        self.m_view:selectBtn(self.m_model.m_select_index)
    elseif msg == "type_btn_2" or msg == "type_bg_btn_2" then
        self.m_model.m_select_index = 2
        self.m_view:selectBtn(self.m_model.m_select_index)
    elseif msg == "type_btn_3" or msg == "type_bg_btn_3" then
        self.m_model.m_select_index = 3
        self.m_view:selectBtn(self.m_model.m_select_index)
    elseif msg == "type_btn_4" or msg == "type_bg_btn_4" then
        self.m_model.m_select_index = 4
        self.m_view:selectBtn(self.m_model.m_select_index)
    elseif msg == "type_btn_5" or msg == "type_bg_btn_5" then
        self.m_model.m_select_index = 5
        self.m_view:selectBtn(self.m_model.m_select_index)
    elseif msg == "type_btn_6" or msg == "type_bg_btn_6" then
        self.m_model.m_select_index = 6
        self.m_view:selectBtn(self.m_model.m_select_index)
    elseif msg == "help_btn" then
        self:openView("Pops.CommonHelpPop", {title = "tid#UnionArtifact1", content = "tid#UnionArtifact2"})
    elseif msg == "reset_btn" then
        self:guildTripodResetTips()
    elseif msg == "lv_btn" then
        self:guildTripodUpgrade()
    elseif msg == "upgrade_btn" then
        self:guildTripodUpgrade()
    elseif msg == "give_btn" then
        local max_times = ConfigManager:getVipValueByKey("contribution_times", 1)
        local contribution_times = self.m_model.m_data.contribution_times or 0
        if max_times <= contribution_times then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0017"), delay_close = 2})
            return
        end
        self:openView("Union.UnionContributionPop", {times = self.m_model.m_data.contribution_times})
    elseif msg == "lv_tips_btn" then
        
    elseif msg == "update_data" then
        self.m_model:netData(data)
        self.m_view:refreshUI()
    elseif msg == "head_btn" then
        self:openView("Pops.HeroLookInfo", {hero_id = data.item_data[2], is_new = false})    
    end
end

function M:guildTripodResetTips()
    local cost = self.m_model:getGuildTripodResetCost()
    if #cost <= 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0411"), delay_close = 2})
        return
    end
    local params =
    {
        on_ok_call = function(msg)
            self:guildTripodReset()
        end,
        text = Language:getTextByKey("union_str_0018", cost[3] or 99999, ""),
        cost = cost,
        return_lvup_cost = self.m_model:getGuildTripodResetCostReturn()
    }
    self:openView("Union.UnionArtifactResetPop", params)
end

-- 公会神炉重置 tripod: 1   神炉类型 - 对应配置type
function M:guildTripodReset()
    local guild_tripod = self.m_model:getSelectGuildTripod()
    local function netCallback(response)
        UserDataManager.tripods = response.tripods
        if self.m_view then
            self.m_view:refreshUI()
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0414"), delay_close = 2})
        end
    end
    local params = {tripod = guild_tripod.guild_tripod_type}
    self.m_model:getNetData("guild_tripod_reset", params, netCallback)
end

-- 公会神炉升级 -- tripod: 1   神炉类型 - 对应配置type
function M:guildTripodUpgrade()
    local lvUpCost, next_cfg = self.m_model:getGuildTripodLvUpCost()
    if next(lvUpCost) ~= nil then
        local cost_data = RewardUtil:getProcessRewardData(lvUpCost)
        if cost_data.user_num < cost_data.data_num then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_1053"), delay_close = 2})
            return
        end
    end
    local guild_tripod = self.m_model:getSelectGuildTripod()
    local attr_point = self.m_view.m_curAttrPoint
    local function netCallback(response)
        UserDataManager.tripods = response.tripods
        if self.m_view then
            self.m_view:refreshUI()
            self.m_view:creatLevelUpEffect(attr_point)
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0413"), delay_close = 2})
        end
    end
    local params = {tripod = guild_tripod.guild_tripod_type}
    self.m_model:getNetData("guild_tripod_upgrade", params, netCallback)
    local cfg = self.m_model:getTripodCfgByType(guild_tripod.guild_tripod_type, 2)
    local lv = cfg.layer or 0
    audio:SendEvtUI(attr_point == 0 and "UI_ShenLu_LevelUp_2" or "UI_ShenLu_LevelUp_1")
end

-- 捐赠  times: 1   捐献次数
function M:guildDoingContribution(times)
    local function netCallback(response)
        if self.m_view then
            self.m_view:refreshUI()
        end
    end
    local params = {times = times}
    self.m_model:getNetData("guild_doing_contribution", params, netCallback)
end

return M;
