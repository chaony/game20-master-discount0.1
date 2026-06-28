local SceneManager = SceneManager

---@class Scene_Model : ModelBase 场景数据层
---@field plyMgr PlayerManager_Model
---@field ZhenFaManager ZhenFaManager
local M = class("Scene_Model",Battle.ModelBase)

--场景id
M.sceneId = 0
--是否按下
M.isMouseDown = false
--场景更新频率
M.delayTime = 0.03
M.curDelayTime = 0
M.unscaleDelayTime = 0.03
M.curUnscaleDelayTime = 0
M.updateOk = false
M.friction = 40
--战斗等级压制生效等级
M.level_suppress = 0
M.gameover = false
--当前的时间
M.curTime = 0;

--开始场景
function M:init()
	self.sceneId = 0;
	self.sceneName = "scene";
	self.scriptName = "";
	self.sceneType = "";
	self.loopTime = 0;
	self.sceneCanshowHp = true;
	self.sceneCanshowLV = true;
	--摩擦系数
	self.friction = 40;
	--打开面板的数量
	self.open_panel_num = 0;
	--延迟关闭loading时间
	self.delay_close_loading_time = 0;
	--最大时间90秒
	self.maxTime = GlobalTools.base90;
	--是否开始战斗
	self.startBattle = false;
	--是否在布阵状态
	self.buzheng = false;
	--更新中发送的数据
	self.updateSendData = {};
	
	--人物管理器 数据层
	self.plyMgr = require("Battle.Ply.PlayerManager_Model").new()
	--阵法管理器
	self.ZhenFaManager = require("Battle.Sce.Tools.ZhenFaManager").new()
	--战斗配置
	self.battleConfig = require("Battle.battleConfig")
	self.battleCameraConfig = require("Battle.battleCameraConfig")
	
	self.cur_near_index = 0
	self.last_near_index = 0

	-- 战斗状态机
	self.battleFSM = Battle.BattleFSM:new()
	self.battleFSM:init(self)
	self.battleFSM:changeState(Battle.BattleFSM.BATTLE_STATES.Idle)
end

--设定相机是否显示
function M:setCameraShow( show )
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelCameraShow, { show = show })
end


--设定类型
function M:setMode( mode )
	self.m_game_mode = mode;
end

--初始化管理器
function M:initManager()
	self.plyMgr:start(self)
	self.ZhenFaManager:init()
	--服务器是不会发送这个事件的
	self:addEventListener_Local(Battle.EventType.VM_SceneViewLoadFinish, {self, self.SceneViewLoadFinish});
end

--进入模式
function M:enter( data )
	-- 編輯器模式客户端每次进入战斗时，重新加载battleConfig,实现在游戏中可以调整战斗阵容
	if GameUtil and GameUtil:getpPlatform() == "Editor" then
		self.battleConfig = CustomRequire("Battle.battleConfig")
		self.isUseConfig = self.battleConfig.useMe
		if self.battleConfig.controlGameVersion then
			GameVersionConfig.USE_LOCAL_BATTLE_DATA = self.battleConfig.useLocalData
			GameVersionConfig.OPEN_BATTLE_LOG = self.battleConfig.openBattleLog
		end
		self:doLuaReload()
	end

	self.m_data = data;
	self.m_stage_id = -999;
	if self.m_data ~= nil and data.sort then
		self.m_data.mode = data.sort
		self.mode = data.sort
	end
	--初始化一次种子,使用真随机
	WRandom:setSeed(0,-1, true);
	self.m_raid_sort = self.m_data and self.m_data.raid_sort
	--服务器战斗参数处理
	if self.m_data ~= nil and self.m_data.common ~= nil then
		self.m_stage_id = self.m_data.common.param
		self:setParam(self.m_data.common)
	end
	self.isDestoryMe = false;
	--开始战斗
	self.startBattle = false;
	self.create_player_finish = false;
	self.create_enemy_finish = false;
	self.spawnCount = 0
	--获取场景名
	self.scene_name = self:getCurSceneName();
	self.sceneObj_name = self:getCurSceneObjName();
	--注册人物的战斗的位置信息
	self:registerHeroAndEnemyPos()
	--发送场景进入事件
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelEnter, data, function()
		self:initScene()
	end)
end

