--玩家player 攻击AI基类
---@class AIStateAttack_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateAttack_Player",Battle.AIState)

--进入攻击状态
function M:enter()
	M.super.enter(self)
	self.startPos = self.player.position;
	if self.player:get_enemy() ~= nil then
		--我和敌人的方向
		local dir = GlobalTools:Dir(self.player.enemy.position,self.player.position)
		if self.player.isBoss == false then
			self.player:setForward(dir)
		end
	end
	--设置动画速度
	self.player:setAnimSpeed(self.player.data:getHaste())
	--Logger.logError( self.player.plyType.." 进入到 攻击状态 ")
end


--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
	if self.player ~= nil then
		--找到敌人了
		if self.player.animator.curState ~= nil then
			--可以切换动画了，就直接切换
			if self.player.animator.curState.canChangeAnim == true then
				self:checkEnemy(dt)
			end 
		end		
	end
end


--上一个动作播放完毕之后
--再次检测敌人
function M:checkEnemy(dt)
	if SceneManager.curScene.plyMgr.blackScreenPlayerCamp == 0 or
		SceneManager.curScene.plyMgr.blackScreenPlayerCamp == self.player:get_camp() then
		if self.player:get_enemy() == nil then
			self:noEnemy(dt)
		else
			if self.player.followTarget ~= nil then
				--敌人和我的距离
				local distance_enemy = GlobalTools:Distance(self.player.followTarget.position, self.player.position )
				if distance_enemy < GlobalTools:ToFix2( GlobalTools.base2 ) then
					self:hasEnemy(dt)
				else
					self.stateParam.normalEnd = true;
					self.player.aiEngine:changeState("move", self.stateParam)
				end
			else
				self:hasEnemy(dt)
			end
		end
	else
		self.stateParam.normalEnd = true;
		self.player.aiEngine:changeState("patrol", self.stateParam )
	end
end


--有敌人时
function M:hasEnemy(dt)
	--我和敌人之间的距离
	local distance = GlobalTools:Distance(self.player.position, self.player.enemy.position)
	--距离大于攻击距离
	local atkRange = self.player.data.atkRange
	--技能不空，就用技能的距离
	if self.aiEngine.skillConfig ~= nil then
        atkRange = self.aiEngine.skillConfig:getSkillDis()
	end
	if distance > GlobalTools:ToFix2( atkRange ) then
		--self.player:set_curSkillConfig(nil)
		--丢失目标
		self.player:lockEnemy(nil)
		self.stateParam.normalEnd = true;
		self.player.aiEngine:changeState("move", self.stateParam)
	else
		if self.aiEngine.skillConfig ~= nil then
			if self.aiEngine.skillConfig.type == 1 then
				self.stateParam.normalEnd = true;
				self.player.aiEngine:changeState("skill", self.stateParam)
			else
				self.stateParam.normalEnd = true;
				self.player.aiEngine:changeState("attack", self.stateParam)
			end
		else
			self.stateParam.normalEnd = true;
			self.player.aiEngine:changeState("idle", self.stateParam)
		end
	end	
end


--没有敌人时
function M:noEnemy(dt)
	self.stateParam.normalEnd = true;
	self.player.aiEngine:changeState("patrol", self.stateParam )
end

--退出当前状态
function M:exit()
	M.super.exit(self)
	--还原动画速度
	self.player:setAnimSpeed( GlobalTools.base1 )
	--Logger.logError( self.player.plyType.." 退出 攻击状态 ")
end

return M