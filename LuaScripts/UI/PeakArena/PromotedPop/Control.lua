local M = class("PromotedPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()
        self.m_view:updateTime()
    end)
    self.m_view:updateTime()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_callback then
            self.m_model.m_callback()
        end
        self:closeView() 
    end
end

return M
