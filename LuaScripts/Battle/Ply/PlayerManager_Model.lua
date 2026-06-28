---@class PlayerManager_Model : ModelBase @玩家管理类
---@field hero_list Battle_List<PlayerModel>
---@field enemy_list Battle_List<PlayerModel>
---@field all_list Battle_List<PlayerModel>
---@field attacker_relicMgr RelicManager
---@field defender_relicMgr RelicManager
---@field scene Scene_Model
---@field hero_table table<number, ConfigHeroDetail>
---@field summon_list ListMap<PlayerModel>
---@field attackerTeam Team_Model
---@field defenderTeam Team_Model
local M = class("PlayerManager_Model",Battle.ModelBase)

--敌人列表
M.enemy_list = nil

--英雄的列表
M.hero_list= nil

--召唤物的列表
M.summon_list= nil

--隐藏角色的列表（会从原有列表移除，结束后放回）
M.hide_table = nil

--玩家管理器所在的scene 
M.scene = nil

--我方英雄斗气
-- M.heroFightScore = nil

-- --敌人英雄斗气
-- M.enemyFightScore = nil

--玩家技能配置信息
M.playerSkillConfig = nil

M.gamestart = false

M.attacker_relicMgr = nil
M.defender_relicMgr = nil

M.spawnCount = 0
--平均等级
M.averageLevel = 0

--敌人掉血统计
M.enemylostHplist = nil
M.enemylostHplistFix = nil

--英雄掉血统计
M.herolostHplist = nil
M.herolostHplistFix = nil

--玩家管理初始化
function M:start( scene )
	--记录一下当前的scene
	self.scene = scene
	--开场技结束
	self.openingSkillFinish = true;
	--全局的黑屏时间
	self.blackScreenTime = 0;
	--当前进入到黑屏的玩家的阵营
	self.blackScreenPlayerCamp = 0
	--每个技能的细节数据
	self.playerSkillConfig = {}
	--召唤物id
	self.summon_index = 0
	
	self.hide_table = Battle.ListMap.new()
	self.enemylostHplist = {}
	self.enemylostHplistFix = {}
	self.herolostHplist = {}
	self.herolostHplistFix = {}

	--英雄表的数据
	self.hero_table = ConfigManager:getCfgByName("hero_detail");
	--清除
	self:clear()
	
	--我方遗物
	self.attacker_relicMgr = require("Battle.Relic.RelicManager").new()
	self.attacker_relicMgr:init(self, 1)
	
	--敌人遗物
	self.defender_relicMgr = require("Battle.Relic.RelicManager").new()
	self.defender_relicMgr:init(self, -1)

	-- 我方宠物
	self.attacker_petMgr = require("Battle.Pet.PetManager").new()
	self.attacker_petMgr:init(self, 1)

	-- 敌方宠物
	self.defender_petMgr = require("Battle.Pet.PetManager").new()
	self.defender_petMgr:init(self, -1)
	
	
	--黑屏时间管理器
	self.blackTimeManager = require("Battle.Data.BlackTimeManager").new()
	--注册回调
	self.blackTimeManager:init(self)
	
	--Logger.logError("<[PlayerManager_Model]> Model创建完成 发送事件 ")
	--通过场景发送事件出去，通知视图层，我的PlayerManager创建好了
	self.scene:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerModelCreateFinish, self)
end

function M:createTeam()
	-- 队伍数据
	self.attackerTeam = require("Battle.Ply.Team_Model").new()
	self.attackerTeam:init(self, 1)

	self.defenderTeam = require("Battle.Ply.Team_Model").new()
	self.defenderTeam:init(self, -1)
end

-- 创建玩家
-- 玩家id    playerId
-- 玩家阵营   camp
-- 创建需要用的数据  playerData
-- 用户自定义的位置坐标 
---@param playerData Battle_CreatePlayerData
function  M:createPlayer( playerData, camp, index, userPos, master)
	--玩家出生点位置
	local pos = userPos
	if pos == nil then
		if index ~= nil then
			pos = self:getSpawnPos(camp, index, playerData.playerType)
		else
			index = 0;
		end
	end
	--创建一个玩家的数据层
	local player_model = Battle.Player_Model.new()
	--这里包含创建玩家的所有数据
	---@type Battle_CreatePlayerData
	local createData = {}
	--服务器传来的技能
	createData.skill = playerData.skill;
	--玩家的id
	createData.playerId = playerData.id;
	--AI类型
	createData.summonAiType = playerData.summonAiType;
	--玩家是否是宠物类型
	createData.summonType = playerData.summonType;
	-- 玩家类型 玩家/宠物
	createData.playerType = playerData.playerType or "player";
	--初始buff
	createData.buffs = playerData.buffs;
	-- 秘籍
	createData.mystics = playerData.mystics;	
	-- 秘籍buffs
	createData.mystic_buffs = playerData.mystic_buffs;
	--阵营
	createData.camp = camp;
	--玩家的位置索引
	createData.index = index;
	--玩家的主人
	createData.master = master;
	--玩家等级
	if playerData.clv ~= nil and playerData.clv > 0 then
		createData.lv = playerData.clv;
	else
		createData.lv = playerData.lv;
	end
	createData.clv = playerData.clv;
	--玩家等级
	createData.evo = playerData.evo;
	-- 皮肤
	createData.skin = playerData.skin;
	-- 英雄在彩色5星之后，在图鉴中的升级属性增加
	createData.book = playerData.book;
	-- 天命化星等级
	createData.fate_level = playerData.fate_level;
	-- 共鸣等级
	createData.resonance_lv = playerData.resonance_lv;
	--玩家一开始的出生位置
	createData.pos = pos;
	--宠物战斗数据增加气势比拼结果
	createData.power_win = playerData.power_win;
	--宠物 心情
	createData.mood = playerData.mood;
	
	--符篆套裝屬性
	createData.seal_character_buffs = playerData.seal_character_buffs
	--玩家管理器
	createData.plyMgr = self;
	--玩家
	createData.plyData = self.hero_table[createData.playerId]
	if createData.plyData == nil then
		Logger.logError(" 玩家id 找不到 "..createData.playerId )
		Logger.logError(debug.traceback())
	end
	if SceneManager.curScene.isUseConfig == true then
		createData.plus_level = playerData.plus_level
		self:replacePlusSkill(playerData, createData)
	end
	--玩家的AI 引擎
	local ai = nil
	if createData.summonAiType == nil or createData.summonAiType == "humMan"  then
		ai = self:createAI("AIEnginePlayer")
	else
		ai = self:createAI("AIEngineSummon")
	end
	createData.ai = ai;
	--是否是剧情人物，这个是视图层的会挪动到视图层
	createData.isStoryPlayer = playerData.isStoryPlayer or false;
	--移动方式，这个是视图层的会挪动到视图层
	createData.moveType = playerData.moveType or 0
	-- 指定模型
	createData.custom_prefab = playerData.custom_prefab
	--初始化人物数据
	player_model:init(createData)

	if createData.playerType == "pet" then -- 宠物
		if createData.camp == 1 then
			self.attacker_petMgr:addPet(player_model)
		else
			self.defender_petMgr:addPet(player_model)
		end
	else
		if createData.summonType == "special" then
			self.summon_list:add(player_model)
		else
			if camp == 1 then
				self.hero_list:add(player_model)
			else
				self.enemy_list:add(player_model)
			end
			self.all_list:add(player_model)
		end
	end

	player_model.plySkill:initFinish()
	
	return player_model
