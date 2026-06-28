local M = class("LoadingControl",LikeOO.OOControlBase)

function M:onEnter()
    local show_time = self.m_model.m_show_time
    if show_time > 0 then
        self:setOnceTimer(show_time, function()
            self:updateMsg(99999)
        end)
    end
    local delay_show = self.m_model.m_delay_show
    if delay_show > 0 then
        self.m_view:setObjectVisible("Content", false)
        self:setOnceTimer(delay_show, function()
            self.m_view:setObjectVisible("Content", true)
        end)
    else
        self.m_view:setObjectVisible("Content", true)
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