--初始化场景数据
function M:initScene()
	--表中读取 摩擦力
	local scene_friction = ConfigManager:getCfgByName("scene_friction")
	local data = scene_friction[self.scene_name] or scene_friction["default"]
	if data ~= nil then
		self.friction = data.friction
	else
		self.friction = GlobalTools.base100
	end
	--游戏结果
	self.gameResult = {}
	--游戏循环帧
	self:set_runframe( GlobalTools.base0 );
	--场景运行
	SceneManager:scenestart_model();
	--战斗配置数据
	self.isUseConfig = self.battleConfig["useMe"]
	--SelectTargetTool:resetFixPoint()
	self:loadFinish();
	if self.m_data ~= nil and self.m_data.view_callBack ~= nil then
		self.m_data.view_callBack();
	end
end

--加载完成(后面子类重写)
function M:loadFinish()
	
end

--视图层通知场景加载完成了
function M:SceneViewLoadFinish()
	--场景数据绑定完成
	self:initScene()
end

--通知视图层
function M:SceneModelCreateFinish()
	--初始化的时候事件发送器还没有注入，这时候发送事件需要发送全局事件
	--Model创建完成
	if SceneManager.MV_EventMgr ~= nil then
		SceneManager.MV_EventMgr:dispatchEvent(Battle.EventType.MV_SceneModelCreateFinish, self);
	end
	self:bandingEventFinish();
	--初始化管理器
	self:initManager();
end


--绑定事件完成
function M:bandingEventFinish()
	self:set_sceneState( SceneManager.SceneState.SceneInit )
end


function M:getHandUpSceneConfig()
	return nil;
end

function M:getHangUpConfig()
	return nil;
end


-- 需要子类手动调用 - 初始化完成
function M:initFinish()
	--初始化完成
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelInitFinish)
end

--注册玩家和敌人的位置信息
function M:registerHeroAndEnemyPos()
	local info = require("Battle.Data.SceneInfo."..self.scene_name.."_info");
	--Logger.log(">>>>> 注册人物开始站位信息 <<<<<<")
	if self.heroPoslist then
		self.heroPoslist:clear()
	end
	if self.enemyPoslist then
		self.enemyPoslist:clear()
	end
	if self.petPoslist then
		self.petPoslist:clear()
	end
	if self.petEnemyPoslist then
		self.petEnemyPoslist:clear()
	end
	if self.xiezhanPetPoslist then
		self.xiezhanPetPoslist:clear()
	end
	if self.xiezhanPetEnemyPoslist then
		self.xiezhanPetEnemyPoslist:clear()
	end


	local index = 0
	while true do
		local key = "HeroPos"
		local list_key = "heroPos"
		if index > 0 then
			key = key .. index
			list_key = list_key .. index
		end
		list_key = list_key .. "list"
		local heroPos = info["info"][self.sceneObj_name][key];
		if heroPos ~= nil then
			if self[list_key] == nil then
				self[list_key] = Battle.List.new()
			end
			local len = #heroPos + 1;
			for i=1,len do
				local pos = heroPos[i-1]
				local fix_pos = FixVector3.New(0,0,0);
				fix_pos.x = pos.x;
				fix_pos.y = pos.y;
				fix_pos.z = pos.z;
				self[list_key]:add(fix_pos)
			end
		else
			if index > 0 then
				break
			end
		end
		index = index + 1
	end

	index = 0
	while true do
		local key = "EnemyPos"
		local list_key = "enemyPos"
		if index > 0 then
			key = key .. index
			list_key = list_key .. index
		end
		list_key = list_key .. "list"
		local enemyPos = info["info"][self.sceneObj_name][key];
		if enemyPos ~= nil then
			if self[list_key] == nil then
				self[list_key] = Battle.List.new()
			end
			local len = #enemyPos + 1;
			for i=1,len do
				local pos = enemyPos[i-1]
				local fix_pos = FixVector3.New(0,0,0);
				fix_pos.x = pos.x;
				fix_pos.y = pos.y;
				fix_pos.z = pos.z;
				self[list_key]:add(fix_pos)
			end
		else
			if index > 0 then
				break
			end
		end
		index = index + 1
	end

	self.areaPoslist = Battle.List.new()
	local areaPos = info["info"][self.sceneObj_name]["AreaPos"];
	if areaPos ~= nil then
		local len = #areaPos + 1;
		for i=1,len do
			local pos = areaPos[i-1]
			local fix_pos = FixVector3.New(0,0,0);
			fix_pos.x = pos.x;
			fix_pos.y = pos.y;
			fix_pos.z = pos.z;
			self.areaPoslist:add(fix_pos)
		end
	end
	self.bossPoslist = Battle.List.new()
	local bossPos = info["info"][self.sceneObj_name]["BossPos"];
	if bossPos ~= nil then
		local len = #bossPos + 1;
		for i=1,len do
			local pos = bossPos[i-1]
			local fix_pos = FixVector3.New(0,0,0);
			fix_pos.x = pos.x;
			fix_pos.y = pos.y;
			fix_pos.z = pos.z;
			self.bossPoslist:add(fix_pos)
		end
	end
	self.gridRootPos = info["info"][self.sceneObj_name]["gridRootPos"];
	--场景中心位置
	local sceneCenterPos = info["info"][self.sceneObj_name]["sceneCenter"];
	self.sceneCenter = FixVector3.New(0,0,0);
	if sceneCenterPos ~= nil then
		self.sceneCenter.x = sceneCenterPos.x
		self.sceneCenter.y = sceneCenterPos.y
		self.sceneCenter.z = sceneCenterPos.z
	end
	self.guideData = info["info"][self.sceneObj_name]["Guide"];

	-- 加载宠物站位信息
	self:loadPetPosInfo(info, "XieZhanPetPos", "xiezhanPetPos")
	self:loadPetPosInfo(info, "XieZhanPetEnemyPos", "xiezhanPetEnemyPos")
	self:loadPetPosInfo(info, "PetPos", "petPos")
	self:loadPetPosInfo(info, "PetEnemyPos", "petEnemyPos")