end

function M:replacePlusSkill(playerData, createData)
	if playerData.oldSkillTab and playerData.plusSkillTab then
		for i = 1, #playerData.oldSkillTab do
			if playerData.oldSkillTab[i] > 0 then
				for j =1, #createData.plyData.skill do
					local needReplace = false
					for k, v in pairs(createData.plyData.skill[j]) do
						if v[1] == playerData.oldSkillTab[i] then
							needReplace = true
						end
					end
					if needReplace then
						for k, v in pairs(createData.plyData.skill[j]) do
							v[1] = playerData.plusSkillTab[i]
						end
					end
				end
			end
		end
	end
end
--- 获取出生点
function M:getSpawnPos(camp, index, playerType)
	if playerType == "pet" then
		-- 如果是协战宠物，读取宠物位置
		return self.scene:findPetSpawnPosition(camp, index)
	else
		if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI then
			return self.scene:findPetDouJiSpawnPosition(camp, index)
		else
			return self.scene:findSpawnPosition(camp, index)
		end
	end
	return FixVector3.New(0,0,0)
end

--加入阵法buf
function M:addZhenFaBuf( camp, zhenfa_id )
	if camp == 1 then
		self.scene.ZhenFaManager:setHeroZhenFaID( zhenfa_id );
	else
		self.scene.ZhenFaManager:setEnemyZhenFaID( zhenfa_id );
	end
	--非阵眼buf
	local no_pos_buf = self.scene.ZhenFaManager:getGlobalBufID( camp );
	--阵眼buf
	local pos_buf = self.scene.ZhenFaManager:getIndexBufID( camp );
	--阵眼
	local pos = self.scene.ZhenFaManager:getPos( camp );

	if camp == 1 then
		if no_pos_buf ~= nil then
			for i,v in ipairs(no_pos_buf) do
				local bufid = v;
				for i = 1,self.hero_list.Count do
					local ply = self.hero_list:get(i-1);
					if ply.index ~= pos then
						ply.bufMgr:addBufById( bufid,ply );
					end
				end
			end
		end

		if pos_buf ~= nil then
			for i,v in ipairs(pos_buf) do
				local bufid = v;
				for i = 1,self.hero_list.Count do
					local ply = self.hero_list:get(i-1);
					if ply.index == pos then
						ply.bufMgr:addBufById( bufid,ply );
					end
				end
			end
		end
	else
		if no_pos_buf ~= nil then
			for i,v in ipairs(no_pos_buf) do
				local bufid = v;
				for i = 1,self.enemy_list.Count do
					local ply = self.enemy_list:get(i-1);
					if ply.index ~= pos then
						ply.bufMgr:addBufById( bufid,ply );
					end
				end
			end
		end

		if pos_buf ~= nil then
			for i,v in ipairs(pos_buf) do
				local bufid = v;
				for i = 1,self.enemy_list.Count do
					local ply = self.enemy_list:get(i-1);
					if ply.index == pos then
						ply.bufMgr:addBufById( bufid,ply );
					end
				end
			end
		end
	end
end


function M:addIndexBuf( camp, pos, bufId )
	if camp == 1 then
		for i = 1,self.hero_list.Count do
			local ply = self.hero_list:get(i-1);
			if ply.index == pos then
				ply.bufMgr:addBufById( bufId,ply );
			end
		end
	else
		for i = 1,self.enemy_list.Count do
			local ply = self.enemy_list:get(i-1);
			if ply.index == pos then
				ply.bufMgr:addBufById( bufId,ply );
			end
		end
	end
end


--重新设定玩家位置 
function M:resetPlayerPosition()
	for i = 1, self.hero_list.Count do
		local ply = self.hero_list:get(i-1);
		if ply ~= nil then
			local pos = self.scene:findSpawnPosition(1, ply.index)
			ply:updateLevelEffect();
			ply:setPos( pos )
			ply:setPosition();
		end
	end

	for i = 1, self.enemy_list.Count do
		local ply = self.enemy_list:get(i-1);
		if ply ~= nil then
			local pos = self.scene:findSpawnPosition(-1, ply.index)
			ply:updateLevelEffect();
			ply:setPos( pos )
			ply:setPosition();
		end
	end
	--通知视图层 重新设定玩家位置
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerResetPlayerPosition)
end


