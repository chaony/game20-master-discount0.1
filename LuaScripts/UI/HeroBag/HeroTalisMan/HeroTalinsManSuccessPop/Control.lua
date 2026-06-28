local M = class("TalisManmentSuccessPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 or "big_close_btn2" then    -- 返回
        self:closeView()
    end
end




function M:destroy()
   self:removeTimer( self.m_timer_id)
    M.super.destroy(self)
end
function M:updateTime()
    self:closeView()
end

return M
