local M = class("WorldBossRewardControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "back_btn" then
    	self:closeView()
    elseif msg == "ok_btn" then
    	self:closeView()
    end
end

return M
