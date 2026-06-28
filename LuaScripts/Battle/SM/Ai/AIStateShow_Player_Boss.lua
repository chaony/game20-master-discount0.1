--AI巡逻状态
---@class AIStateShow_Player_Boss : AIState @
---@field super AIState @AIState
local M = class("AIStateShow_Player_Boss",Battle.AIState)


local findTime = 1

M.anim_name = "in"

M.extra_anim_name = nil

M.curTime = 3.5

M.animList = nil

--进入状态
function M:enter()
	M.super.enter(self)

	self.animList = Battle.List.new()
	self.animList:add({name = self.anim_name})

	self.animList:add({name = "idle", time = -1})
	self.player.animator:startAnimList(self.animList)

	EventDispatcher:registerEvent("PlayShowAnimator", {self,self.PlayShowAnimatorHandler})
end



function M:PlayShowAnimatorHandler(eventName, data)

	self.animList:clear()
	self.animList:add({name = self.anim_name})

	self.animList:add({name = "idle", time = -1})

	self.player.animator:startAnimList(self.animList)
end



function M:update(dt)
	M.super.update(self,dt)
	if SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneRunning then
		self.player.aiEngine:changeState("patrol")
	end
end

--退出当前状态
function M:exit()
	M.super.exit(self)

	 EventDispatcher:unRegisterEvent("PlayShowAnimator", {self,self.PlayShowAnimatorHandler})
end


return M