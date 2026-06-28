---@class PlayerManager_View : ViewBase @玩家管理类
---@field enemy_list Battle_List
---@field hero_list Battle_List
local M = class("PlayerManager_View",Battle.ViewBase)

--敌人列表
M.enemy_list = nil

--英雄的列表
M.hero_list= nil

--召唤物的列表
M.summon_list= nil

--玩家管理器所在的scene 
M.scene = nil

-- 攻击方宠物
M.attacker_pet = nil
-- 防守方宠物
M.defender_pet = nil

--我方英雄斗气
-- M.heroFightScore = nil

-- --敌人英雄斗气
-- M.enemyFightScore = nil

--玩家技能配置信息
M.playerSkillConfig = nil

M.gamestart = false

M.spawnCount = 0

--玩家管理初始化
---@param model PlayerManager_Model
---@param scene Scene_View
function M:start( scene, model )
	self.model = model;
	self.scene = scene
	-- 通过 数据来获取视图
	-- 敌人视图类
	self.modelToView_enemy = {}
	-- 我方视图类
	self.modelToView_hero = {}
	-- 敌人列表
	self.enemy_list = Battle.List.new()
	-- 我方列表
	self.hero_list = Battle.List.new()
	-- 战斗显示范围
	self.rangeShow = require("BattleView.Ply.PlayerRangeShow").new()
	self.rangeShow:init(self)
	--玩家数据层创建成功
	self:addEventListener_Local(Battle.EventType.MV_PlayerModelCreateFinish, {self, self.MV_PlayerModelCreateFinish})
	--玩家出生通知视图层
	self:addEventListener_Local(Battle.EventType.MV_PlayerManagerPlayerSpawn, {self, self.MV_PlayerManagerPlayerSpawn})
	--管理器销毁通知
	self:addEventListener_Local(Battle.EventType.MV_PlayerManagerDestroy, {self, self.MV_PlayerManagerDestroy})
	--黑屏处理
	self:addEventListener_Local(Battle.EventType.MV_PlayerManagerBlackScreen, {self, self.MV_PlayerManagerBlackScreen})
	--战斗开始
	self:addEventListener_Local(Battle.EventType.MV_PlayerManagerStartBattle, {self, self.MV_PlayerManagerStartBattle})
	--重新设定玩家位置 
	self:addEventListener_Local(Battle.EventType.MV_PlayerManagerResetPlayerPosition, {self,self.MV_PlayerManagerResetPlayerPosition})
	--暂停游戏
	self:addEventListener_Local(Battle.EventType.MV_PlayerManagerPause,{self,self.MV_PlayerManagerPause})
	--继续游戏
	self:addEventListener_Local(Battle.EventType.MV_PlayerManagerContinue,{self,self.MV_PlayerManagerContinue})
	--游戏结束
	self:addEventListener_Local(Battle.EventType.MV_PlayerManagerGameOver, {self,self.MV_PlayerManagerGameOver})

	self:addEventListener_Local(Battle.EventType.MV_TeamModelCreateFinish, {self, self.MV_TeamModelCreateFinish})
end


--游戏结束
function M:MV_PlayerManagerGameOver(eventName, data)
	self:gameover( data.result );
end

--暂停游戏
function M:MV_PlayerManagerPause()
	self:pause();
end

--继续游戏
function M:MV_PlayerManagerContinue()
	self:continue()
end

--重新设定位置
function M:MV_PlayerManagerResetPlayerPosition(eventName, data)
	self:resetPlayerPosition();
end

--开始战斗
function M:MV_PlayerManagerStartBattle(eventName, data) 
	self:startBattle();
end


function M:MV_PlayerManagerBlackScreen(eventName, data)
	if data.type == 0 then
		self:startBlackTimeHandler();
	elseif data.type == 1 then
		self:resetBlackTimeHandler();
	elseif data.type == 2 then
		self:overBlackTimeHandler();
	end
end

--清空存储
function M:MV_PlayerManagerDestroy(eventName, data)
	self.modelToView_hero = {}
	self.modelToView_enemy = {}
end

--玩家的数据层创建完成
function M:MV_PlayerModelCreateFinish( eventName, data )

	--Logger.logError("<[PlayerManager_View]> 玩家 数据层和视图事件绑定完成 ")
	local player_model = data;
	local createData = {}
	--PlayerManager 管理器
	createData.plyMgr = self;
	createData.parent = self.scene.obj;
	createData.model = player_model;
	local player_view = require("BattleView.Ply.Player_View").new()
	--绑定 Player_Model 和 Player_View 以事件绑定
	SceneManager.MV_EventMgr:register(player_view, player_model);
	player_view:init(createData)
	--加入视图列表
	if player_model:get_camp() == 1 then
		if player_model.playerType == "pet" then
			self.attacker_pet = player_view
		else
			self.hero_list:add(player_view);
		end
		self.modelToView_hero[player_model] = player_view;
	else
		if player_model.playerType == "pet" then
			self.defender_pet = player_view
		else
			self.enemy_list:add(player_view);
		end
		self.modelToView_enemy[player_model] = player_view;
	end
