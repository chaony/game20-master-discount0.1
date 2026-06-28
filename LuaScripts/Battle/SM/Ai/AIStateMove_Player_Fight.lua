
--AI的移动状态
---@class AIStateMove_Player_Fight : AIStateMove_Player @
---@field super AIStateMove_Player @AIStateMove_Player
local M = class("AIStateMove_Player_Fight",Battle.AIStateMove_Player)


--进入移动状态
function M:enter()
	M.super.enter(self)
	self.isArrive = false
	--索敌时间
	self.lock_enemy_time = GlobalTools.base1;
	--当前的索敌时间
	self.cur_lock_enemy = self.lock_enemy_time;
	--是否移动到目标点
	self.move_target_finish = false;
	--玩家进入到移动状态
	if self.grid ~= nil then
		self.grid:setValue(0);
	end
	--Logger.logError(self.player.plyType.." 进入了移动状态 ")
end

--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
end

--退出当前状态
function M:exit()
	M.super.exit(self)
end


--有
function M:hasEnemy(dt)
	self.cur_lock_enemy = self.cur_lock_enemy - dt;
	if self.cur_lock_enemy <= 0 then
		local enemy = nil
		if self.player.playerType == "pet" then
			enemy = self:selectLatestEnemy()
		else
			enemy = GlobalTools:findPlayer(self.player, true ,1,-1, 0)
		end
		self.player:lockEnemy(enemy)
		self.cur_lock_enemy = self.lock_enemy_time;
	end

	if self.player:get_enemy() ~= nil then
		--定点计算
		--近战
		if self.player.plyData.fight_type == 1 then
			self:hasEnemy_Rule(dt)
		else
			self:hasEnemy_Rule_Common(dt)
		end
	else
		self:noEnemy(dt)
	end
end


--近战的规则
function M:hasEnemy_Rule(dt)
	
	local atkRange = self.player.data.atkRange
	if self.player.curSkillConfig ~= nil then
		atkRange = self.player.curSkillConfig:getSkillDis()
	end
	
	--攻击距离小于3的技能走具体位置逻辑
	--if atkRange < GlobalTools.base4 then
	--	self:calculateWay03(atkRange,dt)
	--else
		--玩家移动
		self:moveToEnemy(atkRange, dt);
	--end
end

--AStar移动 和 伪AStar玩家战斗
function M:calculateWay03(atkRange, dt)
	--敌人和我的距离
	local distance_enemy = GlobalTools:Distance(self.player.enemy.position, self.player.position )
	if distance_enemy < GlobalTools:ToFix2( atkRange ) then
		self:useSkill()
	else
		--if self.move_target_finish == false then
		--	self.move_target_finish = self.player:move_astar(dt);
		--end
		--if self.move_target_finish then
			self:moveToEnemy(atkRange, dt);
		--end
	end
end

--移动到敌人
function M:moveToEnemy(atkRange, dt)
	--敌人和我的距离
	local distance_enemy = GlobalTools:Distance(self.player.enemy.position, self.player.position )
	if distance_enemy < GlobalTools:ToFix2( atkRange ) then
		self:useSkill()
	else
		--我和敌人的方向
		local dir_enemy = GlobalTools:Dir(self.player.enemy.position,self.player.position)
		--玩家移动
		self.player:move_no_coillder(dir_enemy,dt)	
		if self.player.isBoss == false then
			self.player:rotaTo(dir_enemy,dt);
		end
	end
end


--传统的规则
function M:hasEnemy_Rule_Common(dt)
	
	local distance = GlobalTools:Distance(self.player.enemy.position, self.player.position )

	--我和敌人的距离小于 攻击距离
	local atkRange = self.player.data.atkRange
	if self.aiEngine.skillConfig ~= nil then
		atkRange = self.aiEngine.skillConfig:getSkillDis()
	end

	if distance < GlobalTools:ToFix2( atkRange ) then
		if self.aiEngine.skillConfig ~= nil then
			if self.aiEngine.skillConfig.type == 1 then
				self.player.aiEngine:changeState("skill")
				return
			else
				self.player.aiEngine:changeState("attack")
				return
			end
		else
			self.player.aiEngine:changeState("idle")
			return
		end
	end

	--我和敌人的方向
	--定点计算
	local dir = GlobalTools:Dir(self.player.enemy.position,self.player.position)
	--玩家移动
	self.player:move_no_coillder(dir,dt)
	if self.player.isBoss == false then
		self.player:rotaTo(dir,dt);
	end
end

--没有敌人的时候的处理
function M:noEnemy(dt)
	if SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneReadyRun then
		self.player:move_no_coillder(self.player.forward, dt)
	else
		self.player.aiEngine:changeState("patrol")
	end
end


return M