end

function M:loadPetPosInfo(info, key, list_key)
	local index = 0
	while true do
		if index > 0 then
			key = key .. index
			list_key = list_key .. index
		end
		list_key = list_key .. "list"
		local enemyPos = info["info"][self.sceneObj_name][key];
		if enemyPos ~= nil then
			if self[list_key] == nil then
				self[list_key] = Battle.List.new()
			end
			local len = #enemyPos + 1;
			for i=1,len do
				local pos = enemyPos[i-1]
				local fix_pos = FixVector3.New(0,0,0);
				fix_pos.x = pos.x;
				fix_pos.y = pos.y;
				fix_pos.z = pos.z;
				self[list_key]:add(fix_pos)
			end
		else
			if index > 0 then
				break
			end
		end
		index = index + 1
	end
end

--获取玩家位置
function M:get_heroPosList()
	return self.heroPoslist
end

--获取敌人位置
function M:get_enemyPosList()
	return self.enemyPoslist
end

--获取玩家宠物斗技位置
function M:get_petPoslist()
	return self.petPoslist
end

--获取敌人宠物斗技位置
function M:get_petEnemyPoslist()
	return self.petEnemyPoslist
end

--设定场景状态
function M:set_sceneState( state )
	self.sceneState = state;
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelSetState)
end

--返回场景状态
function M:get_sceneState()
	return self.sceneState;
end


--创建场景配置文件
function M:createSceneConfig( config_id )
	self.scene_config_id = config_id;
	self.scene_config = ConfigManager:getCfgByName("scene_config");
	self.scene_info = self.scene_config[tonumber(config_id)]
end
--获取场景信息
function M:get_scene_info()
	return self.scene_info;
end

--获取向导数据
function M:get_guideData()
	return self.guideData;
end

--子类重写
function M:getCurSceneName()
	return "chapter1";
end

--子类重写
function M:getCurCameraInfoName()
	if self.m_data ~= nil and self.m_data.m_isMoveCamera == 1 then
		self:createSceneConfig(109)
		return self.scene_info.resource;
	end
	return self:getCurSceneName()
end

--子类重写
function M:getCurSceneObjName()
	return "fightscene_data1";
end

--获取边缘位置
function M:getEdgePosition(pos, dir)
	return pos
end

--当前运行的帧数
function M:get_runframe()
	return self.loopTime;
end
--设定循环时间
function M:set_runframe( loopTime )
	self.loopTime = loopTime;
end
--更新循环时间
function M:add_runframe()
	self.loopTime = self.loopTime + GlobalTools.base1;
end

function M:sendEvent( eventName, data, panelName ) 
	local eventData = {}
	eventData.eventName = eventName;
	eventData.data = data;
	eventData.panelName = panelName;
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelSendEvent, eventData )
end


