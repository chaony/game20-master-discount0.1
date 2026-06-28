local M = class("ShiguangBattleOverControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView("Shiguang")
        self:closeView()
    elseif msg == "ok_btn" then
    	self:closeView("Shiguang")
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
