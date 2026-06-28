--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-03 09:32:16
]]

local SceneManager = SceneManager
local tonumber = tonumber

--挂机场景
---@class LegendFightScene_Model : SceneArrayBase_Model @
---@field super SceneArrayBase_Model @SceneArrayBase_Model
local M = class("LegendFightScene_Model",Battle.SceneArrayBase_Model)

--初始化场景
function M:init()
	M.super.init(self)
	self.use_hov = true;
	self.killNum = 0
	self.legendNextRefreshTime = nil
	--江湖传说敌人刷新次数
	self.legend_refresh_count = 0
	--江湖传说boss刷新序号
	self.legend_boss_index = 1
	self.buffCount = 0
	self.enemy_refresh_count = 0
	self.boss_refresh_count = 0
	
	self.refreshTime = GlobalTools.base1
	self.curRefreshTime = self.refreshTime;
	
	self.legend_stage_table = ConfigManager:getCfgByName("legend_stage");
	self.legend_table = ConfigManager:getCfgByName("legend");
	
	self.leaveFieldEnemies = {}		-- 离场的敌人
	self.playerIdPrefab = {}
end


--进入场景
function M:enter(data)
	self:clearCacheData()
	self.curRefreshTime = self.refreshTime;
	self.legend_stage_cfg = self.legend_stage_table[data.legend_stage_id]
	M.super.enter(self, data)
	EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
	EventDispatcher:registerEvent("leave_battlefield", {self,self.leaveFieldHandler})
	LODUtil:recordLodLevel();
	CS.wt.framework.AssetLoaderHelper.Inst:SetEffectLOD(0);
	LODUtil:setShaderLOD(0)
end

--加载完成
function M:loadFinish( data )
	M.super.loadFinish(self, data)
	if self.isDestoryMe then
		return;
	end
	SelectTargetTool:resetFixPoint()

	--游戏结束
    self.gameover = true
    --初始化阶段
	self:set_sceneState(0)
end

--子类重写
function M:getCurSceneName()
	return "legend";
end

--子类重写
function M:getCurCameraInfoName()
	local scene_name = self:getCurSceneName()
	return scene_name..self.legend_stage_cfg.type
end

--场景文件
function M:getCurSceneObjName()
	return "fightscene_data_w"
end

function M:readyBattleData( data )
	M.super.readyBattleData(self, data)
	local legend = self.legend_table[self.m_legend_sort]
	local time = legend.stage_time
	if time <= 0 then
		time = 99999
	end
	self:setBattleTime(time)
end

function M:setBattleTime(time)
	self.maxTime = GlobalTools:ToFix(time)
end

--加载场景
function M:loadScene( data )
	M.super.loadScene(self)
	self:loadSceneItem()
end

--加载美术场景
function M:loadSceneItem()
    M.super.loadSceneItem( self )
    if self.obj ~= nil then
        --场景的根节点
        self.guide = nil
        self.sceneRoot = self.obj.transform:Find("Scene_Root")
		self.gridRoot = self.obj.transform:Find("gridRoot");
		self:setSceneInstancePosition(false);
	end
end

--获取玩家位置
function M:get_heroPosList()
	local type = self.legend_stage_cfg.type
	if type == 1 then
		return self.heroPos1list
	elseif type == 2 then
		return self.heroPos2list
	end
end

--获取敌人位置
function M:get_enemyPosList()
	local type = self.legend_stage_cfg.type
	if type == 1 then
		return self.enemyPos1list
	elseif type == 2 then
		return self.enemyPos2list
	end
end

--@camp: 阵营 1 己方， 其他为敌人
--@index: 位置序号
--返回值为定点数
function M:findSpawnPosition(camp, index)
	local type = self.legend_stage_cfg.type
	if index >= 0 then
		local posList = nil
		if camp == 1 then
			posList = self["heroPos"..type.."list"]
		else
			posList = self["enemyPos"..type.."list"]
		end
		if posList and posList.Count > index then
			return posList:get(index)
		else
			return FixVector3.New(0,0,0)
		end
	else
		return FixVector3.New(0,0,0)
	end
end

