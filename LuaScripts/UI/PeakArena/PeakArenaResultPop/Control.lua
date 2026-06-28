local M = class("PeakArenaResultPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()

    end)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_callback_new)
        end
        self:closeView() 
    end
end

return M