end

---@param teamModel Team_Model
function M:MV_TeamModelCreateFinish(eventName, teamModel)
	local teamView = require("BattleView.Ply.Team_View").new()
	SceneManager.MV_EventMgr:register(teamView, teamModel);
	teamView:init(self, teamModel)
	if teamModel.camp == 1 then
		self.attackerTeam = teamView
	else
		self.defenderTeam = teamView
	end
end

--数据层 通知 视图层 玩家出生
function M:MV_PlayerManagerPlayerSpawn( eventName, data )
	self:playerSpawn(data);
end

--销毁 Player
function M:destroyPlayer( player_model )
	if player_model:get_camp() == 1 then
		if table.existkey(self.modelToView_hero, player_model ) then
			local player_view = self.modelToView_hero[player_model];
			if self.attacker_pet and player_model.playerType == "pet" then
				self.attacker_pet = nil
			else
				self.hero_list:remove(player_view);
			end
			self.modelToView_hero[player_model] = nil;
		end
		
	else
		if table.existkey(self.modelToView_enemy, player_model ) then
			local player_view = self.modelToView_enemy[player_model];
			if self.defender_pet and player_model.playerType == "pet" then
				self.defender_pet = nil
			else
				self.enemy_list:remove(player_view);
			end
			self.modelToView_enemy[player_model] = nil;
		end
	end
end


--通过实例id去找玩家
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

	-- 通过id获取宠物
	if self.attacker_pet and self.attacker_pet:get_playerInstanceId() == instanceId then
		return self.attacker_pet
	end
	if self.defender_pet and self.defender_pet:get_playerInstanceId() == instanceId then
		return self.defender_pet
	end
	return nil
end

--通过 玩家id 找敌人
function M:getPlayerByPlayerID( playerId, camp )
	if camp == 1 then
		for i = 1, self.hero_list.Count do
			local player = self.hero_list:get(i-1)
			if player.model.playerId == playerId then
				return player
			end
		end
	else
		for i = 1, self.enemy_list.Count do
			local player = self.enemy_list:get(i-1)
			if player.model.playerId == playerId then
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


--通过数据获取玩家
---@param player_model PlayerModel
---@return Player_View
function M:GetPlayerViewByModel( player_model )
	if player_model:get_camp() == 1 then
		if table.existkey(self.modelToView_hero, player_model ) then
			local player_view = self.modelToView_hero[player_model];
			return player_view;
		end

	else
		if table.existkey(self.modelToView_enemy, player_model ) then
			local player_view = self.modelToView_enemy[player_model];
			return player_view;
		end
	end
	return nil;
end

--玩家出生
function M:playerSpawn(data)
	
end

--处理脚底UI
function M:HandleFootUI()
	for i = 1,self.hero_list.Count do
		local ply = self.hero_list:get(i-1);
		if ply ~= nil then
			ply:MakeFootUI()
		end
	end
	for i = 1,self.enemy_list.Count do
		local ply = self.enemy_list:get(i-1);
		if ply ~= nil then
			ply:MakeFootUI()
		end
	end
	if self.attacker_pet ~= nil then
		self.attacker_pet:MakeFootUI()
	end
	if self.defender_pet ~= nil then
		self.defender_pet:MakeFootUI()
	end
end

--重新设定玩家位置 
function M:resetPlayerPosition()
	for i=1, 5 do
		local pos = self.scene:findSpawnPosition(1, i-1)
		local standEffect = self.scene.scene_view.standEffect_hero:get(i-1)
		if standEffect ~= nil then
			local pos_trans = standEffect.transform.position;
			pos_trans.x = pos.x;
			pos_trans.z = pos.z;
			standEffect.transform.position = pos_trans;
		end
	end

	for i=1, 5 do
		local pos = self.scene:findSpawnPosition(-1, i-1)
		local standEffect = self.scene.scene_view.standEffect_enemy:get(i-1)
		if standEffect ~= nil then
			local pos_trans = standEffect.transform.position;
			pos_trans.x = pos.x;
			pos_trans.z = pos.z;
			standEffect.transform.position = pos_trans;
		end
	end
end

function M:view_update(dt, unsdt)
	for i = self.hero_list.Count,1,-1 do
		self.hero_list:get(i-1):view_update(dt, unsdt)
	end
	for i = self.enemy_list.Count,1,-1 do
		self.enemy_list:get(i-1):view_update(dt, unsdt)
	end

	if self.rangeShow ~= nil then
		self.rangeShow:update(dt);
	end
end

--返回密集区的中心玩家
function M:DenseareaPlayer(radius, camp)
	camp = camp or 1
	local ply_hero = nil
	local friend = nil
	local all_players = self:getPlayers(camp)
	local players = {}
	radius = GlobalTools:ToFloat(radius)

	for i = 1, all_players.Count,1 do
		friend = all_players:get(i-1)
		local players_temp = {}
		table.insert(players_temp, friend)
		for j = 1, all_players.Count,1 do
			ply_hero = all_players:get(j-1)
			if friend:equal(ply_hero) ~= true then
				local vec_cha = friend:get_position() - ply_hero:get_position();
				local distance = vec_cha:SqrMagnitude();
				if distance <= radius * radius then
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