--创建敌人队伍Target
--是否是布阵创建人物
function M:createLegendEnemyTeam(legend_battle_id)
	self:clearCacheData()	-- 不记录之前的缓存
	local legend_stage_tab = ConfigManager:getCfgByName("legend_stage")
	local stage_data = legend_stage_tab[legend_battle_id]
	if stage_data then
		local prefabUseCnt = {}
		local monsters = stage_data["enemy"]
		for k,v in pairs(monsters) do
			local playerData = {
				["id"]=v,
				["iid"]=0,
				["lv"]=1,
				["evo"]=1,
				["buffs"]={},
				["attrs"]={},
				["equips"]={},
			}
			
			local player = self.plyMgr:createPlayer(playerData,-1,k-1, nil,nil)
			player.canRelive = true
			player.data:set_evo( playerData.evo );
			local prefabName = player:get_prefabName()
			self.playerIdPrefab[v] = prefabName
			prefabUseCnt[prefabName] = (prefabUseCnt[prefabName] or 0) + 1
			if self.legend_stage_cfg.type == 1 then
				player.plySkill:lockSkill({"attack1"})
			end
		end
		
		--英雄表的数据
		--每个 敌方英雄都创建 10个预备着
		for k, v in pairs(prefabUseCnt) do
			for i = 1, v*10 do
				ResourceUtil:LoadRole3dAsync(k, nil, function(obj)
					ResourceUtil:ReturnItem(obj)
				end)
			end
		end

		for i = 1, 50 do	-- 死亡特效
			ResourceUtil:LoadCommonEffectAsync("Skill_Die_001", nil, function(obj)
				ResourceUtil:ReturnItem(obj)
			end)
		end
	else
		Logger.logError(legend_battle_id, "stage_battle not found id => ")
	end
	
	self:createEnemyFinish();
end

function M:playerSpawnHandler()
	M.super.playerSpawnHandler(self)

	if self.legend_stage_cfg.type == 2 then
		for i = 1, self.plyMgr.enemy_list.Count do
			local enemy = self.plyMgr.enemy_list:get(i - 1)
			self:createEnemyEffect(enemy, "Legend_BUFF_001", "head")
		end
	end
end

--准备布阵数据
function M:readyArrayData( data, mode, def_data, assist_heros, legend_heros, ext_data )
	M.super.readyArrayData( self, data, mode, def_data, assist_heros, legend_heros, ext_data )
end

function M:sceneBattleStart()
	M.super.sceneBattleStart( self )
	self.killNum = 0
	self.legendNextRefreshTime = nil
	--江湖传说敌人刷新次数
	self.legend_refresh_count = 0
	--江湖传说boss刷新序号
	self.legend_boss_index = 1
	self.buffCount = 0
	self.enemy_refresh_count = 0
	self.boss_refresh_count = 0
	for k,v in pairs(self.common.attacker_add) do
		local enemys = self.plyMgr.enemy_list
		for i = 1, enemys.Count do
			local enemy = enemys:get(i - 1)
			self:addAttr(enemy, k, v)
		end
	end
end

function M:update_dt(dt)
	M.super.update_dt(self,dt)
	if self:get_sceneState() == SceneManager.SceneState.SceneRunning then
		local time = GlobalTools:ToFix(self.legend_stage_cfg.levelup_time)
		local buff = self.legend_stage_cfg.levelup_num
		--生存模式
		if self.battle_mode == 3 and time > 0 then
			local count = Mathf.Floor(self.curTime/time)
			if self.buffCount ~= count then
				local enemys = self.plyMgr.enemy_list
				for i = 1, enemys.Count do
					local enemy = enemys:get(i - 1)
					for i = self.buffCount+1, count do
						for k,v in pairs(buff) do
							enemy.bufMgr:addBufById(v, enemy)
						end
					end
				end
				self.buffCount = count
				--local buff_table = ConfigManager:getCfgByName("buff")
				--local buff_param = buff_table[buff[1]].param[1]
				--local value = 0 
				--for k,v in ipairs(buff_param) do
				--	if v[1] == "param" then
				--		value = v[2]
				--		break
				--	end
				--end
				local num = math.floor(0.2 * 100 + 0.5) * count
				self:dispatchEvent_Local(Battle.EventType.MV_LegendFightSceneModelUpdateBuff, {attr = num})
			end
		end
	end
end

function M:checkBuff(player)
	--战役属性升级
	for k,v in pairs(self.common.attacker_add) do
		self:addAttr(player, k, v)
	end
	--生存模式
	if self.battle_mode == 3 then
		for i = 1, self.buffCount do
			for k,v in pairs(self.legend_stage_cfg.levelup_num) do
				player.bufMgr:addBufById(v, player)
			end
		end
	end
