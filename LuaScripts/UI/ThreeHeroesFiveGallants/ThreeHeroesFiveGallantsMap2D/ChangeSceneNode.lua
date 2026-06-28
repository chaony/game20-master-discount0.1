local M = class("ChangeSceneNode",LikeOO.OOUIbase)

M.m_uiName = "ThreeHeroesFiveGallantsMap/ChangeSceneNode"

function M:onEnter()
	self.m_control.m_view:lockTouch()
	
	self.changeDir = self.m_params.changeDir or 0
	self.changeFunc = self.m_params.changeFunc
	self.finish = self.m_params.finish
	
	self:setOrder(self.m_sortOrder + 50)
	
	if self.changeDir == 1 then
		self:setObjectVisible("content_left", true)
		self.m_control:setOnceTimer(0.5, self.changeFunc)
	elseif self.changeDir == 2 then
		self:setObjectVisible("content_right", true)
		self.m_control:setOnceTimer(0.5, self.changeFunc)
	else
		self:setObjectVisible("content_mid", true)
		self.changeFunc()
	end

	self.m_control:setOnceTimer(1, function()
		self:destroy()
	end)
end

function M:destroy()
	self.m_control.m_view:unlockTouch()
	self.finish()
	M.super.destroy(self)
end

return M