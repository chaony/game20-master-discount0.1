--AI巡逻状态
local M = class("AIStateStorySpawnNew_Player.lua", Battle.AIState)

--1为出生动画，2为跑进来
M.spawnType = nil

M.offset = 15

--进入状态
function M:enter()
	M.super.enter(self)
	self.cur_position = FixVector3.New(0,0,0);
	self.target_position = FixVector3.New(0,0,0);
	--self.player.animator:changeState("jumpin1")
	self.player.animator:changeState("jumpin1")
	if self.player.tran ~= nil then
		self.player.tran.localScale = Vector3(1,1,1);
	end
	Logger.log(" 进入 AIStateStorySpawnNew_Player ")
end

--更新状态
function M:update(dt)
	M.super.update(self,dt)
	
	if self.player ~= nil and self.player:isLive() then
		
		local state = self.player.animator.curState
		
		self.target_position.y = self.player.position.y;
		self.target_position.z = self.player.position.z;

		local distance = GlobalTools:Distance(self.player.position, self.target_position )
		if distance <= GlobalTools:ToFix2( GlobalTools.base0_5 ) then
			self.player.aiEngine:changeState("idle")
		else
			local dir = GlobalTools:Dir(self.target_position, self.player.position)
			self.player:move_no_coillder(dir * GlobalTools.base1_5, dt)
		end
	end
end


--退出当前状态
function M:exit()
	Logger.log(" 退出 AIStateStorySpawnNew_Player ")
	M.super.exit(self)
end


return M