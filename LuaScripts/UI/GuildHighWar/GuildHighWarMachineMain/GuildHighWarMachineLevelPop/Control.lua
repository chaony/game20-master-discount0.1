local M = class("GuildHighWarMachineMainControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_view" then    -- 返回
        self:closeView()
    elseif msg == "btn_cancel" then
        local function receivetCallback(response)
            self:updateMsg("refresh_data",response,"GuildHighWar.GuildHighWarMachineMain")
            self:updateMsg("refresh_data",response,"GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff"..self.m_model.page_id)
            self:updateMsg("level_spine",self.m_model.m_point_data.point_id,"GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff"..self.m_model.page_id)
            self:closeView()
        end
        local params = {}
        params.point_id = self.m_model.m_point_data.point_id
        params.page_id = self.m_model.page_id
        local net = self.m_model.page_id == 1 and "guild_high_war_update_guild_level" or "guild_high_war_update_user_talent"
        self.m_model:getNetData(net, params, receivetCallback)
    elseif msg == "btn_revert" then
        self.m_model.is_cur_text = self.m_model.is_cur_text ==1 and 2 or 1
        self.m_view:UpdateText()
        --local params = {
        --    left_name = "talisman_text_0024",
        --    right_name = "talisman_text_0025",
        --    tips_text = "guild_high_war_new_0059",
        --    right_callback= function()
        --        local function receivetCallback(response)
        --            self:updateMsg("refresh_data",response,"GuildHighWar.GuildHighWarMachineMain")
        --            self:updateMsg("refresh_data",response,"GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff"..self.m_model.page_id)
        --            self:closeView()
        --        end
        --        local params = {}
        --        params.point_id = self.m_model.m_point_data.point_id
        --        params.point_type = self.m_model.page_id == 1 and 1 or 2
        --        self.m_model:getNetData("guild_high_war_reset_one_point", params, receivetCallback)
        --        self:closeView()
        --    end,
        --}
        --self:openView("Pops.CommonTipsPop", params)
    else 
        self:clickBtn(msg)
    end
end

function M:clickBtn(msg)
    local numText = string.sub(msg,10,string.len(msg))
    local data = self.m_model:getCurDataByPointId(tonumber(numText))
    self:openView("GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineLevelPop")
end


return M