end

function M:addAttr(player, key, value)
	local hp_rate = player.data:get_hpRate()
	player.data[key]:addToMulList(value)
	if key == "hp" then
		player.data:set_curHp(GlobalTools:Mul(player.data.hp:getValue(), hp_rate))
	end
end


--总是更新的场景
function M:updateAlways(dt)
	M.super.updateAlways(self,dt)
end


--设定CameraPosition
function M:setCameraPosition( isZhanDou )
	
end

function M:killerPlayerHandler(eventName, data)
	local victim = data["victim"]
	local killer = data["killer"]
	if killer ~= nil and killer.camp == 1 then
		if victim.master == nil then
			self.killNum = self.killNum + 1
			if self.battle_mode == 2 then
				self:dispatchEvent_Local(Battle.EventType.MV_LegendFightSceneModelUpdateKillNum, {killNum = self.killNum})
			end
		end
	end
	if victim ~= nil and victim.camp == -1 then
		victim:removeEffectByName("Legend_BUFF_001")
	end
end

function M:getBattleValue()
	if self.battle_mode == 2 then
		return self.killNum
	elseif self.battle_mode == 3 then
		return Mathf.Floor(GlobalTools:ToFloat(self.curTime))
	end
	return 0
end

function M:checkEnemyRefresh( dt )
	if self.curRefreshTime >= 0 then
		self.curRefreshTime = self.curRefreshTime - dt
		if self.curRefreshTime <= 0 then
			if self.battle_mode == 2 then
				self:refreshBoss()
				self:refreshConquestEnemy()
			elseif self.battle_mode == 3 then
				self:refreshSurvivalEnemy()
			end
			self.curRefreshTime = self.refreshTime
		end
	end
end