function M:restart()
	for i = 1,self.hero_list.Count do
		self.hero_list:get(i-1):restart()
	end
	for i = 1,self.enemy_list.Count do
		self.enemy_list:get(i-1):restart()
	end
end


---@param ply PlayerModel
function M:removePlayerFromList(ply)
	for i=self.enemy_list.Count,1,-1 do
		local player = self.enemy_list:get(i-1)
		if player == ply then
			self.enemy_list:removeAt(i-1)
		end
	end

	for i=self.hero_list.Count,1,-1 do
		local player = self.hero_list:get(i-1)
		if player == ply then
			self.hero_list:removeAt(i-1)
		end
	end
end

function M:removePlayerFromOtherPlayerList(ply)
	for i=self.enemy_list.Count,1,-1 do
		local player = self.enemy_list:get(i-1)
		player:removeOtherPlayer(ply)
	end

	for i=self.hero_list.Count,1,-1 do
		local player = self.hero_list:get(i-1)
		player:removeOtherPlayer(ply)
	end
end

--删除某个玩家
function M:destroyAllPlayer(isDestoryObj )
	--self:dumpAllPlayer("destroyAllPlayer " .. tostring(isDestoryObj))
	for i = self.summon_list.Count, 1, -1 do
		local ply = self.summon_list:get(i-1)
		if ply ~= nil then
			ply:destroy(isDestoryObj)
		end
	end
	self.summon_list:clear()

	for i = self.hide_table.list.Count, 1, -1 do
		local instanceId = self.hide_table.list:get(i-1)
		---@type PlayerModel
		local ply = self.hide_table:get(instanceId)
		if ply ~= nil then
			ply:destroy(isDestoryObj)
		end
	end
	self.hide_table:clear()
	
	for i = self.hero_list.Count, 1, -1 do
		local ply = self.hero_list:get(i-1)
		if ply ~= nil then
			ply:destroy(isDestoryObj)
		end
	end
	self.hero_list:clear()

	for i = self.enemy_list.Count, 1, -1 do
		local ply = self.enemy_list:get(i-1)
		if ply ~= nil then
			ply:destroy(isDestoryObj)
		end
	end
	self.enemy_list:clear()
end

--删除某个玩家
---@param ply PlayerModel
function M:destoryPlayer( ply, isDestoryObj )
	self:removePlayerFromList(ply);
	ply:destroy(isDestoryObj)
end

--删除协战宠物
---@param ply PlayerModel
function M:destoryXieZhanPet( ply, isDestoryObj )
	if self.attacker_petMgr.curPet == ply then
		self.attacker_petMgr:destroy(isDestoryObj)
	elseif self.defender_petMgr.curPet == ply then
		self.defender_petMgr:destroy(isDestoryObj)
	end
end


--清除玩家，敌人，英雄数组
function M:clear()
	if self.enemy_list ~= nil then
		self.enemy_list:clear()
	else
		self.enemy_list = Battle.List.new()
	end

	if self.hero_list ~= nil then
		self.hero_list:clear()
	else
		self.hero_list = Battle.List.new()
	end
	
	if self.all_list ~= nil then
		self.all_list:clear()
	else
		self.all_list = Battle.List.new()
	end

	if self.summon_list ~= nil then
		self.summon_list:clear()
	else
		self.summon_list = Battle.List.new()
	end
	self.hide_table:clear()
	self.herolostHplist = {}
	self.herolostHplistFix = {}
	self.enemylostHplist = {}
	self.enemylostHplistFix = {}
end

function M:addHide(player)
	if player.master ~= nil then
		if self.summon_list:contains(player) then
			self.summon_list:remove(player)
		end
	else
		if player.camp == 1 then
			if self.hero_list:contains(player) then
				self.hero_list:remove(player)
			end
		else
			if self.enemy_list:contains(player) then
				self.enemy_list:remove(player)
			end
		end
	end
	self.hide_table:add(player:get_playerInstanceId(),player)
end

function M:removeHide(player)
	if self.hide_table:get(player:get_playerInstanceId()) ~= nil then
		if player.master ~= nil then
			self.summon_list:add(player)
		else
			if player.camp == 1 then
				self.hero_list:add(player)
			else
				self.enemy_list:add(player)
			end
		end
		self.hide_table:remove(player:get_playerInstanceId())
	end
end

--- 清理掉隐藏列表，防止有些角色移除不干净
function M:clearHideList()
	for i = self.hide_table.list.Count, 1, -1 do
		local instanceId = self.hide_table.list:get(i-1)
		---@type PlayerModel
		local ply = self.hide_table:get(instanceId)
		if ply ~= nil then
			self:removeHide(ply)
		end
	end
end

function M:update_unsdt( unsdt )
	for i=self.hero_list.Count,1,-1 do
		local player = self.hero_list:get(i-1)
		if player ~= nil then
			if player:isDestroy() then
				self.hero_list:removeAt(i-1)
			else
				if player.animator ~= nil and player.animator.mode ~= 0 then
					player:update(unsdt)
				end
			end
		end
	end
	
	for i=self.enemy_list.Count,1,-1 do
		local player = self.enemy_list:get(i-1)
		if player ~= nil then
			if player:isDestroy() then
				self.enemy_list:removeAt(i-1)
			else
				if player.animator ~= nil and player.animator.mode ~= 0 then
					player:update(unsdt)
				end
			end
		end
	end
	
	--Logger.logError(" 同屏人数 ~~~~~ "..(self.hero_list.Count+self.enemy_list.Count) )

	for i=self.all_list.Count,1,-1 do
		local player = self.all_list:get(i-1)
		if player ~= nil then
			if player:isDestroy() then
				self.all_list:removeAt(i-1)
			end
		end
	end
	
	--更新黑屏时间
	if self.blackTimeManager ~= nil then
		self.blackTimeManager:updateBlackTime(unsdt);
	end

	for i=self.summon_list.Count,1,-1 do
		local player = self.summon_list:get(i-1)
		if player ~= nil then
			if player:isDestroy() then
				self.summon_list:removeAt(i-1)
			else
				if player.animator ~= nil and player.animator.mode ~= 0 then
					player:update(unsdt)
				end
			end
		end
	end

	for i = 1, self.hide_table.list.Count do
		local instanceId = self.hide_table.list:get(i-1)
		local ply = self.hide_table:get(instanceId)
		if ply ~= nil and ply.animator ~= nil and ply.animator.mode ~= 0 then
			ply:update(unsdt)
		end
	end
	self:addReplayFix()
	self:checkGameOver();