--创建玩家队伍
--isArray 是否是布阵
function M:createPlayerTeam(data)
	for k,v in pairs(data) do
		if v ~= "" then
			local data, heroXlsxData = UserDataManager.hero_data:getHeroDataById(v)
			if data == nil then
				data, heroXlsxData = UserDataManager.pet_data:getPetDataById(v)
				if data then
					data.playerType = "player"
				end
			end
			if data == nil then
				if self.m_assist_heros ~=  nil then
					data = self.m_assist_heros[v]
				end
				if data == nil and self.m_legend_heros ~= nil then
					data = self.m_legend_heros[v]
				end
				if data == nil and self.m_ext_data and self.m_ext_data.other_heros then
					data = self.m_ext_data.other_heros[v]
				end
			end
			if data ~= nil then
				if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
					local cur_season = UserDataManager:getCurSeason()
					local gve_cfg = ConfigManager:getCfgByName("gve")
					local gve_cfg_season = gve_cfg[cur_season] or {}
					local conversion_a = gve_cfg_season.conversion_a or 300 -- 最小等級
					if data and data.lv < conversion_a and data.clv < conversion_a then
						data = table.copy(data)
						data.lv = conversion_a
						data.clv = conversion_a
					end
				elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
					if self.m_data.level_up == 1 then
						local min_lv = 300
						if data and data.lv < min_lv and data.clv < min_lv then
							data = table.copy(data)
							data.lv = min_lv
							data.clv = min_lv
						end
					end
				elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.MYTH_ARENA_DEFENSE
					or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.MYTH_ARENA then
					local show_lvXlsxData = ConfigManager:getCommonValueById(727) or {{3,150},{5,300}}
					local xlsxEvo = heroXlsxData.evo
					local heroLv = 1
					local commonHeroData1 = show_lvXlsxData[1]
					local commonHeroData2 = show_lvXlsxData[2]
					if xlsxEvo == commonHeroData1[1] then
						heroLv = commonHeroData1[2]
					elseif xlsxEvo == commonHeroData2[1] then
						heroLv = commonHeroData2[2]
					end
					data = table.copy(data)
					data.lv = heroLv
					data.clv = heroLv
				elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR then
					
					local heroLv = ConfigManager:getCommonValueById(776,3300 )
					--local r_lv = conversion_a
					--local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
					--local upgrade_cfg = hero_upgrade[tonumber(r_lv)] or {}
					--heroLv = upgrade_cfg.display_level or 1
					data = table.copy(data)
					data.lv = heroLv
					data.clv = heroLv
				elseif self.mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_POINT_RACE or self.mode == GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION then
					local show_lvXlsxData = ConfigManager:getCommonValueById(778 or 2300) 
					local xlsxEvo = heroXlsxData.evo
					local heroLv = 1
					local commonHeroData1 = show_lvXlsxData[1]
					local commonHeroData2 = show_lvXlsxData[2]
					if xlsxEvo == commonHeroData1[1] then
						heroLv = commonHeroData1[2]
					elseif xlsxEvo == commonHeroData2[1] then
						heroLv = commonHeroData2[2]
					end
					data = table.copy(data)
					data.lv = heroLv
					data.clv = heroLv
				elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.AWAKE_SYSTEM then
					local stagecfg = SceneManager:getCurSceneModel().m_ext_data.m_stage_cfg or {}
					local hero_level = stagecfg.max_lv or 300
					data = table.copy(data)
					data.lv = hero_level
					data.clv = hero_level

				elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.XIAKEDAO or
						self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI
				then
					local hero_isle_base_cfg=ConfigManager:getCfgByName("hero_isle_base")
					local hero_level=hero_isle_base_cfg.hero_level or 300
					data = table.copy(data)
					data.lv = hero_level
					data.clv = hero_level
				elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE 
						or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE then
					local openJusticeIndex = SceneManager:getCurSceneModel().m_ext_data.fair or 0
					-- 0 不公平，1公平
					if openJusticeIndex == 1 then
						local show_lvXlsxData = ConfigManager:getCommonValueById(721) or {{3,150},{5,300}}
						local xlsxEvo = heroXlsxData.evo
						local heroLv = 1
						local commonHeroData1 = show_lvXlsxData[1]
						local commonHeroData2 = show_lvXlsxData[2]
						if xlsxEvo == commonHeroData1[1] then
							heroLv = commonHeroData1[2]
						elseif xlsxEvo == commonHeroData2[1] then
							heroLv = commonHeroData2[2]
						end
						data = table.copy(data)
						data.lv = heroLv
						data.clv = heroLv
					end
				end
				local player = self.plyMgr:createPlayer(data,1,k-1,nil,nil)
				if player:checkApostle() then
					self:sendEvent("createHelperUI", {player = player}, "Formation")
				end
				player:set_playerInstanceId(v)
				player.data:set_evo( data.evo )
			end
		end
	end
	
	self:createPlayerFinish();
end

function M:createPlayerFinish()
	self.create_player_finish = true;
	if self.create_player_finish and self.create_enemy_finish then
		self:createPlayerAndEnemyFinish();
	end
end

function M:playerSpawnFinish()
end

