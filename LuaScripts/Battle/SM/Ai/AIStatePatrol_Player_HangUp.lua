--挂机玩家的攻击
---@class AIStatePatrol_Player_HangUp : AIStatePatrol_Player @
---@field super AIStatePatrol_Player @AIStatePatrol_Player
local M = class("AIStatePatrol_Player_HangUp",Battle.AIStatePatrol_Player)

--进入状态
function M:enter()
	M.super.enter(self)
	self.player:setScale(self.player.base_scale);
	self.minDistance = GlobalTools:ToFix2( GlobalTools.base1 )
	self.playerMoveMinDistance = GlobalTools:ToFix2( GlobalTools.base5 )
end

--更新状态
function M:update(dt)
	M.super.update(self,dt)
end

function M:hasEnemy(dt)
	--我和敌人之间的距离
	--定点计算
	local distance = GlobalTools:Distance(self.player.enemy.position, self.player.position )
	--我和敌人的方向
	--定点计算
	--local dir = GlobalTools:Dir(self.player.enemy.position,self.player.position);
	
	local atkRange = self.player.data.atkRange
	if self.aiEngine.skillConfig ~= nil then
		if self.aiEngine.skillConfig.type ~= 2 then
			atkRange = self.aiEngine.skillConfig:getSkillDis()
		end
	end

	if distance < GlobalTools:ToFix2( atkRange ) then
		if self.player.plyMgr.scene.guide ~= nil and self.player.plyMgr.scene.guide.mode == 3 then -- 追捕模式
			self.player.aiEngine:changeState("idle")
		else
			self:useSkill()
		end
	else
		if self.player.plyMgr.scene.guide.mode == 1 then
			self.player.aiEngine:changeState("move")
		else
			if self.player.camp == 1 then
				local guide_position = self.player.plyMgr.scene.guide:getFixPosition()
				local enemy_distance = GlobalTools:Distance(self.player.enemy.position, guide_position )
				if enemy_distance < self.playerMoveMinDistance then
					self.player.aiEngine:changeState("move")
				end
			else
				self.player.aiEngine:changeState("move")
			end
		end
	end
end



--没有敌人的时候的处理
--由父类调用
function M:noEnemy(dt)
	if self.player.camp == 1 then
		--场景导航 不是空
		if self.player.plyMgr.scene.guide ~= nil then
			--我要追的点
			local point = self.player.plyMgr.scene.guide:getPoint(self.player:get_index());
			if point ~= nil then
				if self.player.plyMgr.scene.guide.mode == 1 then
					if self.player.plyMgr.scene.guide:moving() then
						if self.player.position.x < point.x then
							self:checkToMove(point);
						end
					end
				else
					--我和要追的点的距离
					self:checkToMove(point);
					--self.player.aiEngine:changeState("idle")
				end
			end
		end
	end	
end



--检测是否到移动
function M:checkToMove(point)
	--我和要追的点的距离
	local distance = GlobalTools:Distance(point, self.player.position);
	if distance > self.minDistance then
		--Logger.log( self.player.plyType.."  [ 巡逻 进入到 移动状态 ]")
		self.player.aiEngine:changeState("move")
	end
end


--退出当前状态
function M:exit()
	M.super.exit(self)
end


return M