end

function M:addReplayFix()
	if not SceneManager.curScene.replayFix then
		return
	end

	local curFrame = SceneManager.curScene:get_loopTimeNormal()
	local replayFix = SceneManager.curScene.replayFix
	
	
	for i=self.hero_list.Count,1,-1 do
		local player = self.hero_list:get(i-1)
		if player ~= nil then
			replayFix:fixPlayerInfo(curFrame, player)
			replayFix:fixDeadInfo(curFrame, player)
		end
	end

	for i=self.enemy_list.Count,1,-1 do
		local player = self.enemy_list:get(i-1)
		if player ~= nil then
			replayFix:fixPlayerInfo(curFrame, player)
			replayFix:fixDeadInfo(curFrame, player)
		end
	end

	for i=self.all_list.Count,1,-1 do
		local player = self.all_list:get(i-1)
		if player ~= nil then
			replayFix:fixPlayerInfo(curFrame, player)
			replayFix:fixDeadInfo(curFrame, player)
		end
	end

	for i = 1, self.hide_table.list.Count do
		local instanceId = self.hide_table.list:get(i-1)
		local ply = self.hide_table:get(instanceId)
		if ply ~= nil and ply.animator ~= nil then
			replayFix:fixPlayerInfo(curFrame, ply)
			replayFix:fixDeadInfo(curFrame, ply)
		end
	end
end

--function M:updateAlways(dt)
--	for i=self.hero_list.Count,1,-1 do
--		local player = self.hero_list:get(i-1)
--		if player:isDestroy() then
--			self.hero_list:removeAt(i-1)
--		else
--			player:updateAlways(dt)
--		end
--	end
--	
--	for i=self.enemy_list.Count,1,-1 do
--		local player = self.enemy_list:get(i-1)
--		if player:isDestroy() then
--			self.enemy_list:removeAt(i-1)
--		else
--			player:updateAlways(dt)
--		end
--	end
--	
--	for i=self.summon_list.Count,1,-1 do
--		local player = self.summon_list:get(i-1)
--		if player:isDestroy() then
--			self.summon_list:removeAt(i-1)
--		else
--			player:updateAlways(dt)
--		end
--	end
--
--	for i = 1, self.hide_table.list.Count do
--		local instanceId = self.hide_table.list:get(i-1)
--		local ply = self.hide_table:get(instanceId)
--		ply:updateAlways(dt)
--	end
--
--	if self.relicMgr ~= nil then
--		self.relicMgr:update(dt)
--	end
--end


--function M:lateUpdate(dt,unsdt)
--	for i=self.hero_list.Count,1,-1 do
--		local player = self.hero_list:get(i-1)
--		if player:isDestroy() then
--			self.hero_list:removeAt(i-1)
--		else
--			if player.animator.mode == 0 then
--				player:lateUpdate(dt)
--			end
--		end
--	end
--	
--	for i=self.enemy_list.Count,1,-1 do
--		local player = self.enemy_list:get(i-1)
--		if player:isDestroy() then
--			self.enemy_list:removeAt(i-1)
--		else
--			if player.animator.mode == 0 then
--				player:lateUpdate(dt)
--			end
--		end
--	end
--
--	for i=self.summon_list.Count,1,-1 do
--		local player = self.summon_list:get(i-1)
--		if player:isDestroy() then
--			self.summon_list:removeAt(i-1)
--		else
--			if player.animator.mode == 0 then
--				player:lateUpdate(dt)
--			end
--		end
--	end
--
--	for i = 1, self.hide_table.list.Count do
--		local instanceId = self.hide_table.list:get(i-1)
--		local ply = self.hide_table:get(instanceId)
--		if ply.animator.mode == 0 then
--       	 ply:lateUpdate(dt)
--    	end
--	end
--end



--更新玩家
function M:update( dt )
	for i=self.hero_list.Count,1,-1 do
		local player = self.hero_list:get(i-1)
		if player ~= nil then
			if player:isDestroy() then
				self.hero_list:removeAt(i-1)
			else
				if player.animator ~= nil and player.animator.mode == 0 and player.plyState ~= 0 then
					player:update(dt)
				end
			end
		end
	end
	
	for i=self.enemy_list.Count,1,-1 do
		local player = self.enemy_list:get(i-1)
		if player ~= nil then
			if player:isDestroy() then
				self.enemy_list:removeAt(i-1)
			else
				if player.animator ~= nil and player.animator.mode == 0 and player.plyState ~= 0 then
					player:update(dt)
				end
			end
		end
	end

	for i = self.all_list.Count,1,-1 do
		local player = self.all_list:get(i-1)
		if player ~= nil then
			if player:isDestroy() then
				self.all_list:removeAt(i-1)
			end
		end
	end

	for i=self.summon_list.Count,1,-1 do
		local player = self.summon_list:get(i-1)
		if player ~= nil then
			if player:isDestroy() then
				self.summon_list:removeAt(i-1)
			else
				if player.animator ~= nil and player.animator.mode == 0 then
					player:update(dt)
				end
			end
		end
	end

	for i = 1, self.hide_table.list.Count do
		local instanceId = self.hide_table.list:get(i-1)
		local ply = self.hide_table:get(instanceId)
		if ply ~= nil and ply.animator ~= nil and ply.animator.mode == 0 then
			ply:update(dt)
		end
	end

	if self.attacker_relicMgr ~= nil then
		self.attacker_relicMgr:update(dt)
	end
	if self.defender_relicMgr ~= nil then
		self.defender_relicMgr:update(dt)
	end

	-- 宠物更新
	self.attacker_petMgr:update(dt)
	self.defender_petMgr:update(dt)
	
	if SceneManager.curScene.sceneId ~= SceneManager.SceneID.QiMenDunJiaScene and SceneManager.curScene.sceneId ~= SceneManager.SceneID.PetHallScene then
		self:checkAroundPlayer(dt);
	end
	
	if self.scene.checkEnemyRefresh ~= nil then
		self.scene:checkEnemyRefresh(dt)
	end
	--self:checkGameOver();