function M:createEnemyFinish()
	self.create_enemy_finish = true;
	if self.create_player_finish and self.create_enemy_finish then
		self:createPlayerAndEnemyFinish();
	end
end

function M:createPlayerAndEnemyFinish()

end


--创建敌人队伍
--是否是布阵创建人物
function M:createEnemyTeam(battle_id, isArray, tableName, formation_index)
	local tableName = tableName or "stage_battle"
	local battle_data = nil
	if tableName == "stage_battle" then
		battle_data = ConfigManager:getCfgStageBattle(battle_id)
	else
		local stage_battle_tab = ConfigManager:getCfgByName(tableName)
		battle_data = stage_battle_tab[battle_id]
		if battle_data == nil and formation_index then
			if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.MULT_STAGE then
				local stage_battle_tab2 = ConfigManager:getCfgByName("stage_battle" .. (formation_index == 1 and "" or formation_index))
				battle_data = stage_battle_tab2[battle_id]
			elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
				local stage_battle_tab2 = ConfigManager:getCfgByName("stage_battle" .. (formation_index == 1 and "" or formation_index))
				battle_data = stage_battle_tab2[battle_id]
			end
		end
		if not battle_data then
			Logger.logErrorAlways(tostring(battle_id).."--"..tostring(tableName).."--"..tostring(formation_index),
					"battle_data is nil battle_id -- tableName -- formation_index ")
		end
	end

	local boss_size = battle_data.boss_size_mode
	if boss_size <= 0 then
		boss_size = 1
	end
	self.stageBossData = { index = battle_data.boss_position, scale = GlobalTools:CommonToFix(boss_size) }
	self.level_suppress = battle_data.level_suppress or 0
	
	if battle_data then
		local monsters = battle_data["monster"]
		for k,v in pairs(monsters) do
			if v.id ~= "null" and v.id ~= nil and v.id > 0 then
				local player = self.plyMgr:createPlayer(v,-1,k-1,nil,nil)
				--player:MakeFootUI();
				player.data:set_evo( v.evo );
			end
		end
	else
		Logger.logError(battle_id, "stage_battle not found id => ")
	end
	self:createEnemyFinish();
end

function M:canAutoUseBigSkillAll()
	return true;
end

function M:canAutoUseBigSkillHero()
	return true;
end

--创建敌人队伍
function M:createEnemyByData(def_data, isArray)
	if def_data then
		local def_team = def_data.def_team or def_data.team
		def_team = def_team or {}
		local heros = def_data.heros or {}
		local dyns = def_data.dyns or {}
		for k,v in pairs(def_team) do
			local hero_data = heros[v]
			local hero_dyns = dyns[v] or {}
			local hp_pct = hero_dyns.hp_pct or GlobalTools.base10000
			if hero_data and hp_pct > 0 then
				local player = self.plyMgr:createPlayer(hero_data,-1,k-1,nil,nil)
				player:set_playerInstanceId(v)
				player.data:set_evo( hero_data.evo )
			end
		end
	end
	
	self:createEnemyFinish();
end


