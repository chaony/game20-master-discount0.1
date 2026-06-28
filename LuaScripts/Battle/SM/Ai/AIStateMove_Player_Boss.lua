--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-02 19:04:05
]]

--AI的移动状态
---@class AIStateMove_Player_Boss : AIStateMove_Player @
---@field super AIStateMove_Player @AIStateMove_Player
local M = class("AIStateMove_Player_Boss",Battle.AIStateMove_Player)


--进入移动状态
function M:enter()
	M.super.enter(self)
	self.isArrive = false
	self.player.waitTime = -1;
	self.lock_enemy_time = 1;
	self.cur_lock_enemy = self.lock_enemy_time;
	if self.grid ~= nil then
		self.grid:setValue(0);
	end
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
	self:hasEnemy_Rule(dt)
end


--近战的规则
function M:hasEnemy_Rule(dt)
	
	local atkRange = self.player.data.atkRange
	if self.player.curSkillConfig ~= nil then
		atkRange = self.player.curSkillConfig:getSkillDis()
	end
	--玩家移动
	self:moveToEnemy(atkRange, dt);
	
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


--没有敌人的时候的处理
function M:noEnemy(dt)
    if SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneReadyRun then
        if self.player.camp == 1 then
            self.player:move_no_coillder(FixVector3.forward() * self.player.camp, dt)
        end
	else
		self.player.aiEngine:changeState("patrol")
	end
end


return M