end

function M:checkGameOver()
	if SceneManager.curScene.sceneId == SceneManager.SceneID.FightScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.BossScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.ActiveBossScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.HeroTrainScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.TianjiLouFightScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.MiGongFightScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.WuXingZhenFightScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.UnionBossScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.LegendScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.GhostsShowSkillScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.GuJianQiTanFightScene then
			
			local heroCount = self:getPlayerCount(self.hero_list)
			local enemyCount = self:getPlayerCount(self.enemy_list)
			for i = 1, self.hide_table.list.Count do
				local instanceId = self.hide_table.list:get(i-1)
				local ply = self.hide_table:get(instanceId)
				if ply ~= nil then
					if ply:get_camp() == 1 then
						heroCount = heroCount + 1
					else
						enemyCount = enemyCount + 1
					end
				end
			end
			if SceneManager.curScene.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
				if heroCount == 0 then
					self.scene:gameOver(0)
					self.gamestart = false
					--敌人列表
				elseif enemyCount == 0 then
					self.scene:gameOver(1)
					self.gamestart = false
				end
			end
	end
end


function M:getPlayersNoDead(list)
	local live_player = Battle.List.new()
	for i = 1, list.Count do
		local ply = list:get(i - 1)
		if ply:isRealDead() == false and ply.master == nil then
			live_player:add(ply)
		end
	end
	return live_player;
end


function M:getPlayerCount(list)
	local count = 0
	for i = 1, list.Count do
		local ply = list:get(i - 1)
		if ply:isRealDead() == false and ply.master == nil then
			count = count + 1
		end
	end
	return count
end

function M:checkAroundPlayer( dt )
	if SceneManager.curScene.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
		local time = dt
		----我的队友
		local alls = self:getPlayers(0)
		local curPlayer = nil
		for i = 1, alls.Count - 1 do
			curPlayer = alls:get(i-1)
			if curPlayer.master == nil then
				for j = i+1, alls.Count do
					local otherPly = alls:get(j-1)
					if otherPly.master == nil then
						if GlobalTools:CheckDistanceMinTwoPoint(curPlayer:get_position(),otherPly:get_position(),curPlayer.data.check_radius ) == false then
							local dir_ply = GlobalTools:Dir( curPlayer:get_position(), otherPly:get_position())
							local pos = curPlayer:get_position() + dir_ply * time;
							curPlayer:setPos( pos );
						end
					end
				end
			end
		end
	end
end


function M:startAiEngineAndAnimator(heroBuzhenMove, enemyBuzhenMove)
	local hero_move = heroBuzhenMove or false;
	for i=1,self.hero_list.Count do
		local player = self.hero_list:get(i-1)
		player:startAiEngineAndAnimator(hero_move)
	end

	local enemy_move = enemyBuzhenMove or false;
	for i=1,self.enemy_list.Count do
		local player = self.enemy_list:get(i-1)
		player:startAiEngineAndAnimator(enemy_move)
	end
	if self.attacker_petMgr and self.attacker_petMgr.curPet then
		self.attacker_petMgr.curPet:startAiEngineAndAnimator(heroBuzhenMove)
	end
	if self.defender_petMgr and self.defender_petMgr.curPet then
		self.defender_petMgr.curPet:startAiEngineAndAnimator(enemy_move)
	end
end


--根据 阵营去出生玩家 
function M:playerSpawnCamp( camp )
	if camp == 1 then
		for i=1,self.hero_list.Count do
			local player = self.hero_list:get(i-1)
			player:spawn()
		end	
	else
		for i=1,self.enemy_list.Count do
			local player = self.enemy_list:get(i-1)
			player:spawn()
		end
	end
end


--阵营加成
function M:checkArray(list, camp)
	local plyDataList = {}
	for i = 1, list.Count do
		if list:get(i - 1).master == nil then
			table.insert(plyDataList, list:get(i - 1).plyData)
		end
	end


	--普通加成，阴阵营加成，阵营1，阵营2, 元阵营加成
	--return 0, raceList[6] + 10, 0, 0, raceList[7] + 10
	local res1, res2, race1, race2 = GlobalTools:checkArray(plyDataList, camp)
	local common1 = Battle.BattleGlobalConfig.ARRAY_ADDITION[res1]
	local data1 = ConfigManager:getBattleCommonValueById(common1,{}, true)
	for i = 1, list.Count do
		local ply = list:get(i - 1)
		if ply.master == nil then
			if data1 ~= nil and data1[1] ~= nil and data1[2] ~= nil then
				ply.data.hp:addToMulList(data1[1])
				ply.data.atk:addToMulList(data1[2])
			end

			self:addRaceAddition(ply, res2)
			--self:addRaceAddition(ply, res3)
		end
	end
end