--从服务器传来的数据设定到玩家身上
--设定玩家的属性
---@param player PlayerModel
function M:setPlayerAttrubute( player, data )

	if GameVersionConfig.Debug then
		local already_handle_data = Battle.BattleGlobalConfig.HandleHeroDataKeys or {}
		for k, v in pairs(data) do
			if not already_handle_data[k] then
				Logger.logError(k, "错误：没有处理角色的属性数据")
			end
		end
	end
	
	-- Player 玩家
	-- data 服务器数据
	--血量
	--Logger.logError(player.plyType.." 血量 "..data["hp"].." 攻击力 "..data["atk"].." 防御力 "..data["def"]  )
	--Logger.logError(data," 英雄数据 ~~~~~~~~~~~~~~ " )
	
	if data["hp"] ~= nil then
		player.data.hp:setInitialValue( data["hp"] )
		player.data:set_curHp( player.data:get_hp() )
	end
	--攻击力
	if data["atk"] ~= nil then
		player.data.atk:setInitialValue( data["atk"] )
	end
	--防御力
	if data["def"] ~= nil then
		player.data.def:setInitialValue( data["def"] )
	end
	--暴击率
	if data["critrate"] ~= nil then
		player.data.critrate:setInitialValue( data["critrate"] )
	end
	--暴击效果
	if data["crit"] ~= nil then
		player.data.crit:addToAddList( data["crit"] )
	end
	--暴击减免效果
	if data["discrit"] ~= nil then
		player.data.discrit:addToAddList( data["discrit"] )
	end
	--怒气值
	if data["rage"] ~= nil then
		player.data:set_anger( data["rage"] )
	end
	--重量
	if data["weight"] ~= nil then
		player:setWeight( data["weight"] )
	end
	-- 受击怒气回复速度
	if data["hurtrageregen"] then
		player.data.hurtrageregen:addToMulList( data["hurtrageregen"] )
	end
	-- 攻击怒气回复速度
	if data["atkrageregen"] then
		player.data.atkrageregen:addToMulList( data["atkrageregen"] )
	end
	--怒气回复
	if data["rageregenper"] ~= nil then
		local rag = data["rageregenper"];
		local rag_div = GlobalTools:Div( rag, GlobalTools.base100 );
		player.data.atkrageregen:addToMulList( rag_div )
		player.data.hurtrageregen:addToMulList( rag_div )
	end
	--内伤增加magicdamage
	if data["magicdamage"] ~= nil then
		player.data.magicdamage:addToMulList( data["magicdamage"] )
	end
	
	--外伤增加physicaldamage
	if data["physicaldamage"] ~= nil then
		player.data.physicaldamage:addToMulList( data["physicaldamage"] )
	end
	--冷却加速
	if data["cdup"] ~= nil then
		player.data.cdup:addToAddList( data["cdup"] )
	end
	
	--命中等级
	if data["hr"] ~= nil then
		player.data.hr:setInitialValue( data["hr"] )
	end
	--闪避等级
	if data["dodge"] ~= nil then
		player.data.dodge:setInitialValue( data["dodge"] )
	end
	--加速
	if data["haste"] ~= nil then
		local haste = data["haste"]
		--冷却加速
		player.data.cdup:addToAddList( haste )
		--攻击速度
		player.data.haste:addToAddList( haste )
		--移动速度
		player.data.spd:addToAddList( haste )
	end
	--吸血等级
	if data["leeching"] ~= nil then
		local leeching = data["leeching"]
		player.data.leeching:setInitialValue( leeching )
	end
	--内伤减免
	if data["res"] ~= nil then
		local res = data["res"]
		player.data.res:addToMulList( res )
	end
	--抗暴率
	if data["resi"] ~= nil then
		local resi = data["resi"]
		player.data.resi:setInitialValue( resi )
	end
	--外伤减免
	if data["atd"] ~= nil then
		local atd = data["atd"]
		player.data.atd:addToMulList( atd )
	end
	--治疗效果(加，乘，同类加异类乘)
	if data["cureRate"] ~= nil then
		local cureRate = data["cureRate"]
		player.data.cureRate:addToAddList( cureRate )
	end
	--生命恢复效果(加，乘，同类加异类乘)
	if data["hpRecover"] ~= nil then
		local hpRecover = data["hpRecover"]
		player.data.hpRecover:addToAddList( hpRecover )
	end
	--坚韧
	if data["discontrol"] ~= nil then
		local discontrol = data["discontrol"]
		player.data.discontrol:setInitialValue( discontrol )
	end
	--伤害减免
	if data["resatd"] ~= nil then
		local resatd = data["resatd"]
		player.data.resatd:setInitialValue( resatd )
	end
	--伤害增加
	if data["pmdamage"] ~= nil then
		local pmdamage = data["pmdamage"]
		player.data.pmdamage:setInitialValue( pmdamage )
	end
	--坚韧抵抗
	if data["rediscontrol"] ~= nil then
		local rediscontrol = data["rediscontrol"]
		player.data.rediscontrol:setInitialValue( rediscontrol )
	end
	--内伤加深
	if data["disres"] ~= nil then
		local disres = data["disres"]
		player.data.disres:setInitialValue( disres )
	end
	--外伤加深
	if data["disatd"] ~= nil then
		local disatd = data["disatd"]
		player.data.disatd:setInitialValue( disatd )
	end
	--宠物气势值
	if data["power"] ~= nil then
		local power = data["power"]
		player.data.power:setInitialValue( power )
	end
end

--播放特效
function M:playerEffect( pos, name, autoDestoryTime )
	local data = {m_pos = pos,m_name = name, m_time = autoDestoryTime}
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelPlayEffect, data)
end

--@camp: 阵营 1 己方， 其他为敌人
--@index: 位置序号
--返回值为定点数
function M:findSpawnPosition(camp, index)
	if index >= 0 then
		local posList = nil
		if camp == 1 then
			posList = self["heroPoslist"]
		else
			posList = self["enemyPoslist"]
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

--- 获取协战宠物出生点
function M:findPetSpawnPosition(camp, index)
	if index >= 0 then
		local posList = nil
		if camp == 1 then
			posList = self["xiezhanPetPoslist"]
		else
			posList = self["xiezhanPetEnemyPoslist"]
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

