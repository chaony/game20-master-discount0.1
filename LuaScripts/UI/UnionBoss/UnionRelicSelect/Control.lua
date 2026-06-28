local M = class("UnionRelicSelectControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "select_btn" then
        if self.m_model.m_select_index == nil or self.m_model.m_select_index == -1 then
            return
        end
        self:updateMsg("select_heirloom", {id = data.id, mode = self.m_model.m_mode}, "UnionBoss")
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end


return M