--- 检查阵营加成
---@param ply PlayerModel
function M:addRaceAddition(ply, res)
	res = res or 10
	if res >= 11 then
		local common2 = Battle.BattleGlobalConfig.ARRAY_ADDITION[11]
		local data2 = ConfigManager:getBattleCommonValueById(common2,0, true)
		ply.data.def:addToMulList(data2)
	end
	if res >= 12 then
		local common2 = Battle.BattleGlobalConfig.ARRAY_ADDITION[12]
		local data2 = ConfigManager:getBattleCommonValueById(common2,0, true)
		ply.data.hurtrageregen:addToAddList(data2)
	end
	if res >= 13 then
		local common2 = Battle.BattleGlobalConfig.ARRAY_ADDITION[13]
		local data2 = ConfigManager:getBattleCommonValueById(common2,0, true)
		ply.data.critrate_correct:addToAddList(data2)
	end
	if res >= 14 then
		local common2 = Battle.BattleGlobalConfig.ARRAY_ADDITION[14]
		local data2 = ConfigManager:getBattleCommonValueById(common2,0, true)
		ply.data.crit:addToAddList(data2)
	end
	if res >= 15 then
		local common2 = Battle.BattleGlobalConfig.ARRAY_ADDITION[15]
		local data2 = ConfigManager:getBattleCommonValueById(common2,{}, true)
		if data2[1] ~= nil then
			ply.data.haste:addToAddList(data2[1])
		end
		if data2[2] ~= nil then
			ply.data.atk:addToMulList(data2[2])
		end
	end
end

--五行阵加成
function M:checkFiveElement(myType)
	if myType ~= nil and type(myType) == "table" then
		--local fiveElement = ConfigManager:getCfgByName("five_element_allelopathy")
		--local elementTable = {}
		--for k,v in ipairs(fiveElement) do
		--	elementTable[v.enemy_type] = v.param2
		--end
		--local elementData = {}
		--for k,v in pairs(myType) do
		--	table.insert(elementData, elementTable[v])
		--end
		--for i = 1, self.hero_list.Count do
		--	local player = self.hero_list:get(i - 1)
		--	player:fiveElement(elementData)
		--end
	end
end

--玩家出生
function M:playerSpawn(data)
	--重置召唤物id
	self.summon_index = 0
	self.blackScreenPlayerCamp = 0
	local enemy_dyns = {}
	local hero_dyns = {}
	if data ~= nil then
		enemy_dyns = data["defender_team"]["dyns"]
		hero_dyns = data["attacker_team"]["dyns"]
	end
	self:checkFiveElement(self.attacker_element)
	
	self:checkArray(self.enemy_list, -1)
	local start_players = {}
	for i=self.enemy_list.Count,1,-1 do
		local player = self.enemy_list:get(i-1)
		player:spawn(enemy_dyns[player:get_playerInstanceId()])
		table.insert(start_players, player)
	end
	
	self:checkArray(self.hero_list, 1)
	for i=self.hero_list.Count,1,-1 do
		local player = self.hero_list:get(i-1)
		player:spawn(hero_dyns[player:get_playerInstanceId()])
		table.insert(start_players, player)
	end

	-- 统一执行一遍天命化星，防止给队友加buff的时候，队友还没有出生
	for i, v in ipairs(start_players) do
		--天命化星 战斗开始
		if v.skyStar ~= nil then
			v.skyStar:gameStart()
		end
	end
	------------- 车轮战宠物血量怒气更新 Start -------------
	local pet_enemy_dyns = {}
	local pet_hero_dyns = {}
	if data ~= nil then
		pet_enemy_dyns = data["defender_team"]["pet_dyns"]
		pet_hero_dyns = data["attacker_team"]["pet_dyns"]
	end
	if self.attacker_petMgr.curPet then
		self.attacker_petMgr:spawn(pet_hero_dyns[self.attacker_petMgr.curPet:get_playerInstanceId()])
	else
		self.attacker_petMgr:spawn()
	end
	if self.defender_petMgr.curPet then
		self.defender_petMgr:spawn(pet_enemy_dyns[self.defender_petMgr.curPet:get_playerInstanceId()])
	else
		self.defender_petMgr:spawn()
	end
	------------- 车轮战宠物血量怒气更新 End -------------
	self.attacker_relicMgr:gameStart()
	self.defender_relicMgr:gameStart()

	if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR then
		for i=self.enemy_list.Count,1,-1 do
			local player = self.enemy_list:get(i-1)
			player:stageBattleInitBuff()
		end
		for i=self.hero_list.Count,1,-1 do
			local player = self.hero_list:get(i-1)
			player:stageBattleInitBuff()
		end
	end

	--模拟服务器数据
	if SceneManager.curScene.sceneId == SceneManager.SceneID.FightScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.BossScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.ActiveBossScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.HeroTrainScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.TianjiLouFightScene or 
			SceneManager.curScene.sceneId == SceneManager.SceneID.MiGongFightScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.WuXingZhenFightScene or
			SceneManager.curScene.sceneId == SceneManager.SceneID.GuJianQiTanFightScene	then
		SceneManager.curScene.gameover = false;
	end

	self:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerPlayerSpawn, data);
end


function M:SetAutoFight( value )
	self.isAutoFight = value
	if SceneManager:getCurSceneModel().tongjiData ~= nil then
		SceneManager:getCurSceneModel().tongjiData:addAutoFightOperation(self.isAutoFight);
		--设置自动战斗时候立刻放大，但是这里可能会导致不同步
		--if value == true then
		--	for i=1,self.hero_list.Count do
		--		local player = self.hero_list:get(i-1)
		--		if player ~= nil then
		--			player:useSkill("skill3")
		--		end
		--	end
		--end
	end
end