--- 获取斗技宠物出生点
function M:findPetDouJiSpawnPosition(camp, index)
	if index >= 0 then
		local posList = nil
		if camp == 1 then
			posList = self["petPoslist"]
		else
			posList = self["petEnemyPoslist"]
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


--暂停
function M:pause()
	--将速度设置成0
	TimeManager:pause()
end

--继续
function M:continue()
	--将速度设置成0
	if self.sceneId == SceneManager.SceneID.FightScene or 
			self.sceneId == SceneManager.SceneID.BossScene or
			self.sceneId == SceneManager.SceneID.ActiveBossScene or
			self.sceneId == SceneManager.SceneID.TianjiLouFightScene or
			self.sceneId == SceneManager.SceneID.MiGongFightScene or
			self.sceneId == SceneManager.SceneID.WuXingZhenFightScene or 
			self.sceneId == SceneManager.SceneID.GuJianQiTanFightScene then
		TimeManager:set_timeSpeed(TimeManager:get_localSpeed())
	else
		TimeManager:set_timeSpeed(TimeManager:get_defaultSpeed());
	end
	TimeManager:set_timePause(GlobalTools.base1);
	TimeManager:set_timeScale(GlobalTools.base1);
end

--update 延迟更新
function M:lateUpdate( dt, unsdt )
	--if self.sceneState == SceneManager.SceneState.SceneReadyRun or 
	--		self.sceneState == SceneManager.SceneState.SceneRunning then
	--	if self.gameover == false then
	--		--人物管理器
	--		if self.plyMgr ~= nil then
	--			self.plyMgr:lateUpdate(dt)
	--		end
	--	end
	--end
end

--总是更新的
function M:updateAlways(dt)
	--if self.plyMgr ~= nil then
	--	self.plyMgr:updateAlways(dt)
	--end
end

--获取正常的帧数 
function M:get_loopTimeNormal()
	return GlobalTools:ToFloat( SceneManager:getCurSceneModel().loopTime )
end


--受到 TimeScale 更新频率影响的
function M:update_dt(dt)
	--Logger.logError(" 场景更新 ~~~~ sceneState "..self.sceneState.." startBattle "..tostring(self.startBattle).." gameover "..tostring(self.gameover))
	if self.sceneState == SceneManager.SceneState.SceneReadyRun or
			self.sceneState == SceneManager.SceneState.SceneRunning then
		if self.gameover == false then
			if self.startBattle == true then
				self:add_runframe()
			end
			self.cur_update_func_name = "update_dt"
			
			--人物管理器
			if self.plyMgr ~= nil then
				self.plyMgr:update(dt)
			end
			--场景导航
			if self.guide ~= nil then
				self.guide:update(dt)
			end
		end
	end

	-- if self.delay_close_loading_time > 0 then
	-- 	self.delay_close_loading_time  = self.delay_close_loading_time - dt;
	-- 	if self.delay_close_loading_time <= 0 then
	-- 		self:closeLoading();
	-- 		self.delay_close_loading_time = 0;
	-- 	end
	-- end
	if self.battleFSM then
		self.battleFSM:update(dt)
	end
end

--不会受到 TimeScale 更新频率影响的
function M:update_unsdt(unsdt)
	if self.sceneState == SceneManager.SceneState.SceneReadyRun or
			self.sceneState == SceneManager.SceneState.SceneRunning then
		if self.gameover == false then
			self.cur_update_func_name = "update_unsdt"
			if self.plyMgr ~= nil then
				self.plyMgr:update_unsdt(unsdt)
			end
		end
	end
	--无论什么状态都会执行的update
	self:updateAlways(unsdt)
end

--返回场景的固定点
function M:findSceneFixPoint()
	return self.sceneCenter;
end

function M:setParam(common)
	if common.sub_param ~= nil then
		if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.RAID then
			self.m_raid_sort = common.sub_param
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
			self.m_legend_sort = common.sub_param
		end
	end
end

function M:getBattleUseTime()
	return self.curTime
end

-- 战斗结束时
function M:onGameOver()
	-- 有需要子类重写逻辑
end

--- 重新开始
function M:restartBattle()
	
end

--- 退出战斗
function M:exitBattle()
	
end

function M:reset()
	self:destroy(nil)
	self:enter(nil)
end

