---@class DeploymentControl:OOControlBase
local M = class("DeploymentControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Formation.Deployment.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then
        if self.m_model.m_select_data and self.m_model.m_select_data.unlock_flag and self.m_model.m_select_data.id ~= self.m_model.m_deployment_id then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0422", Language:getTextByKey(self.m_model.m_select_data.cfg.name)), delay_close = 2})
            self:updateMsg("updateDeploymentTx", nil, "Formation")
        end
        self:closeView()
    elseif msg == "lock_tips" then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey(data.cell_data.cfg.unlock_des), delay_close = 2})
    elseif msg == "sele_btn" then
        self:updateMsg("click_select_deployment", data, "Formation")
    end
end

function M:destroy()
    
    M.super.destroy(self)
end

return M;