function M:refreshConquestEnemy()
	local legend_data = self.legend_stage_table[self.m_ext_data.battle_id]
	local enemtList = self.plyMgr:getPlayersNoDead(self.plyMgr.enemy_list)
	local enemyCount = enemtList.Count;
	if enemyCount <= legend_data.refresh_time then
		self.legend_refresh_count = self.legend_refresh_count + 1
		local spawn_right = self.legend_refresh_count%2 ~= 0
		--local pos_index = {}
		--for i = 1, #self.legend_data.enemy do
		--	table.insert(pos_index, i - 1)
		--end
		--for i = 1, enemtList.Count do
		--	local enemy = enemtList:get(i - 1)
		--	if enemy ~= nil then
		--		table.removebyvalue(pos_index, enemy.index)
		--	end
		--end
		self.cur_legend_monster_index = self.cur_legend_monster_index or 1
		local count = #legend_data.enemy - enemyCount
		if count > 0 then
			self.enemy_refresh_count = self.enemy_refresh_count + 1
		end
		while count > 0 do
			--刷新角色
			local hero_id = legend_data.enemy_group[self.cur_legend_monster_index]
			
			local pos = nil
			local index = WRandom:randomNum(0, #legend_data.enemy, true)
			if spawn_right then
				pos =  self:findSpawnPosition(-1, index) + FixVector3.New(5,0,0)
			else
				pos = self:findSpawnPosition(-1, index + #legend_data.enemy/2) - FixVector3.New(5,0,0)
			end
			
			---@type PlayerModel
			local player = nil
			local playerKey = self.playerIdPrefab[hero_id]
			if playerKey and self.leaveFieldEnemies[playerKey] and #self.leaveFieldEnemies[playerKey] > 0 then
				player = table.remove(self.leaveFieldEnemies[playerKey])
				player.aiEngine:changeState("relive")
				player:setPos(pos, true)
			else
				local hero_param = BattleDataManager:create_hero_data(hero_id, self.mode, {battle_id = self.m_legend_sort, type = 2, count = self.enemy_refresh_count})
				local playerData = BattleDataManager:create_hero(hero_id, hero_param)
				--local player = self:createNewPlayer(playerData.oid, playerData,-1,pos_index[1],pos,nil)
				player = self:createNewPlayer(playerData.oid, playerData,-1,0,pos,nil)
				player.data:set_evo( playerData.evo );
				player.canRelive = true
				self:setPlayerAttrubute(player, playerData.attrs)
				player:spawn()
				--table.remove(pos_index, 1)
				player.plySkill:lockSkill({"attack1"})
				player.canRelive = true
				player.aiEngine:changeState("legendSpawn", {spawnDist = GlobalTools.base5, finishCallBack = function() player:spawn() end })
			end
			if player then
				if spawn_right == false then
					player:setForward(FixVector3.right(),true)
				end
				self:checkBuff(player)
			end
			--刷新索引
			self.cur_legend_monster_index = self.cur_legend_monster_index + 1
			if self.cur_legend_monster_index > #legend_data.enemy_group then
				self.cur_legend_monster_index = 1
			end
			count = count - 1
		end
	end
end

function M:refreshBoss()
	local legend_data = self.legend_stage_table[self.m_ext_data.battle_id]
	local bossSpawn = false
	local cond = legend_data.boss_refresh[self.legend_boss_index]
	if cond ~= nil then
		if self.battle_mode == 2 then
			bossSpawn = self.killNum >= cond
		elseif self.battle_mode == 3 then
			bossSpawn = self.curTime >= GlobalTools:ToFix(cond)
		end
		local enemtList = self.plyMgr:getPlayersNoDead(self.plyMgr.enemy_list)
		local enemyCount = enemtList.Count;
		if bossSpawn == true and enemyCount < #legend_data.enemy then
			local pos_index = {}
			for i = 1, #legend_data.enemy do
				table.insert(pos_index, i - 1)
			end
			for i = 1, enemtList.Count do
				local enemy = enemtList:get(i - 1)
				if enemy ~= nil then
					table.removebyvalue(pos_index, enemy.index)
				end
			end
			self.boss_refresh_count = self.boss_refresh_count + 1
			--刷新角色
			local hero_id = legend_data.boss_group[self.legend_boss_index]
			local hero_param = BattleDataManager:create_hero_data(hero_id, self.mode, {battle_id = self.m_legend_sort, type = 3, count = self.boss_refresh_count})
			local playerData = BattleDataManager:create_hero(hero_id, hero_param)
			local pos = nil
			local index = WRandom:randomNum(0, 10, true)
			pos =  self:findSpawnPosition(-1, index) + FixVector3.New(5,0,0)
			local player = self:createNewPlayer(playerData.oid, playerData,-1,pos_index[1],pos,nil)
			player.data:set_evo( playerData.evo );
			self:setPlayerAttrubute(player, playerData.attrs)
			player:spawn()
			player:setBaseScale(GlobalTools.base1_2)
			self:checkBuff(player)
			player.aiEngine:changeState("legendSpawn", {spawnDist = GlobalTools.base5, finishCallBack = function() player:spawn() end })
			self.legend_boss_index = self.legend_boss_index + 1
		end
	end
end

function M:refreshSurvivalEnemy()
	local legend_data = self.legend_stage_table[self.m_ext_data.battle_id]
	local enemtList = self.plyMgr:getPlayersNoDead(self.plyMgr.enemy_list)
	local enemyCount = enemtList.Count;
	self.legendNextRefreshTime = self.legendNextRefreshTime or GlobalTools:ToFix(legend_data.refresh_time)
	if enemyCount <= 0 or self.curTime > self.legendNextRefreshTime then
		local refreshAll = false
		if self.curTime > self.legendNextRefreshTime then
			refreshAll = true
			for i = 1, self.plyMgr.enemy_list.Count do
				local enemy = self.plyMgr.enemy_list:get(i - 1)
				if enemy:isLive() == true then
					local hp = enemy.data:get_curHp()
					Logger.log(enemy.plyType.."自爆，攻击力为："..GlobalTools:ToFloat(hp))
					enemy.data:set_curHp( 0 )
					self:createEnemyEffect(enemy, "Legend_baozha_001", "Root")
					TimeTools:delayTimeUnity(0.5, function()
						for j = 1, self.plyMgr.hero_list.Count do
							local hero = self.plyMgr.hero_list:get(j - 1)
							local dis = GlobalTools:Distance(enemy.position, hero.position)
							if dis <= GlobalTools:ToFix2(GlobalTools.base3) then
								local attackData = BattleTool:getBaseAttackData()

								attackData["damage"] = hp
								attackData["player"] = enemy
								attackData["skillConfig"] = nil
								attackData["injureType"] = nil
								attackData["damageFront"] = GlobalTools.base1
								attackData["damageLast"] = GlobalTools.base1
								attackData["angerAir"] = 0
								attackData["type"] = 0
								attackData["injureBuf"] = 0
								attackData["damageType"] = 1

								hero:injure(attackData)
							end
						end
					end)
				end
			end
		end
		self.legend_refresh_count = self.legend_refresh_count + 1
		self.legendNextRefreshTime = self.curTime + GlobalTools:ToFix(legend_data.refresh_time)
		local pos_index = {}
		for i = 1, #legend_data.enemy do
			table.insert(pos_index, i - 1)
		end
		for i = 1, enemtList.Count do
			local enemy = enemtList:get(i - 1)
			if enemy ~= nil then
				table.removebyvalue(pos_index, enemy.index)
			end
		end
		self.cur_legend_monster_index = self.cur_legend_monster_index or 1
		local count = #legend_data.enemy - enemyCount
		if refreshAll == true then
			count = #legend_data.enemy
		end
		if count > 0 then
			self.enemy_refresh_count = self.enemy_refresh_count + 1
		end
		while count > 0 do
			--刷新角色
			local hero_id = legend_data.enemy_group[self.cur_legend_monster_index]
			local hero_param = BattleDataManager:create_hero_data(hero_id, self.mode, {battle_id = self.m_legend_sort, type = 2, count = self.enemy_refresh_count})
			local playerData = BattleDataManager:create_hero(hero_id, hero_param)
			if playerData ~= nil then
				local pos = nil
				local index = WRandom:randomNum(0, 5, true)
				pos =  self:findSpawnPosition(-1, index) + FixVector3.New(5,0,0)
				local player = self:createNewPlayer(playerData.oid, playerData,-1,pos_index[1],pos,nil)
				table.remove(pos_index, 1)
				player.data:set_evo( playerData.evo );
				self:setPlayerAttrubute(player, playerData.attrs)
				player:spawn()
				self:createEnemyEffect(player, "Legend_BUFF_001", "head")
				self:checkBuff(player)
				player.aiEngine:changeState("legendSpawn", {spawnDist = GlobalTools.base5, finishCallBack = function() player:spawn() end })
			end
			count = count - 1
			--刷新索引
			self.cur_legend_monster_index = self.cur_legend_monster_index + 1
			if self.cur_legend_monster_index > #legend_data.enemy_group then
				self.cur_legend_monster_index = 1
			end
		end
	end
end

function M:createEnemyEffect(player, effect_name, parent, needDestory)
	local effectData = {}
	effectData["prefab"] = effect_name
	effectData["autodestoryTime"] = self.legend_stage_cfg.refresh_time
	effectData["parent"] = parent
	effectData["isPutUpInParent"] = true
	effectData["positionType"] = "parentOffset"
	effectData["directionType"] = "parent"
	effectData["scaleType"] = "world"
	local prefabTrans = {}
	prefabTrans["useUserSet"] = true
	prefabTrans["position"] = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
	}
	prefabTrans["rotation"] = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
	}
	prefabTrans["scale"] = {
		[1] = 1,
		[2] = 1,
		[3] = 1,
	}
	effectData["prefabTrans"] = prefabTrans

	player:playEffect(effectData, player)
end

---@param eventData Battle_HandleData_LeaveField
function M:leaveFieldHandler(eventName, eventData)
	if eventData.player.camp == -1 then -- 敌方
		local playerKey = eventData.player:get_prefabName()
		self.leaveFieldEnemies[playerKey] = self.leaveFieldEnemies[playerKey] or {}
		table.insert(self.leaveFieldEnemies[playerKey], 1, eventData.player)
	end
end

function M:onGameOver()
	self:clearCacheData()
	M.super.onGameOver(self)
end

--- 重新开始
function M:restartBattle()
	self:clearCacheData()
	M.super.restartBattle(self)
end


--- 退出战斗
function M:exitBattle()
	self:clearCacheData()
	M.super.exitBattle(self)
end

function M:clearCacheData()
	self.leaveFieldEnemies = {}
	self.playerIdPrefab = {}
end

--销毁
function M:destroy( nextScene )
	self:clearCacheData()
	LODUtil:resetLodLevel()
	EventDispatcher:unRegisterEvent("leave_battlefield", {self,self.leaveFieldHandler})
	EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
	M.super.destroy(self, nextScene);
end

return M