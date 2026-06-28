local M = class("FiveLinesDeffDetailNewControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.FivelinesNew.FiveLinesDeffDetailNew.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        self:updateMsg("reward_open_btn", { cell_data = self.m_model.m_cell_data, index = self.m_model.m_index }, "FivelinesNew")
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
