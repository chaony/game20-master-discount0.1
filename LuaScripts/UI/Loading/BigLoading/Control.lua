local M = class("BigLoadingControl",LikeOO.OOControlBase)

function M:onEnter()
    local show_time = self.m_model.m_show_time
    if show_time > 0 then
        self:setOnceTimer(show_time, function()
            self:updateMsg(99999)
        end)
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if type(self.m_model.m_callfunc) == "function" then
            self.m_model.m_callfunc()
        end
        self:closeView()
    end
end

return M
