local M = class("ReportBtnPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "report_btn" then
        local params = {}
        params.uid = self.m_model.m_uid
        params.name = self.m_model.m_user_name
        params.module_id = self.m_model.m_module_id
        params.chat = self.m_model.m_chat
        self:openView("Pops.ReportPop", params)
        self:closeView()
    end
end

return M;