--销毁场景
function M:destroy( nextScene )
	self.isDestoryMe = true;
	self.plyMgr:SetAutoFight(false)
	self.plyMgr:destroy();
	SelectTargetTool:clear();
	self.open_panel_num = 0;
	self.level_suppress = 0
	if self.mainPlayer ~= nil then
		self.mainPlayer = nil
	end
	--if self.aStar ~= nil then
		--self.aStar:destroy()
	--end
	self.stageBossData = nil
	--场景模式销毁
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelDestory,{nextScene = nextScene})
end

function M:doLuaReload()
	if GameUtil and GameUtil:getpPlatform() == "Editor" then
		--if self.isUseConfig then
			local ReloadBattleLuaFiles = {
				"Battle.Artifact",
				"Battle.Blt",
				"Battle.Buf",
				"Battle.Ply",
				"Battle.Relic",
				"Battle.SM",
				"Battle.Summon",
			}

			for k, v in pairs(package.loaded) do
				if string.find(k, "Battle") == 1 and #string.split(k,".") > 2 then
					package.loaded[k] = nil
					--Logger.log(k, "Will reload lua")
				end
			end
			
			local reloadLua  = function(script)
				package.loaded[script] = nil
				return require(script)				
			end


			Battle.EnumData = reloadLua("Battle.Data.EnumData")
			Battle.BattleGlobalConfig = reloadLua("Battle.BattleGlobalConfig")
			Battle.BattleConfigManager = reloadLua("Battle.Tool.BattleConfigManager")
			Battle.EventType = reloadLua("Battle.Evt.EventType")
			Battle.SkillEventType = reloadLua("Battle.Evt.SkillEventType")
			Battle.List = reloadLua("Battle.Tool.List")
			Battle.ListMap = reloadLua("Battle.Tool.ListMap")
			XXX = reloadLua("Battle.Tool.XXX")
			
			Battle.AIEngine = reloadLua("Battle.SM.Ai.AIEngine")
			Battle.AIState = reloadLua("Battle.SM.Ai.AIState")
			Battle.AIStateAttack_Player = reloadLua("Battle.SM.Ai.AIStateAttack_Player")
			Battle.AIStateMove_Player = reloadLua("Battle.SM.Ai.AIStateMove_Player")
			Battle.AIStatePatrol_Player = reloadLua("Battle.SM.Ai.AIStatePatrol_Player")


			SkillFeatures_Model = reloadLua("Battle.Ply.SkillFeatures.SkillFeatures_Model")
			SkillSkyStar = reloadLua("Battle.Ply.SkillSkyStar.SkillSkyStar")
			Mystic = reloadLua("Battle.Ply.Mystic.Mystic")
			PlayerTrait = reloadLua("Battle.Ply.Trait.PlayerTrait")
			
			Battle.Bullet_Model = reloadLua("Battle.Blt.Bullet_Model")
			Battle.Player_Model = reloadLua("Battle.Ply.Player_Model")
			
			Battle.ClassPathUtil = reloadLua("Battle.Tool.ClassPathUtil")
			Battle.ClassPathUtil:init()
			BattleTool = reloadLua("Battle.Tool.BattleTool")
			SelectTargetTool = reloadLua("Battle.Tool.SelectTargetTool")
			SelectTargetTool:init();
			SelectTargetUtil = reloadLua("Battle.Tool.SelectTargetUtil")


			TimeManager_View = reloadLua("BattleView.Tool.TimeManager_View")
			Battle.SceneGuide_View = reloadLua("BattleView.Sce.Guide.SceneGuide_View")
			Battle.GuideModeBase_View = reloadLua("BattleView.Sce.Guide.GuideModeBase_View")
			Battle.Scene_View = reloadLua("BattleView.Sce.Scene_View")
			Battle.SceneArrayBase_View = reloadLua("BattleView.Sce.SceneArrayBase_View")
			Battle.FightScene_View = reloadLua("BattleView.Sce.FightScene_View")
			Battle.Bullet_View = reloadLua("BattleView.Blt.Bullet_View")
			Battle.WorldSceneBase_View = reloadLua("BattleView.Sce.WorldSceneBase_View")
			Battle.Player_View = reloadLua("BattleView.Ply.Player_View")
			BufWork_View = reloadLua("BattleView.Buf.BufWork_View")
			SkillFeatures_View = reloadLua("BattleView.Ply.SkillFeatures.SkillFeatures_View")
			PlayerHeadUI_View = reloadLua("BattleView.Ply.HeadUI.PlayerHeadUI_View")

			SelectTargetTool_View = reloadLua("BattleView.Tool.SelectTargetTool_View")
			SelectTargetTool_View:init();
		--end


		self.battleFSM:init(self)
		self.battleFSM:changeState(Battle.BattleFSM.BATTLE_STATES.Idle)
	end
end

return M