--胜利返回1，失败返回0
function M:gameover(re)
	if self.blackTimeManager ~= nil then
		if self.blackTimeManager.gameOver then
			self.blackTimeManager:gameOver()
		else
			self.blackTimeManager:overBlackTime()
			self.blackTimeManager.curBlackTime = 0
		end
	end
	self.attacker_relicMgr:gameover()
	self.defender_relicMgr:gameover()

	for i=1,self.enemy_list.Count do
		local player = self.enemy_list:get(i-1)
		if player ~= nil then
			player:gameover(re)
		end
	end

	for i=1,self.hero_list.Count do
		local player = self.hero_list:get(i-1)
		if player ~= nil then
			player:gameover(re)
		end
	end
	for i=1,self.summon_list.Count do
		local player = self.summon_list:get(i-1)
		if player ~= nil then
			player:gameover(re)
		end
	end
	--游戏结束
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerGameOver, {result = re})
end

--战斗开始
function M:startBattle()
	self.attacker_relicMgr:spawnFinish()
	self.defender_relicMgr:spawnFinish()
	--重新排序
	local hero_list_temp = Battle.List.new()
	local hero_sendFor_list = Battle.List.new()
	for i = 1, self.hero_list.Count do
		local ply = self.hero_list:get(i - 1)
		if ply ~= nil and ply.master ~= nil then
			hero_sendFor_list:add(ply);
		end
	end
	for i = 1, 5 + hero_sendFor_list.Count do
		local ply = self:getHeroByIndex(i-1)
		if ply ~= nil then
			hero_list_temp:add(ply);
		end
	end
	for i = 1, hero_sendFor_list.Count do
		local ply = hero_sendFor_list:get(i - 1)
		if ply ~= nil  then
			hero_list_temp:add(ply);
		end
	end
	
	local enemy_list_temp = Battle.List.new()
	local enemy_sendFor_list = Battle.List.new()
	for i = 1, self.enemy_list.Count do
		local ply = self.enemy_list:get(i - 1)
		if ply ~= nil and ply.master ~= nil then
			enemy_sendFor_list:add(ply);
		end
	end
	for i = 1, 20 + enemy_sendFor_list.Count do
		local ply = self:getEnemyByIndex(i-1)
		if ply ~= nil then
			enemy_list_temp:add(ply);
		end
	end
	for i = 1, enemy_sendFor_list.Count do
		local ply = enemy_sendFor_list:get(i - 1)
		if ply ~= nil  then
			enemy_list_temp:add(ply);
		end
	end
	
	self:clear()
	--self.enemy_list:clear()
	self.enemy_list = enemy_list_temp;
	--self.hero_list:clear()
	self.hero_list = hero_list_temp;
	
	for i=1,self.enemy_list.Count do
		local player = self.enemy_list:get(i-1)
		if player ~= nil then
			--所有数据重新设置
			player:resetAllData();
			player.plyInBattle = true;
		end
	end

	local total_level = 0
	for i=1,self.hero_list.Count do
		local player = self.hero_list:get(i-1)
		if player ~= nil then
			---TODO player.data.level 人物等级压制计算没有转定点数导致等级压制不生效
			total_level = total_level + player.data.level
			--所有数据重新设置
			player:resetAllData();
			player.plyInBattle = true;
		end
	end
	--平均等级
	self.averageLevel = GlobalTools:Div(total_level,GlobalTools.base5 )
	
	for i=1,self.enemy_list.Count do
		local player = self.enemy_list:get(i-1)
		if player ~= nil then
			if player.mysticMgr ~= nil then
				player.mysticMgr:spawnFinish()
			end
			if player.talismanMgr ~= nil then
				player.talismanMgr:spawnFinish()
			end
			player.plySkill:spawnFinish()
		end
	end

	for i=1,self.hero_list.Count do
		local player = self.hero_list:get(i-1)
		if player ~= nil then
			if player.mysticMgr ~= nil then
				player.mysticMgr:spawnFinish()
			end
			if player.talismanMgr ~= nil then
				player.talismanMgr:spawnFinish()
			end
			player.plySkill:spawnFinish()
		end
	end

	if self.attacker_petMgr:hasPet() then
		local attacker_pet = self.attacker_petMgr:getCurPet()
		attacker_pet:resetAllData();
	end
	
	if self.defender_petMgr:hasPet() then
		local defender_pet = self.defender_petMgr:getCurPet()
		defender_pet:resetAllData();
	end

	self:openingSkill()
	--通知视图层开始战斗
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerStartBattle)
end

---@return PetManager
function M:getPetMgr(camp)
	if camp == 1 then
		return self.attacker_petMgr
	else
		return self.defender_petMgr
	end
end

function M:openingSkill()
	self.openingSkillFinish = false

	local has_openingSkill = false
	for i=1,self.enemy_list.Count do
		local player = self.enemy_list:get(i-1)
		if player ~= nil and player.plySkill:checkOpening() == true then
			has_openingSkill = true
			break
		end
	end

	if has_openingSkill == false then
		for i=1,self.hero_list.Count do
			local player = self.hero_list:get(i-1)
			if player ~= nil and player.plySkill:checkOpening() == true then
				has_openingSkill = true
				break
			end
		end
	end

	if has_openingSkill == true then
		TimeTools:delayTime(GlobalTools.base0_1, function()
			self.openingSkillFinish = true
		end)
	else
		self.openingSkillFinish = true
	end
end

---@return Battle_List
function M:getPlayers( camp )
	local players = nil
	if camp == 1 then
		players = self.hero_list
	elseif camp == -1 then
		players = self.enemy_list
	else
		players = self.all_list
	end
	return players
end

---@return Battle_ListMap
function M:getHidePlayers()
	local players = self.hide_table
	return players
end

--通过index找敌人
function M:getEnemyByIndex( index )
	for i = 1, self.enemy_list.Count do
		local player = self.enemy_list:get(i-1)
		if player.master == nil and player.index == index then
			return player
		end
	end
	return nil
end


--通过 玩家id 找敌人
function M:getPlayerByPlayerID( playerId, camp )
	if camp == 1 then
		for i = 1, self.hero_list.Count do
			local player = self.hero_list:get(i-1)
			if player.playerId == playerId then
				return player
			end
		end
	else
		for i = 1, self.enemy_list.Count do
			local player = self.enemy_list:get(i-1)
			if player.playerId == playerId then
				return player
			end
		end
	end
	return nil
