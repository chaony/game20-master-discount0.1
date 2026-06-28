local M = class("FourForceWarControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        self:closeView("Activities.FourForceWar")
        self:closeView()
    elseif msg == "group_btn" then
        audio:SendEvtUI("UI_Tab_N5")
        Logger.log(data,"group_btn ====")
        local params = {}
        params.version = self.m_model.m_version
        params.index = data
        params.data = self.m_model.m_data
        self:openView("Activities.FourForceWar.FourForceWarGroupSelectPop", params)
    end
end

return M;
