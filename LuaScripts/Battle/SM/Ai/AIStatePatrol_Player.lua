---@class AIStatePatrol_Player : AIState @AI巡逻状态
local M = class("AIStatePatrol_Player",Battle.AIState)

local findTime = 1

M.anim_name = "idle"

M.extra_anim_name = nil

M.skillConfig = nil
--进入状态
function M:enter()
	M.super.enter(self)
	--先将动作切换到站立
	if self.extra_anim_name == nil then
		self.player.animator:changeState(self.anim_name)
	else
		self.player.animator:changeState(self.extra_anim_name)
		self.extra_anim_name = nil
	end
	self.findTime = 1
	--Logger.logError( self.player.plyType.." 进入到 巡逻状态 ")
end

--更新状态
function M:update(dt)
	M.super.update(self,dt)
	if self.player ~= nil and self.player:isLive() then
		--找到敌人了
		--没有人放大招，或者时放大招的人是我方阵营的,逻辑继续执行
		if SceneManager.curScene.plyMgr.blackScreenPlayerCamp == 0 or
			SceneManager.curScene.plyMgr.blackScreenPlayerCamp == self.player.camp then
			if self.player:get_enemy() ~= nil then
				self:hasEnemy(dt)
			else
				if SceneManager.curScene.plyMgr.getPetMgr then
					local petMgr = SceneManager.curScene.plyMgr:getPetMgr(-self.player:get_camp())
					if self.player.playerType == "pet" and (petMgr.curPet == nil or petMgr.curPet:isDead()) then -- 一方没有宠物或者宠物已死亡时也要放技能
						self:hasPetEnemy(dt)
					else
						self:noEnemy(dt)
					end
				else
					self:noEnemy(dt)
				end
			end
		end
	end
end


function M:hasEnemy(dt)
	--我和敌人之间的距离
	--定点计算
	local distance = GlobalTools:Distance(self.player.enemy.position, self.player.position )
	local atkRange = self.player.data.atkRange
	if self.aiEngine.skillConfig ~= nil then
		atkRange = self.aiEngine.skillConfig:getSkillDis()
	end
	if distance < GlobalTools:ToFix2( atkRange ) then
		self:useSkill()
	else
		self.player.aiEngine:changeState("move")
	end
end

function M:useSkill ()
	if self.aiEngine.skillConfig ~= nil then
		if self.aiEngine.skillConfig.type == 1 then
			self.player.aiEngine:changeState("skill")
		else
			self.player.aiEngine:changeState("attack")
		end
	else
		self.player.aiEngine:changeState("idle")
	end
end


function M:noEnemy(dt)
	if SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneReadyRun and self.player.isBoss ~= true then
		self.player.aiEngine:changeState("move")
	end
end

--检测宠物idle时释放技能
function M:hasPetEnemy(dt,unsdt)
	if self.aiEngine.skillConfig ~= nil then
		if self.aiEngine.skillConfig.anim_name ~= "xiezhanattack1" and self.aiEngine.skillConfig.anim_name ~= "xiezhanattack1_2" then
			self.player.aiEngine:changeState("attack")
		end
	end
end

--退出当前状态
function M:exit()
	M.super.exit(self)
	--Logger.logError( self.player.plyType.." 退出 巡逻状态 ")
end


return M