end


--通过位置获取英雄
function M:getHeroByIndex( index )
	for i = 1, self.hero_list.Count do
		local player = self.hero_list:get(i-1)
		if player.master == nil and player.index == index then
			return player
		end
	end
	return nil
end


---@return PlayerModel 通过实例id去找玩家
function M:getPlayerByInstanceId( instanceId )
	for i = 1, self.hero_list.Count do
		local player = self.hero_list:get(i-1)
		if player:get_playerInstanceId() == instanceId then
			return player
		end
	end
	for i = 1, self.enemy_list.Count do
		local player = self.enemy_list:get(i-1)
		if player:get_playerInstanceId() == instanceId then
			return player
		end
	end

	for i = 1, self.hide_table.list.Count do
		local plyInstanceId = self.hide_table.list:get(i-1)
		if plyInstanceId == instanceId then
			return self.hide_table:get(instanceId)
		end
	end
	
	for i = 1, self.summon_list.Count do
		local player = self.summon_list:get(i-1)
		if player:get_playerInstanceId() == instanceId then
			return player
		end
	end
	return nil
end

--返回密集区的中心玩家
function M:DenseareaPlayer(radius, camp)
	camp = camp or 1
	local ply_hero = nil
	local friend = nil
	local all_players = self:getPlayers(camp)
	local players = {}
	for i = 1, all_players.Count,1 do
		friend = all_players:get(i-1) 
		local players_temp = {}
		table.insert(players_temp, friend)
		for j = 1, all_players.Count,1 do
			ply_hero = all_players:get(j-1)
			if friend:equal(ply_hero) ~= true then
				local distance = GlobalTools:Distance(friend.position, ply_hero.position)
				if distance <= GlobalTools:ToFix2(radius) then
					table.insert(players_temp, ply_hero)
				end
			end
		end
		if #players_temp > #players then
			players = players_temp 		
		end
	end
	return players
end


--创建AI
---@return AIEngine
function M:createAI( aiName )
	local aiCls = require("Battle.SM.Ai."..aiName)
	local aiIns = aiCls.new()
	return aiIns
end

--暂停
function M:pause()
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerPause);
end

--继续
function M:continue()
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerContinue);
end

-- ********************************************************************
-- 黑屏处理
-- ********************************************************************

--开始设定黑屏的时候做的处理
function M:startBlackTimeHandler()
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerBlackScreen,{type = 0})
	--场景速度设置成1
	TimeManager:set_timeScale(GlobalTools.base0);
	--SceneManager:getCurSceneModel():pause();
end

--重新设置黑屏
function M:resetBlackTimeHandler()
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerBlackScreen,{type = 1})
end

--黑屏结束处理
function M:overBlackTimeHandler()
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerBlackScreen,{type = 2})
	--场景速度设置成1
	TimeManager:set_timeScale(GlobalTools.base1);
	--SceneManager:getCurSceneModel():continue()
end

function M:getSummonIndex()
	self.summon_index = self.summon_index + 1
	return self.summon_index
end

function M:setLostHpData(player, totalLostHp, totalLostHpFix)
	if player:get_playerInstanceId() ~= nil then
		local list, listFix = nil
		if player:get_camp() == 1 then
			list = self.herolostHplist
			listFix = self.herolostHplistFix
		else
			list = self.enemylostHplist
			listFix = self.enemylostHplistFix
		end
		list[player:get_playerInstanceId()] = totalLostHp
		listFix[player:get_playerInstanceId()] = totalLostHpFix
	end
end

--销毁所有玩家 
function M:destroy(isDestoryObj)
	--self:dumpAllPlayer("destroy")
	--self.isAutoFight = false
	self:destroyAllPlayer(isDestoryObj)
	if self.attacker_relicMgr ~= nil then
		self.attacker_relicMgr:destroy()
	end
	if self.defender_relicMgr ~= nil then
		self.defender_relicMgr:destroy()
	end

	-- 宠物销毁
	if self.attacker_petMgr ~= nil then
		self.attacker_petMgr:destroy(isDestoryObj)
	end
	if self.defender_petMgr ~= nil then
		self.defender_petMgr:destroy(isDestoryObj)
	end
	
	if self.blackTimeManager ~= nil then
		if self.blackTimeManager.destroy ~= nil then
			self.blackTimeManager:destroy()
		else
			self.blackTimeManager:overBlackTime()
			self.blackTimeManager.curBlackTime = 0
		end
	end
	self:clear()
	--发送销毁事件
	self:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerDestroy);
end

function M:dumpAllPlayer(tag)
	local msg =  "AllPlayers:" .. tostring(tag) .. "\n"
	for i = self.summon_list.Count, 1, -1 do
		local ply = self.summon_list:get(i-1)
		if ply then
			msg = msg .. "\t\tsummon:" .. ply.plyType .. " " .. ply.camp .. "\n"
		end
	end

	for i = self.hide_table.list.Count, 1, -1 do
		local instanceId = self.hide_table.list:get(i-1)
		local ply = self.hide_table:get(instanceId)
		if ply ~= nil then
			msg = msg .. "\t\thide:" .. instanceId .. "  " .. ply.plyType .. " " .. ply.camp .. "\n"
		end
	end

	for i = self.hero_list.Count, 1, -1 do
		local ply = self.hero_list:get(i-1)
		if ply ~= nil then
			msg = msg .. "\t\thero_list:" .. ply.plyType .. " " .. ply.camp .. "\n"
		end
	end

	for i = self.enemy_list.Count, 1, -1 do
		local ply = self.enemy_list:get(i-1)
		if ply ~= nil then
			msg = msg .. "\t\tenemy_list:" .. ply.plyType .. " " .. ply.camp .. "\n"
		end
	end
	Logger.log(msg)
end

return M
