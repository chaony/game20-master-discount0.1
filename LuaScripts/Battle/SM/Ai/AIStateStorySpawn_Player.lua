--AI巡逻状态
local M = class("AIStateStorySpawn_Player.lua", Battle.AIState)

--1为出生动画，2为跑进来
M.spawnType = nil

M.offset = 15

--进入状态
function M:enter()
	M.super.enter(self)
	if self.player.moveType == 1 then
		self.offset = 10
		self.cur_position = FixVector3.New(0,0,0);
		self.target_position = FixVector3.New(0,0,0);
		self.player.animator:changeState("jumpin1")
	elseif self.player.moveType == 2 then
		self.offset = 5
		self.player.animator:changeState("run")
		self.player:setPos( self.player.position - self.player.forward * self.offset);
	end
	if self.player.tran ~= nil then
		self.player.tran.localScale = Vector3(1,1,1);
	end
end

--更新状态
function M:update(dt)
	M.super.update(self,dt)
	if self.player ~= nil and self.player:isLive() then
		local state = self.player.animator.curState
		--出生状态结束
		if self.player.moveType == 1 then
			if state.running == false then
				self.player.aiEngine:changeState("idle")
			end

			self.cur_position.x = self.player.position.x;
			self.cur_position.y = self.player.position.y;
			self.cur_position.z = self.player.position.z;

			self.target_position.y = self.player.position.y;
			self.target_position.z = self.player.position.yz;
			
			local distance = GlobalTools:Distance(self.cur_position, self.target_position )
			if distance <= GlobalTools:ToFix2( 0.5 ) then
				local dir = GlobalTools:Dir(self.cur_position, self.target_position)
				self.player:move_no_coillder(dir, dt)
			else
				self.player.aiEngine:changeState("idle")
			end
			
		elseif self.player.moveType == 2 then
			local spawnPoint = GlobalTools:ToFixVector3(SceneManager.curScene:findSpawnPosition(self.player.camp, self.player.index))
			local dir = GlobalTools:Dir(spawnPoint, self.player.position)
			self.player:move_no_coillder(dir, dt)
			local distance = GlobalTools:Distance(spawnPoint, self.player.position )
			if distance <= GlobalTools:ToFix2( 0.5 ) then
				self.player.aiEngine:changeState("idle")
			end
		end
	end
end


--退出当前状态
function M:exit()
	M.super.exit(self)
	--到达
	if self.player.storyMoveFinish ~= nil then
		self.player.storyMoveFinish();
	end
end


return M