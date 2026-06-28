local M = class("ShiguangRelicSelectControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "select_btn" then
        if self.m_model.m_select_index == nil or self.m_model.m_select_index == -1 then
            return
        end
        local heirloom_pool = self.m_model.m_cell_data.heirloom_pool or {}
        local heirloom_id = heirloom_pool[self.m_model.m_select_index]
        self:updateMsg("shiguang_select_heirloom", {data = self.m_model.m_cell_data, heirloom_id = heirloom_id}, "Shiguang")
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end


return M
