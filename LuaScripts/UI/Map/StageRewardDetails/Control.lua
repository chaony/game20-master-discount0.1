local M = class("StageRewardDetailsControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif  msg == "tab_click" then
        self.m_view:switchTabNode(data)
    end
end

return M