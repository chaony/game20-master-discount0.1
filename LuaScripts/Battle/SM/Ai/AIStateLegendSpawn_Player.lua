--AI巡逻状态
---@class AIStateLegendSpawn_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateSpawn_Player",Battle.AIState)

M.anim_name = "run"

M.extra_anim_name = nil

--进入状态
function M:enter(data)
	M.super.enter(self)
	self.player.animator:changeState(self.anim_name)
	self.spawnDist = data.spawnDist
	self.finishCallBack = data.finishCallBack
	self.pos = FixVector3.New(0,0,0)
	self.pos.x = self.player.position.x
	self.pos.y = self.player.position.y
	self.pos.z = self.player.position.z
end

--更新状态
function M:update(dt)
	M.super.update(self,dt)
	if self.player ~= nil then
		local dir = self.player:getForward()
		self.player:move_no_coillder(dir, dt)
		if GlobalTools:Distance(self.pos, self.player.position) >= GlobalTools:Mul(self.spawnDist, self.spawnDist) then
			self.player.aiEngine:changeState("idle")
		end
	end
end


--退出当前状态
function M:exit()
	M.super.exit(self)
	--if self.finishCallBack ~= nil then
	--	self.finishCallBack()
	--end
end


return M