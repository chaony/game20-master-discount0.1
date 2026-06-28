--AI巡逻状态
---@class AIStateSpawn_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateSpawn_Player",Battle.AIState)

M.anim_name = "jumpin1"

M.extra_anim_name = nil

M.target = nil

--进入状态
function M:enter()
	M.super.enter(self)
	SceneManager.curScene.spawnCount = SceneManager.curScene.spawnCount + 1
	if self.player.animator.states["jumpin1"] == nil then
		TimeTools:delayTime(GlobalTools.base1,function()
			if self.player.aiEngine then
				self.player.aiEngine:changeState("idle")
			end
		end)
		return
	end
	--self.player:setScale(GlobalTools.base1)
	--先将动作切换到站立
	if self.extra_anim_name == nil then
		--Logger.log(" 切换动画 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "..self.anim_name )
		self.player.animator:changeState(self.anim_name)
	else
		--Logger.log(" 切换动画 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "..self.extra_anim_name )
		self.player.animator:changeState(self.extra_anim_name)
		self.extra_anim_name = nil
	end
end

--更新状态
function M:update(dt)
	M.super.update(self,dt)
	if self.player ~= nil and self.player:isLive() then
		local state = self.player.animator.curState
		if state ~= nil then
			--出生状态结束
			if state.running == false or (state.isLooping == true and self.player.moveMgr.moveFrames.Count <= 0) then
				self.player.aiEngine:changeState("idle")
			end
		end
	end
end


--退出当前状态
function M:exit()
	M.super.exit(self)
	SceneManager.curScene.spawnCount = SceneManager.curScene.spawnCount - 1
	if SceneManager.curScene.spawnCount <= 0 and self.player:get_master() == nil then
		SceneManager.curScene:playerSpawnFinish()
	end
end


return M