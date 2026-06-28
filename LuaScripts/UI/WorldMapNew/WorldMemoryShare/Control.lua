local M = class("WorldMemoryShareControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "share_btn" then
        local show_call = function()
            self.m_view:showUI()
        end
        self.m_view:hideUI()
        self:openView("SharePicture", {picture_callback = show_call})
    end
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M;
