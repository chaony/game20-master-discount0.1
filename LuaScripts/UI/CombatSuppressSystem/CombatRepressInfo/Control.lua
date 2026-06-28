local M = class("CombatRepressInfoControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "check_tag" then
        self.m_model.m_select_id = tonumber(data) 
        self.m_view:refreshUI()
    elseif msg == "btn_infoBtn" then
        self:openView("Pops.CommonHelpPop", { title = "combat_suppress_system_text_002", content = Language:getTextByKey("tid#combat_repress_Namedes" ..self.m_model.m_select_id) })
    elseif msg == "btn_tipsBtn" then
        GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("combat_suppress_system_text_005",self.m_model.m_global_nums), delay_close = 2})
    elseif msg == "help_btn" then
        self:openView("Pops.CommonHelpPop", { title = "combat_suppress_system_text_002", content = Language:getTextByKey("tid#combat_repress_des") })
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;
