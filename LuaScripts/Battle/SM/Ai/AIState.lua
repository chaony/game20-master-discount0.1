---@class AIState @玩家AI的状态的基类
---@field player PlayerModel
local M = class("AIState")

---@param player PlayerModel
function M:init( player, key, stateName )
	self.player = player
	self.name = stateName
	self.key = key
	self.delayTime = GlobalTools.base1
	self.curDelayTime = self.delayTime 
	
	self.aiEngine = player.aiEngine

	self.stateParam = {}
	self.checkSkillTime = GlobalTools.base0_2
	self.curcheckSkillTime = self.checkSkillTime 

	self.checkEnemyTime = GlobalTools.base0_0_3_3
	self.curcheckEnemyTime = self.checkEnemyTime 
end


function M:enter(data)
	self:createLockData();
	if SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneRunning then
		self.aiEngine.skillConfig = self.player:setCurSkillConfig()
	end
end

--更新
function M:update(dt)
	if SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneRunning then
		
		if self.curcheckSkillTime > GlobalTools.base0 then
			self.curcheckSkillTime = self.curcheckSkillTime - dt;
			if self.curcheckSkillTime <= GlobalTools.base0 then
				self.aiEngine.skillConfig = self.player:setCurSkillConfig()
				self.curcheckSkillTime = self.checkSkillTime 
			end
		end
		self:createLockData();
		-- --最近的敌人
		if self.player:get_enemy() == nil then
			local enemy = self:selectLatestEnemy()
			if enemy ~= nil then
				self.player:lockEnemy(enemy);
				if self.player.enemy ~= nil then
					self.player.enemyIndex = self.player.enemy.index
				end
			end
		else
			--人物敌人不为空
			if self.player:get_enemy() ~= nil then
				--人物死亡重新索敌
				--人物有消失buf重新索敌
				if self.player.enemy:isDead() or self.player.enemy.bufMgr:hasBufByType("Disappear") or SceneManager.curScene.plyMgr.hide_table:contains(self.player.enemy:get_playerInstanceId()) == true then
					--丢失目标
					--下一帧会索敌
					self.player:lockEnemy(nil)
				end
			end
		end
		
		--if self.player:get_enemy() ~= nil then
		--	if self.player_move_target ~= nil and self.player_move_target.IsVisi == false then
		--		Logger.logError(" AIState ~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~~~~")
		--		local enemyList = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
		--		local enemy = self:getPlayerClostest(enemyList)
		--		if enemy ~= nil then
		--			self.player:lockEnemy(enemy);
		--			self.player.enemyIndex = self.player.enemy.index
		--		end
		--	end
		--end

		if self.player.friend == nil then
			self.lock_data["camp"] = "friend"
			local friendList = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
			local friend = self:getPlayerClostest(friendList)
			if friend ~= nil then
				self.player.friend = friend
			end
		end
	end
end

function M:createLockData()
	if self.lock_data == nil then
		self.lock_data = 
		{
			["count"] = "one",--数量
			["camp"] = "enemy",--锁定类型
			["posIndex"] = "all",--位置index
			["priority"] = false,
			["ignoreSummon"] = false,--忽略宠物
			["campRace"] = "not",
			["type"] = "player",
			["pos"] = "distanceRecently",--位置
			["profession"] = "all",
			["area"] = "all",
			["areaWidth"] = 0,
			["areaHeight"] = 0,
			["areaAngle"] = 0,
			["areaRadius"] = 0,
			["forceSelect"] = false,
			["selectLast"] = false
		}

		-- 宠物
		if self.player.playerType == "pet" then
			self.lock_data.playerType = "pet"
		end
	end
end


function M:updateUnscale( unsdt )
	
end


function M:setPosition()
	
end


function M:exit()
	self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerModeAIStateExit)
	for i = 1, self.player.curSkillEnemyList.Count do
		local ply = self.player.curSkillEnemyList:get(i - 1)
		ply.lockMeList:remove(self.player)
	end
	self.player.curSkillEnemyList:clear()
end

--获取距离最近的玩家
function M:getPlayerClostest(playerList)
	--最小距离
	local minDis = GlobalTools.base999;
	local ply = nil
	for i = 1, playerList.Count do
		local temp = playerList:get(i - 1)
		if temp:isLive() and temp:equal(self.player) == false then
			local dis = GlobalTools:Distance(self.player.position, temp.position)
			if dis < GlobalTools:ToFix2(minDis) then
				ply = temp
				minDis = dis
			end
		end
	end
	return ply
end

--- 选一个最近的敌人目标
function M:selectLatestEnemy()
	self.lock_data["camp"] = "enemy"
	local enemyList = SelectTargetTool:findPlayerByType(self.lock_data, self.player)
	return enemyList:get(0)
end

return M