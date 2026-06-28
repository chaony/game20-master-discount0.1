local SceneManager = SceneManager
local GlobalTools = GlobalTools

--AI的移动状态的基础类
---@class AIStateMove_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateMove_Player",Battle.AIState)

M.testTime = 0.3

M.anim_name = "run"

M.extra_anim_name = nil

M.skillConfig = nil

--进入移动状态
function M:enter()
	M.super.enter(self)
	--先将动作切换到站立
	if self.extra_anim_name == nil then
		self.player.animator:changeState(self.anim_name)
	else
		self.player.animator:changeState(self.extra_anim_name)
		self.extra_anim_name = nil
	end
	--设置动画速度
	local animSpeed = GlobalTools:Div( self.player.data:getSpd(), self.player.data:get_moveSpeed())
	self.player:setAnimSpeed( animSpeed )
	--Logger.logError( self.player.plyType.." 进入到 移动状态 ")
end


function M:setPosition()
	M.super.setPosition(self)
end

--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
	if self.player ~= nil and self.player:isLive() then
		if self.player.data:getSpd() > GlobalTools.base0 then
			--每帧获取当前的技能
			self.player:set_curSkillConfig(self.aiEngine.skillConfig)
			--找到敌人了
			if SceneManager.curScene.plyMgr.blackScreenPlayerCamp == 0 or
					SceneManager.curScene.plyMgr.blackScreenPlayerCamp == self.player.camp  then
				if self.player.followTarget ~= nil then
					self:moveToTarget(dt)
				else
					if self.player:get_enemy() ~= nil then
						self:hasEnemy(dt)
					else
						self:noEnemy(dt)
					end
				end
			else
				self.player.aiEngine:changeState("patrol")
			end
		else
			self.player.aiEngine:changeState("idle")
		end
	end
end

function M:moveToTarget(dt)
	--敌人和我的距离
	local distance_enemy = GlobalTools:Distance(self.player.followTarget.position, self.player.position )
	if distance_enemy < GlobalTools:ToFix2( GlobalTools.base1_5 ) then
		if self.player:get_enemy() ~= nil then
			self:useSkill()
		else
			self.player.aiEngine:changeState("idle")
		end
	else
		--我和敌人的方向
		local dir_enemy = GlobalTools:Dir(self.player.followTarget.position,self.player.position)
		--玩家移动
		self.player:move_no_coillder(dir_enemy,dt)
		self.player:rotaTo(dir_enemy,dt);
	end
end

function M:noEnemy(dt)
	self.player.aiEngine:changeState("patrol")
end

--我和队友之间的距离
function M:disFriend(radius,ply)
	self.player.apieceIndex = 0
	local players = self.player.plyMgr:getPlayers(ply:get_camp())
	for i = 1,players.Count,1 do
		local friend =players:get(i-1) 
	 	local distance = GlobalTools:Distance(ply.position, friend.position)
	 	if distance <= GlobalTools:ToFix2(radius) then
			ply.apieceIndex = ply.apieceIndex + 1						
		end
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


--检测我和敌人
function M:hasEnemy(dt)
	
end


--退出当前状态
function M:exit()
	M.super.exit(self)
	--还原动画速度
	self.player:setAnimSpeed( GlobalTools.base1 )
	--Logger.logError( self.player.plyType.." 退出 移动状态 ")
end



return M
