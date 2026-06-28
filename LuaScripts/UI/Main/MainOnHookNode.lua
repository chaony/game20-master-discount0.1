--- 挂机宝箱
local M = class("MainOnHookNode",LikeOO.OOUIbase)

M.m_uiName = "Main/MainOnHookNode"
M.m_iphoneXAdapter = true

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	Logger.log("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
end

function M:refreshRedPoint()
	
end

function M:destroy()

end


return M