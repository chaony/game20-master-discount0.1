---@class AIStateMove_Player_HangUp : AIStateMove_Player @
---@field super AIStateMove_Player @AIStateMove_Player
local M = class("AIStateMove_Player_HangUp",Battle.AIStateMove_Player)

--进入移动状态
function M:enter()
	M.super.enter(self)
	--是否移动到目标点
	self.player.move_target_finish = false;
	self.minDistance = GlobalTools:ToFix2( GlobalTools.base0_5 );
end

--更新移动状态
function M:update(dt)
	M.super.update(self,dt)
end

function M:noEnemy(dt)
	--没有找到敌人
	--场景导航不是空
	--只有英雄会走这个逻辑
	--敌人不走 
	--挂机AI中独有的逻辑
	if self.player:get_camp() == 1 then
		if self.player.master == nil then
			if self.player.plyMgr.scene.guide ~= nil then
				local point = self.player.plyMgr.scene.guide:getPoint(self.player.index)
				if self.player.plyMgr.scene.guide.mode == 1 then
					if self.player.plyMgr.scene.guide:moving() then
						if self.player.position.x < point.x then
							self:followPoint( point, dt );
						end
					end
				else
					self:followPoint( point, dt );
					--我和要追的点的距离
					--self.player.aiEngine:changeState("patrol")
				end
			else
				--切换到巡逻
				self.player.aiEngine:changeState("patrol")
			end
		else
			local dir = GlobalTools:Dir(self.player.master.position, self.player.position)
			self.player:rotaTo(dir,dt)
			if self.player.hangupFollowOffset then	-- 指定挂机跟随属性
				self.player:setPos(self.player.master:get_position() + self.player.hangupFollowOffset, true)
			else
				self.player:setPos(self.player.master:get_position(), true)
			end
		end
	end
end

function M:followPoint(point, dt, rate )
	--我和要追的点的距离
	local distance = GlobalTools:Distance(point, self.player.position)
	if distance > self.minDistance  then
		local dir = GlobalTools:Dir(point, self.player.position)
		--玩家移动
		self.player:move_no_coillder(dir,dt)
		self.player:rotaTo(dir,dt)
	else
		--Logger.logError( self.player.plyType.."  [ 移动 进入到 巡逻状态 ]")
		--切换到巡逻
		self.player.aiEngine:changeState("patrol")
	end
end


function M:hasEnemy(dt)
	local atkRange = self.player.data.atkRange
	if self.player.curSkillConfig ~= nil then
		atkRange = self.player.curSkillConfig:getSkillDis()
	end
	 --if atkRange < 4 then
		--if self.player.move_target_finish == false then
		--	self.player.move_target_finish = self.player:move_astar(dt);
		--end
		--if self.player.move_target_finish then
		--	self:moveToEnemy(dt);
		--end
	 --else
		--self:moveToEnemy(dt);
	 --end

	if self.player:get_camp() == 1 then
		if self.player.plyMgr.scene.guide ~= nil and self.player.plyMgr.scene.guide.mode == 3 then-- 追捕模式
			local point = self.player.plyMgr.scene.guide:getPoint(self.player.index)
			self:followPoint( point, dt );
		else
			self:moveToEnemy(dt);
		end
	else
		self:moveToEnemy(dt);
	end
	
end

function M:moveToEnemy(dt)
	--Logger.log(self.player.plyType.." [ 挂机移动 ---- 有敌人 ]")
	--我和敌人之间的距离
	--定点计算
	local distance = GlobalTools:Distance(self.player.enemy.position, self.player.position )
	--我和敌人的距离小于 攻击距离
	local atkRange = self.player.data.atkRange
	if self.player.curSkillConfig ~= nil then
		atkRange = self.player.curSkillConfig:getSkillDis()
	end

	if distance <= GlobalTools:ToFix2( atkRange ) then
		if self.player.plyMgr.scene.guide ~= nil and self.player.plyMgr.scene.guide.mode == 3 then-- 追捕模式
			self.player.aiEngine:changeState("idle")
		else
			self:useSkill()
		end
	else
		--我和敌人的方向
		--定点计算
		local dir = GlobalTools:Dir(self.player.enemy.position,self.player.position)
		--玩家移动
		self.player:move_no_coillder(dir,dt)
		self.player:rotaTo(dir,dt);
	end
end



--退出当前状态
function M:exit()
	M.super.exit(self)
end


return M