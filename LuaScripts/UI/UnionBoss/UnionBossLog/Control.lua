local M = class("UnionBossLogControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "back_btn" then
    	self:closeView()
    elseif msg == "statistics_btn" then
    	
    end
end

return M