function M:resetObj( obj )
	for i = 1,self.model.hero_list.Count do
		self.model.hero_list:get(i-1):setParent(obj)
	end
	for i = 1,self.model.enemy_list.Count do
		self.model.enemy_list:get(i-1):setParent(obj)
	end
end

--获取 Player_Vieww
function M:getPlayers( camp )
	if camp == 1 then
		return self.hero_list;
	else
		return self.enemy_list;
	end
end

--战斗开始
function M:startBattle()
	for i=1,self.enemy_list.Count do
		local player = self.enemy_list:get(i-1)
		if player ~= nil then
			player:ShowHpBar(true)
		end
	end
	for i=1,self.hero_list.Count do
		local player = self.hero_list:get(i-1)
		if player ~= nil then
			player:ShowHpBar(true)
		end
	end
	
	--这里会影响一开始不放大招问题
	--自动战斗
	if SceneManager.curScene.mode ~= nil then
		if GlobalConfig.BATTLE_MODE_CFG[SceneManager.curScene.mode].pvp == false then
			local auto = UserDataManager.local_data:getUserDataByKey("combat_auto", 1)
			if SceneManager:getCurSceneModel().m_replay == false and SceneManager:getCurSceneModel().checkBattle ~= 1 then
				self.model:SetAutoFight(auto == 1)
			end
		end
	end

	if UserDataManager.guide_data:isGuiding() then
		local info = UserDataManager.guide_data:getCurGuideInfo()
		if info and info.key == "GamePanel" and info.action == 4 then
			self.model:SetAutoFight(false)
		end
	end
end

function M:gameover()
	
end

function M:destroy()
	self.hero_list:clear();
	self.enemy_list:clear();
	if self.rangeShow ~= nil then
		self.rangeShow:destroy()
		self.rangeShow = nil
	end
	self.attacker_pet = nil
	self.defender_pet = nil
end

--重新设置 UnScale
function M:resetPlayerUnScale()
	--还原所有玩家
	local hero = self.model.hero_list
	for i = 1, hero.Count do
		local ply = hero:get(i - 1)
		ply:setUnScale(false)
	end
	local enemy = self.model.enemy_list
	for i = 1, enemy.Count do
		local ply = enemy:get(i - 1)
		ply:setUnScale(false)
	end
end

--所有玩家暂停
function M:pause()
	for i=1,self.model.hero_list.Count do
		local ply = self.model.hero_list:get(i-1);
		ply:pause();
	end

	for i=1,self.model.enemy_list.Count do
		local ply = self.model.enemy_list:get(i-1);
		ply:pause();
	end
end

--所有玩家继续
function M:continue()
	for i=1,self.model.hero_list.Count do
		local ply = self.model.hero_list:get(i-1);
		ply:continue();
	end
	for i=1,self.model.enemy_list.Count do
		local ply = self.model.enemy_list:get(i-1);
		ply:continue();
	end
end

-- ********************************************************************
-- 黑屏处理
-- ********************************************************************

--开始设定黑屏的时候做的处理
function M:startBlackTimeHandler()
	--设置TweenTool的运行变成unscale的 
	U3DUtil:SetUnScale(true)
	--摄像机变黑
	SceneManager:getCurSceneView().cameraController:BlackScreen(true);
end


function M:resetBlackTimeHandler()
	self:overBlackTimeHandler();
end


--黑屏结束处理
function M:overBlackTimeHandler()
	--设置TweenTool的运行变成scale的 
	U3DUtil:SetUnScale(false)
	--摄像机恢复
	if SceneManager:getCurSceneView().cameraController ~= nil then
		SceneManager:getCurSceneView().cameraController:BlackScreen(false);
	end

	for i=1,self.model.hero_list.Count do
		local ply = self.model.hero_list:get(i-1);
		ply:setLayer(false);
	end
	for i=1,self.model.enemy_list.Count do
		local ply = self.model.enemy_list:get(i-1);
		ply:setLayer(false);
	end
	if self.model.summon_list ~= nil then
		for i=1,self.model.summon_list.Count do
			local ply = self.model.summon_list:get(i-1);
			ply:setLayer(false);
		end
	end
end

function M:removePetPowerItem()
	for i=self.enemy_list.Count,1,-1 do
		local player = self.enemy_list:get(i-1)
		player:removeLightEffect()
	end

	for i=self.hero_list.Count,1,-1 do
		local player = self.hero_list:get(i-1)
		player:removeLightEffect()
	end
end
-- 展示宠物血条
function M:showPetHpNode()
	for i=self.enemy_list.Count,1,-1 do
		local player = self.enemy_list:get(i-1)
		player:showPetHpNode()
	end

	for i=self.hero_list.Count,1,-1 do
		local player = self.hero_list:get(i-1)
		player:showPetHpNode()
	end
end


return M