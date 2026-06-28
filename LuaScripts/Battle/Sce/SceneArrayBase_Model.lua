--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-02 16:36:20
]]

--具备布阵功能的Scene基类
local SceneManager = SceneManager
---@class SceneArrayBase_Model : Scene_Model
---@field super Scene_Model
---@field tongjiData TongJiData
local M = class("SceneArrayBase_Model",Battle.Scene_Model)

function M:init()
	M.super.init(self);
	--self.maxLoopTime = 1350;
	--数据统计
    self.tongjiData = require("Battle.Data.TongjiData").new();
	self.tongjiData:init();
	self.replayData = {};
	--玩家战斗内操作数据
	self.player_battle_operations = {}
	--
	self.battleDataList = Battle.List.new();
	--战斗log，主要看每帧的同步信息
	if self.battleLog == nil then
		self.battleLog = require("Battle.Data.battleLogData").new();
	end
	--所有视图数据都在这里处理
	self.playerSetPositionFinishIndex = 0
	-- 回放修正数据
	self.replayFix = nil

	if GameUtil and GameUtil:getpPlatform() == "Editor" then
		self.collectData = require("Battle.Data.CollectData").new();
	end
end



function M:bandingEventFinish()
	M.super.bandingEventFinish( self )
	self:addEventListener_Local(Battle.EventType.VM_SceneViewSetPlayerAttr, {self,self.VM_SceneViewSetPlayerAttr})
	self:addEventListener_Local(Battle.EventType.VM_SceneViewCallBattleStart, {self,self.VM_SceneViewCallBattleStart})
end


--修改人物属性
function M:VM_SceneViewSetPlayerAttr( eventName, data )
	--设定宠物战斗数据
	self:setPetDataAttrs(self.cur_battle_data);
	--设置玩家属性
	self:setDataAttrs(self.cur_battle_data);
	self.plyMgr:playerSpawn(self.cur_battle_data)
end

--战斗开始
function M:VM_SceneViewCallBattleStart( evnetName, data )
	self:sceneBattleStart();
end

function M:enter( data )
	self.load_finish = false;
	self.sceneCanshowHp = true;
	if data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.EVIL_SHADOW or data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.DRAGONSWORD
			or data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.SORT_CHIVALROUS or data.mode == Battle.BattleGlobalConfig.BATTLE_MODE.COMMON_BATTLE then
		self.sceneCanshowHp = false
		self.sceneCanshowLV = false
	end
	self.maxTime = data.max_time or GlobalTools.base90 --战斗时间
	TimeManager:set_baseUpdateDelaTime(TimeManager.fightUpdateDelteTime)
	M.super.enter(self, data);
end

function M:initScene()
    M.super.initScene(self);
end


function M:loadFinish( data )
	M.super.loadFinish(self, data);
	
	self.load_finish = true;
	self.isArraySet = false;
	--场景AStar数据
	--self.aStar = require("Battle.Data.AStarSix").new();
	--self.aStar:init();
	self:resetUI()
	--注册场景区域
	self:registerSceneArea();
end


function M:calculateDamageHandler(eventName, data)
	local totalDamage = 0
	local enemylostHplistFix = SceneManager.curScene.plyMgr.enemylostHplistFix
	for k,v in pairs(enemylostHplistFix) do
		totalDamage = totalDamage + math.floor(GlobalTools:ToFloat(v))
	end
	--local totalDamage = GlobalTools:ToFloat(totalDamageFix)
	--totalDamage = math.floor( totalDamage )
	--玩家
	local ply = data["player"]
	--只记录boss的
	if ply.isBoss then
		--计算boss血量
		self:caculateHpBar(ply,totalDamage)
	end
end

--计算血量
function M:caculateHpBar( ply, totalDamage )
	if self.lost_hp[self.maxnum] ~= nil and totalDamage > self.lost_hp[self.maxnum] then
		ply.dmg_layer = self.maxnum
		self.maxnum = self.maxnum +1
		if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE then
			EventDispatcher:dipatchEvent("bossMaxnum",{ player = ply, maxnum =  self.maxnum, addAtk = self.hero_train_cfg["atk_add"], atk_area = self.hero_train_cfg["atk_area"]} )
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.WORLD_BOSS then
			EventDispatcher:dipatchEvent("bossMaxnum",{ player = ply, maxnum =  self.maxnum, addAtk = self.world_boss[self.param]["atk_add"], atk_area = self.world_boss[self.param]["atk_area"]} )
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
			EventDispatcher:dipatchEvent("bossMaxnum",{ player = ply, maxnum =  self.maxnum, addAtk = self.active_world_boss["atk_add"], atk_area = self.active_world_boss["atk_area"]} )
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.FIVE_ARRAY then
			EventDispatcher:dipatchEvent("bossMaxnum",{ player = ply, maxnum =  self.maxnum, addAtk = self.five_array_cfg["atk_add"] } )
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
			EventDispatcher:dipatchEvent("bossMaxnum",{ player = ply, maxnum =  self.maxnum, addAtk = self.gve_stage_cfg["atk_add"]} )
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.EVIL_SHADOW then
			EventDispatcher:dipatchEvent("bossMaxnum",{ player = ply, maxnum =  self.maxnum, addAtk = self.evil_array_cfg["atk_add"] } )
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.DRAGONSWORD then
			EventDispatcher:dipatchEvent("bossMaxnum",{ player = ply, maxnum =  self.maxnum, addAtk = self.evil_array_cfg["atk_add"] } )
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
			EventDispatcher:dipatchEvent("bossMaxnum",{ player = ply, maxnum =  self.maxnum, addAtk = self.evil_array_cfg["atk_add"] } )
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.COMMON_BATTLE then
			EventDispatcher:dipatchEvent("bossMaxnum",{ player = ply, maxnum =  self.maxnum, addAtk = self.evil_array_cfg["atk_add"] } )
		end
	end
end


function M:resetUI()
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelResetUI)
end

function  M:loadScene( data )
    M.super.loadScene(self, data);
end

function M:loadSceneItem()
	M.super.loadSceneItem(self);
end

--设定位置
function M:setPosition()
    if self:get_sceneState() == SceneManager.SceneState.SceneReadyRun or 
			self.sceneState == SceneManager.SceneState.SceneRunning then
		M.super.setPosition(self)
    end
end

function M:update(dt)
	if GameVersionConfig.OPEN_BATTLE_LOG == true then
		self.battleLog:frame_begin_write(self:get_runframe())
	end
	
	--旧版的
	if self:get_sceneState() == SceneManager.SceneState.SceneRunning then
		self.curTime = self.curTime + dt
		--游戏时间
		local gameTime = GlobalTools:ToFloat(self.maxTime - self.curTime)
		EventDispatcher:dipatchEvent("TimeUpdate",{ data = self,time = gameTime, cur_time = self.curTime, max_time = self.maxTime })
		if self.curTime >= self.maxTime then
			self:gameOver(0)
		end
		--if self:get_runframe() >= self.maxLoopTime then
		--	self:gameOver(0)
		--end

		if self.startSetCamera == true then
			for i = 1, self.plyMgr.hero_list.Count do
				local player = self.plyMgr.hero_list:get(i - 1)
				if player:checkApostle() then
					EventDispatcher:dipatchEvent("refreshHelperUI", {player = player})
				end
			end
		end
	end
end

function M:run_autoFight()
	local frame = self:get_runframe();
	if self.player_battle_operations.autofight ~= nil then
		local frameData = self.player_battle_operations.autofight[frame];
		if frameData ~= nil then
			--释放大招
			self.plyMgr:SetAutoFight(frameData.autofight);
		end
	end
end


--最后一帧才执行大招逻辑
function M:run_skill3()
	local frame = self:get_runframe();
	if self.player_battle_operations.skill ~= nil then
		local frameData = self.player_battle_operations.skill[frame];
		if frameData ~= nil then
			--释放大招
			for i = 1, frameData.list.Count do
				--玩家实例id
				local k = frameData.list:get(i-1)
				--数据类型
				local v = frameData:get(k)
				local player = self.plyMgr:getPlayerByInstanceId(v.instanceId);
				if player ~= nil then
					player:useSkill("skill3",v.params)
					self.tongjiData:addOperation( player, v.params)
				end
			end
		end
	end
end


function M:addAutoFight( autoFight )
	--同一帧播放一次大招
	if self.player_battle_operations.autofight == nil then
		self.player_battle_operations.autofight = {}
	end
	--下一帧
	local frame = self:get_runframe() + GlobalTools.base1;
	local frame_autoFight_data = self.player_battle_operations.autofight[frame]
	if frame_autoFight_data == nil then
		frame_autoFight_data = {}
		frame_autoFight_data.autofight = autoFight
		self.player_battle_operations.autofight[frame] = frame_autoFight_data;
	else
		frame_autoFight_data.autofight = autoFight
	end
end


--加入大招数据
function M:addSkill3Data( player, params )
	--同一帧播放一次大招
	if self.player_battle_operations.skill == nil then
		self.player_battle_operations.skill = {}
	end
	--帧数
	local frame = self:get_runframe() + GlobalTools.base1;
	local frameSkill3_data = self.player_battle_operations.skill[frame]
	if frameSkill3_data == nil then
		frameSkill3_data = Battle.ListMap.new()
		self.player_battle_operations.skill[frame] = frameSkill3_data;
	end
	--通过实例id 获取当前帧的大招信息
	local instanceId = player:get_playerInstanceId()
	local frameSKill3_data_player = frameSkill3_data:get(instanceId)
	if frameSKill3_data_player == nil then
		frameSKill3_data_player = {}
		--放大招的人物
		frameSKill3_data_player.instanceId = instanceId;
		--参数
		frameSKill3_data_player.params = params;
		frameSkill3_data:add(instanceId,frameSKill3_data_player);
	end
end


function M:update_unsdt(unsdt)
	M.super.update_unsdt(self,unsdt);
end

function M:updateAlways(dt)
	M.super.updateAlways(self,dt);
	--布阵设置
	if self.load_finish  then
		if self.array_data_finish then
			self:arraying_players_set();
		end
	end

	--只记录我方的操作
	if self.oneRoundBattleData ~= nil then
		--设定自动战斗逻辑
		self:replay_autoFight();
		self:replay_skill3();
	else
		--执行大招逻辑
		self:run_autoFight();
		self:run_skill3()
	end
end


function M:replay_autoFight()
	if self.oneRoundBattleData ~= nil then
		local list = self.oneRoundBattleData["autofight_operations"];
		if list ~= nil then
			local frame = self:get_runframe();
			local frameData = list[tostring(frame)]
			if frameData ~= nil then
				--Logger.logError(" 回放设置自动战斗 ["..frame.."] 自动战斗 "..tostring(frameData.autofight) )
				self.plyMgr:SetAutoFight(frameData.autofight);
			end
		end
	end
end

--回放播放大招
function M:replay_skill3()
	if self.oneRoundBattleData ~= nil then
		local list = self.oneRoundBattleData["operations"];
		if list ~= nil then
			local frame = self:get_runframe();
			local frameData = list[tostring(frame)]
			if frameData ~= nil then
				if frameData.key ~= nil then
					for i, v in ipairs(frameData.key) do
						local data = frameData.value[v];
						local player = self.plyMgr:getPlayerByInstanceId(v);
						if player ~= nil then
							player:useSkill("skill3",data.params)
						end
					end
				else
					for i, v in pairs(frameData) do
						local player = self.plyMgr:getPlayerByInstanceId(i);
						if player ~= nil then
							player:useSkill("skill3",v.params)
						end
					end
				end
			end
			
			--if frameData ~= nil then
			--	for i, v in pairs(frameData) do
			--		local player = self.plyMgr:getPlayerByInstanceId(v.instanceId);
			--		if player ~= nil then
			--			--Logger.logError(v.instanceId.." 回放~~~~~~~放大招 "..frame )
			--			player:useSkill("skill3",v.params)
			--		end
			--	end
			--end
		end
	end
end


--销毁
function M:destroy( nextScene )
	M.super.destroy(self, nextScene);
	self.tongjiData:init();
end

function M:lateUpdate( dt, unsdt )
    M.super.lateUpdate(self,dt, unsdt);
end

--设定配置属性 
function M:setConfigAttrs()
	local attacker_team = self.battleConfig["attacker_team"]
	--攻击方英雄布阵
	local atk_heros = attacker_team["heros"]
	for i = 1, self.plyMgr.hero_list.Count do
		local player = self.plyMgr.hero_list:get(i - 1)
		if player ~= nil and player.master == nil then
			local attr = atk_heros[player.index]
			self:setPlayerAttrubute(player, attr["attrs"])
			player.data:set_evo( attr["evo"] )
			player:set_playerInstanceId(tostring( 100001+player.index ));
			self.tongjiData:register(player:get_playerInstanceId(), attr, player.camp, player.index, 1)
			if self.replayFix then
				self.replayFix:registerPlayer(player)
			end
		end
	end
	--for k,v in pairs(atk_heros) do
	--	if v ~= "" then
	--		local player = self.plyMgr.hero_list:get(k)
	--		if player ~= nil then
	--			self:setPlayerAttrubute(player, v["attrs"])
	--			player.data:set_evo( v["evo"] )
	--			player:set_playerInstanceId(tostring( 100001+k ));
	--			self.tongjiData:register(player:get_playerInstanceId(), v, player.camp, k, 1)
	--		end
	--	end
	--end

	local defender_team = self.battleConfig["defender_team"]
	--攻击方英雄布阵
	local def_heros = defender_team["heros"]
	for i = 1, self.plyMgr.enemy_list.Count do
		local player = self.plyMgr.enemy_list:get(i - 1)
		if player ~= nil and player.master == nil then
			local attr = def_heros[player.index]
			self:setPlayerAttrubute(player, attr["attrs"])
			player.data:set_evo( attr["evo"] )
			player:set_playerInstanceId(tostring( 200001+player.index ));
			self.tongjiData:register(player:get_playerInstanceId(), attr, player.camp, player.index, 1)

			if self.replayFix then
				self.replayFix:registerPlayer(player)
			end
		end
	end
	--for k,v in pairs(def_heros) do
	--	if v ~= "" then
	--		local player = self.plyMgr.enemy_list:get(k)
	--		if player ~= nil then
	--			self:setPlayerAttrubute(player, v["attrs"])
	--			player.data:set_evo( v["evo"] )
	--			player:set_playerInstanceId( tostring( 200001+k ) );
	--			self.tongjiData:register(player:get_playerInstanceId(), v, player.camp, k, 1)
	--		end
	--	end
	--end
end

-- 车轮战数据组装
function M:getFormatBattleData()
	if self.tongjiData.curRoundData then
		local cur_tongji_data = self.tongjiData.curRoundData
		local result = cur_tongji_data.result or 0
		local attacker_team_id = cur_tongji_data.attacker_team.team_id
		local defender_team_id = cur_tongji_data.defender_team.team_id
		local cur_attacker_team_id = attacker_team_id
		local cur_defender_team_id = defender_team_id
		local attacker = nil
		local defender = nil
		if result == 0 then
			defender = self.cur_battle_data.defender_team
			defender.dyns = self.tongjiData:getOneBattleDynsData(self.round, 2)
			local dyns = {}
			for i, v in ipairs(defender.team) do
				dyns[v] = defender.dyns[v] or { hp_pct= 0, mp_pct = 0}
			end
			defender.dyns = dyns;
			for i = 1, self.battleDataList.Count do
				local round_data = self.battleDataList:get(i - 1)
				if round_data.attacker_team.team_id == attacker_team_id + 1 then
					attacker = round_data.attacker_team
					cur_attacker_team_id = attacker_team_id + 1
					break
				end
			end
		else
			attacker = self.cur_battle_data.attacker_team
			attacker.dyns = self.tongjiData:getOneBattleDynsData(self.round, 1)
			local dyns = {}
			for i, v in ipairs(attacker.team) do
				dyns[v] = attacker.dyns[v] or { hp_pct= 0, mp_pct = 0}
			end
			attacker.dyns = dyns;
			for i = 1, self.battleDataList.Count do
				local round_data = self.battleDataList:get(i - 1)
				if round_data.defender_team.team_id == defender_team_id + 1 then
					defender = round_data.defender_team
					cur_defender_team_id = defender_team_id + 1
					break
				end
			end
		end
		if attacker and defender then
			self.tongjiData:getRoundData( self.round + 1, cur_attacker_team_id, cur_defender_team_id)
			local one_round = {attacker_team = attacker, defender_team = defender}
			return one_round
		end
	end
end

--游戏结束
function M:gameOver( re )
	if self.startBattle == true then
		if not self.m_replay then
			if self.tongjiData.curRoundData then
				self.tongjiData.curRoundData["result"] = re;
				self.tongjiData.curRoundData.frame = self:get_runframe();
				-- 如果有修正数据
				if self.replayFix then
					if not self.replayFix.isReplay then
						self.tongjiData.curRoundData.fix = self.replayFix:getFormatData()
					end
				end
			end
		end

		if self.battleLog ~= nil and self.common ~= nil then
			if GameVersionConfig.IS_SERVER then


				--if self.round == 1 then
					self.battleLog:finish_write("ReplayData_Log_Server"..self.common.seed.."_"..self.common.seed_team .. "_" .. self.round.."__roleId__"..self.log_roleId);
					self.battleLog:finish_frame_write();
					--self.battleLog:finish_write("ReplayData_Log_Server@@@"..self.common.seed.."_"..self.common.seed_team);
					--self.battleLog:finish_frame_write();
				--end
			else
				if self.m_replay == true then
					self.battleLog:finish_write("ReplayData_Log_Client_Replay"..self.common.seed.."_"..self.common.seed_team .."_" .. tostring(self.round));
				else
					self.battleLog:finish_write("ReplayData_Log_Client"..self.common.seed.."_"..self.common.seed_team .."_".. tostring(self.round));
				end
			end
		end

		-- 每场战斗都要清理数据
		self.plyMgr:gameover(re)
		if self.isUseConfig == false then
			if self.battleDataList.Count <= 0 then
				self:gameOverNow( re );
			elseif (self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.MULT_STAGE or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GU_JIAN_MULT
			or self.mode==Battle.BattleGlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI) and re == 0 then
				self:gameOverNow( re );
			else
				if GameVersionConfig.IS_SERVER then
					if self.battle_mode == 1 then
						local one_round = self:getFormatBattleData()
						if one_round then
							self:set_sceneState(4);
							self.startBattle = false;
							self.gameover = true
							TimeTools:killModel();
							self.plyMgr:gameover(re)
							self.plyMgr:destroyAllPlayer()
							-- 由于destoryAllPlayer,此时的one_round可能已经改变
							local one_round = self:getFormatBattleData()
							self.battleDataList:insert(0, one_round)
							--self.aStar:init();
							self:battleOnce();
						else
							self:gameOverNow( re );
						end
					else
						TimeTools:killModel();
						--self.aStar:init();
						self:battleOnce();
					end
				else
					if self.m_next_battle_delay ~= true then
						self.m_next_battle_delay = true
						TimeTools:delayTime(GlobalTools.base2,function ()
							self.plyMgr:destroyAllPlayer()
							self.m_next_battle_delay = false
							--self.aStar:init();
							TimeTools:killModel();
							self:battleOnce();
						end)
					end
				end
			end
		else
			self:gameOverNow( re );
		end
	end
end

--游戏结束现在
function M:gameOverNow( re )
	self:onGameOver()
	--TablePoolUtil:init()
	local battle_data = self.replayData["battle_data"]
	if not Battle.BattleGlobalConfig.BATTLE_MODE_CFG[self.mode].pvp and not self.m_replay and battle_data ~= nil then
		local temp_battle = battle_data["battle"]
		battle_data = {battle = self.tongjiData.data}
		if temp_battle ~= nil then
			battle_data.battle.sort = temp_battle.sort
		else
			battle_data.battle.sort = 0
		end
		battle_data.battle.common = battle_data.battle.common or temp_battle.common
		battle_data.upload_data = self.tongjiData:getBattleUploadData()
		--测试数据
		self.m_test_m_replay_data = battle_data.upload_data;
	--elseif  GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA == self.mode then
	--	battle_data.upload_data = self.tongjiData:getBattleUploadData()
	--	re = battle_data.upload_data.result
	else
		if battle_data and battle_data.result then
			re = battle_data.result
		end
	end
	EventDispatcher:unRegisterEvent("calculateDamage", {self,self.calculateDamageHandler})
	GlobalTools.isbattle = true;
	self:sendEvent("battle_end", { result = re, mode = self.mode, def_data = self.m_def_data, ext_data = self.m_ext_data, battle_data = battle_data, replay = self.m_replay},"GamePanel" )
	self:set_sceneState(4)
	self.gameover = true
	self.gameResult["result"] = re
	self.gameResult["gameTime"] = 9
	TimeManager:reset()
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelGameOver)
	TimeTools:killModel();
	if self.collectData then
		self.collectData:destroy()
	end
	--collectgarbage("stop")
	--local shifang = collectgarbage("step",999999999)
	--if shifang == true then
	--	Logger.logError("释放 完成")
	--else
	--	Logger.logError("释放 未完成")
	--end
	--MemLeakCheckTools.printWeakObjMap(true);
end


function M:createBattlePlayer(data)
	--创建战斗玩家完成
	if data ~= nil then
		local attacker_team = data["attacker_team"]
		--攻击方英雄布阵
		local atk_team = attacker_team["team"]
		local atk_heros = attacker_team["heros"]
		--动态血量
		local atk_dyns = attacker_team.dyns or {}
		--Logger.logError(atk_heros,"  攻击战斗队伍  ~~~~~~~~~~ ")
		--Logger.logError(atk_dyns,"  攻击动态属性  ~~~~~~~~~~ ")
		for k,v in ipairs(atk_team) do
			--k 表示位置
			--v 表示玩家的instanceid
			if v ~= "" then
				local hero_data = atk_heros[v]
				if hero_data ~= nil then
					if self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LOCAL_ARENA 
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.HIGH_ARENA 
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.HUASHAN_SWORD 
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.RACE_ARENA 
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.MINING
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_MINING
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI
							and self.m_replay ~= true then
						--已经存在玩家管理器的第一个玩家
						local player = self.plyMgr:getHeroByIndex(k-1);
						if player ~= nil then
							--玩家的类型id 相同
							if player.playerId == hero_data.id then
								player:set_playerInstanceId(v)
								local lv = hero_data.lv;
								if hero_data.clv and hero_data.clv > 0 then
									lv = hero_data.clv;
								end
								player.data:set_level( lv );
								player.data:set_evo( hero_data.evo )
								player.heroData.buffs = hero_data.buffs
								player.heroData.mystics = hero_data.mystics
								player.heroData.mystic_buffs = hero_data.mystic_buffs
								player.heroData.seal_character_buffs = hero_data.seal_character_buffs
								player:refreshSkill( hero_data.skill )
								player:refreshTalisman()
								player.animator:reset2()
							else
								--当前玩家删除
								self.plyMgr:destoryPlayer(player);
								self:createNewPlayer(v, hero_data,1,k-1,nil,nil)
							end
						else
							local hero_dyns = atk_dyns[v] or {}
							local hp_pct = hero_dyns.hp_pct or GlobalTools.base10000
							if hp_pct > 0 then
								self:createNewPlayer(v, hero_data,1,k-1,nil,nil)
							end
						end
					else
						local hero_dyns = atk_dyns[v] or {}
						local hp_pct = hero_dyns.hp_pct or GlobalTools.base10000;
						if hp_pct > 0 then
							self:createNewPlayer(v, hero_data,1,k-1,nil,nil)
						end
					end
				else
					Logger.logError(" 玩家数据没有找到 "..v )
				end
			else
				local player = self.plyMgr:getHeroByIndex(k-1);
				if player ~= nil then
					--当前玩家删除
					self.plyMgr:destoryPlayer(player);
				end
			end
		end
		
		local defender_team = data["defender_team"]
		--Logger.logError(defender_team,"<[防守队伍]>  ")
		--防御英雄布阵
		local def_team = defender_team.team
		--防御方英雄
		local def_heros = defender_team.heros
		--动态血量
		local dyns = defender_team.dyns or {}
		--Logger.logError(def_team,"  防守战斗队伍  ~~~~~~~~~~ ")
		--Logger.logError(dyns,"  防守动态属性 ~~~~~~~~~~ ")
		for k,v in ipairs(def_team) do
			--k 表示位置
			--v 表示玩家的instanceid
			if v ~= "" then
				local enemy_data = def_heros[v]
				if enemy_data ~= nil then
					if self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LOCAL_ARENA 
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.HIGH_ARENA
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.HUASHAN_SWORD
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.RACE_ARENA
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.MINING
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_MINING
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI
							and self.m_replay ~= true then
						local player = self.plyMgr:getEnemyByIndex(k-1);
						if player ~= nil then
							if player.playerId == enemy_data.id or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
								player:set_playerInstanceId(v)
								player.heroData.buffs = enemy_data.buffs
								player.heroData.mystics = enemy_data.mystics
								player.heroData.mystic_buffs = enemy_data.mystic_buffs
								player.heroData.seal_character_buffs = enemy_data.seal_character_buffs
								player:refreshSkill( enemy_data.skill )
								player:refreshTalisman()
								player.animator:reset2()
							else
								--当前玩家删除
								self.plyMgr:destoryPlayer(player);
								self:createNewPlayer(v, enemy_data,-1,k-1,nil,nil)
							end
						else
							local hero_dyns = dyns[v] or {}
							local hp_pct = hero_dyns.hp_pct or GlobalTools.base10000
							if hp_pct > 0 then
								self:createNewPlayer(v, enemy_data,-1,k-1,nil,nil)
							end
						end
					else
						local hero_dyns = dyns[v] or {}
						local hp_pct = hero_dyns.hp_pct or GlobalTools.base10000
						if hp_pct > 0 then
							self:createNewPlayer(v, enemy_data,-1,k-1,nil,nil)
						end
					end
				else
					Logger.logError(" 玩家数据没有找到 "..v )
				end
			else
				local player = self.plyMgr:getEnemyByIndex(k-1);
				if player ~= nil then
					--当前玩家删除
					self.plyMgr:destoryPlayer(player);
				end
			end
		end
	end
	
	--服务器战斗
	--竞技场
	--高阶竞技场
	--回放

	--if self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LOCAL_ARENA and
	--				self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.HIGH_ARENA and
	--				self.m_replay ~= true then
	--	self:playerSpawnHandler()
	--end

	--目前世界boss 和 侠客试炼 和 月影传说(原五行阵) 和 邪极魅影
	if self:isBossLevel() then
		--在出生前设置数据
		for i = 1, self.plyMgr.enemy_list.Count do
			---@type PlayerModel
			local ply = self.plyMgr.enemy_list:get(i-1)
			if ply:get_master() == nil then
				ply:setBoss(true)
				ply:resetAllData() -- 如果是boss，需要重新设置boss的数据（站位信息）
			end
		end
	end
	
	--玩家创建完成，玩家出生
	self:playerSpawnHandler()
end

function M:createBattlePet(camp, data)
	if data then
		if camp == 1 then
			--------------- 攻击方宠物初始化 start --------------
			local attacker_team = data["attacker_team"]
			--攻击方英雄布阵
			local attack_pet_id = attacker_team["battle_pet"]
			local attack_pet = attacker_team["pets"]
			--动态血量
			local atk_dyns = attacker_team["pet_dyns"] or {}
			--attack_pet_id 表示玩家的instanceid
			if attack_pet_id ~= "" and attack_pet_id ~= nil then
				local pet_data = attack_pet[attack_pet_id]
				if pet_data ~= nil then
					if self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LOCAL_ARENA
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.HIGH_ARENA
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.HUASHAN_SWORD
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.RACE_ARENA
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.MINING
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_MINING
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI
							and self.m_replay ~= true then
						local curPet = self.plyMgr.attacker_petMgr.curPet
						if curPet ~= nil then
							if curPet.playerId == pet_data.id then
								curPet:set_playerInstanceId(attack_pet_id)
								local lv = pet_data.lv;
								curPet.data:set_level( lv );
								curPet.data:set_evo( pet_data.evo )
								curPet.heroData.buffs = pet_data.buffs
								curPet:refreshSkill( pet_data.skill )
							else
								--当前玩家删除
								self.plyMgr:destoryXieZhanPet(curPet);
								self:createNewPet(attack_pet_id, pet_data, camp)
							end
						else
							local hero_dyns = atk_dyns[attack_pet_id] or {}
							local hp_pct = hero_dyns.hp_pct or GlobalTools.base10000
							if hp_pct > 0 then
								self:createNewPet(attack_pet_id, pet_data,camp)
							end
						end
					else
						local hero_dyns = atk_dyns[attack_pet_id] or {}
						local hp_pct = hero_dyns.hp_pct or GlobalTools.base10000
						if hp_pct > 0 then
							self:createNewPet(attack_pet_id, pet_data,camp)
						end
					end
				else
					Logger.logError(" 宠物数据没有找到 "..attack_pet_id )
				end
			else
				local curPet = self.plyMgr.attacker_petMgr.curPet
				if curPet ~= nil then
					--当前宠物删除
					self.plyMgr:destoryXieZhanPet(curPet);
				end
			end
			--------------- 攻击方宠物初始化 end --------------
		end

		if camp == -1 then
			--------------- 防守方宠物初始化 start --------------
			local defender_team = data["defender_team"]
			--攻击方英雄布阵
			local defend_pet_id = defender_team["battle_pet"]
			local defend_pet = defender_team["pets"]
			--动态血量
			local atk_dyns = defender_team["pet_dyns"] or {}
			--defend_pet_id 表示玩家的instanceid
			if defend_pet_id ~= "" and defend_pet_id ~= nil then
				local pet_data = defend_pet[defend_pet_id]
				if pet_data ~= nil then
					if self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.LOCAL_ARENA
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.HIGH_ARENA
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.HUASHAN_SWORD
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.RACE_ARENA
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.MINING
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_MINING
							and self.mode ~= Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI
							and self.m_replay ~= true then
						local curPet = self.plyMgr.defender_petMgr.curPet
						if curPet ~= nil then
							if curPet.playerId == pet_data.id then
								curPet:set_playerInstanceId(defend_pet_id)
								local lv = pet_data.lv;
								curPet.data:set_level( lv );
								curPet.data:set_evo( pet_data.evo )
								curPet.heroData.buffs = pet_data.buffs
								curPet:refreshSkill( pet_data.skill )
							else
								--当前玩家删除
								self.plyMgr:destoryXieZhanPet(curPet);
								self:createNewPet(defend_pet_id, pet_data, camp)
							end
						else
							local hero_dyns = atk_dyns[defend_pet_id] or {}
							local hp_pct = hero_dyns.hp_pct or GlobalTools.base10000
							if hp_pct > 0 then
								self:createNewPet(defend_pet_id, pet_data,camp)
							end
						end
					else
						local hero_dyns = atk_dyns[defend_pet_id] or {}
						local hp_pct = hero_dyns.hp_pct or GlobalTools.base10000
						if hp_pct > 0 then
							self:createNewPet(defend_pet_id, pet_data,camp)
						end
					end
				else
					Logger.logError(" 宠物数据没有找到 "..defend_pet_id )
				end
			else
				local curPet = self.plyMgr.defender_petMgr.curPet
				if curPet ~= nil then
					--当前宠物删除
					self.plyMgr:destoryXieZhanPet(curPet);
				end
			end
			--------------- 防守方宠物初始化 end --------------
		end
		
	end
end

--创建新宠物
function M:createNewPet(instanceID, petData, camp )
	if not petData then return end
	petData.playerType = "pet"
	local player = self.plyMgr:createPlayer(petData,camp,0)
	if player ~= nil then
		player:set_playerInstanceId(instanceID)
	end
	self:createPlayerFinish();
	return player
end

--设定宠物战斗数据
function M:setPetDataAttrs(data)
	--攻击方英雄
	if data ~= nil then
		local attacker_team = data["attacker_team"]
		--攻击方英雄布阵
		local attack_pet_id = attacker_team["battle_pet"]
		local attack_pet = attacker_team["pets"]
		--attack_pet_id 表示玩家的instanceid
		if attack_pet_id ~= "" and attack_pet_id ~= nil then
			local pet_data = attack_pet[attack_pet_id]
			if pet_data ~= nil then
				local curPet = self.plyMgr.attacker_petMgr.curPet
				if curPet ~= nil then
					curPet:set_playerInstanceId(attack_pet_id);
					--注册统计玩家数据
					self.tongjiData:registerPet(attack_pet_id, pet_data, 1, 0,self.round)
				else
					--Logger.logError(" Attacker InstanceId = " ..v .." 统计数据注册失败 ")
				end
			end
		end

		if attack_pet_id ~= "" and attack_pet_id ~= nil then
			local pet_data = attack_pet[attack_pet_id]
			local curPet = self.plyMgr.attacker_petMgr.curPet
			if curPet ~= nil then
				self:setPlayerAttrubute(curPet, pet_data.attrs)
			else
				--Logger.logError(" Attacker InstanceId = " ..v .." 统计数据注册失败 ")
			end
		end

		local defender_team = data["defender_team"]
		--防御英雄布阵
		local def_pet_id = defender_team["battle_pet"]
		--防御方英雄
		local def_pet = defender_team["pets"]
		--def_pet_id 表示玩家的instanceid
		if def_pet_id ~= "" and def_pet_id ~= nil then
			local pet_data = def_pet[def_pet_id]
			if pet_data ~= nil then
				local curPet = self.plyMgr.defender_petMgr.curPet
				if curPet ~= nil then
					curPet:set_playerInstanceId(def_pet_id);
					--注册统计玩家数据
					self.tongjiData:registerPet(def_pet_id, pet_data, -1, 0,self.round)
				else
					--Logger.logError(" Attacker InstanceId = " ..v .." 统计数据注册失败 ")
				end
			end
		end

		if def_pet_id ~= "" and def_pet_id ~= nil then
			local pet_data = def_pet[def_pet_id]
			local curPet = self.plyMgr.defender_petMgr.curPet
			if curPet ~= nil then
				self:setPlayerAttrubute(curPet, pet_data.attrs)
			else
				--Logger.logError(" Attacker InstanceId = " ..v .." 统计数据注册失败 ")
			end
		end
	end
end

function M:createConfigPet(camp, pet)
	if not pet then
		return
	end
	local petData = CustomRequire("Battle.BattleData.PetDataTemplate")(pet)
	if not petData then return end
	petData.playerType = "pet"
	local position = {x = -3.3, y = 0, z = -5.5}
	for i, v in pairs(position) do
		position[i] = GlobalTools:CommonToFix(v)
	end
	local petOid = string.format("pet-%s_%s", tostring(petData.id), tostring(camp))
	petData.oid = petOid
	local player = self.plyMgr:createPlayer(petData, camp, 0)
	if player ~= nil then
		player:set_playerInstanceId(petData.oid)
	end
end

function M:playerSpawnHandler()
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelPlayerSpawn, nil, function()
		--设定宠物战斗数据
		self:setPetDataAttrs(self.cur_battle_data);
		--设定玩家属性
		self:setDataAttrs(self.cur_battle_data);
		--玩家出生
		self.plyMgr:playerSpawn(self.cur_battle_data)
		--战斗开始
		self:sceneBattleStart();
	end)
end

--- 添加攻守放buff
function M:addCommonBuff()

	--为平衡或其他原因，可以通过配置给所有角色加一个buff
	local commonBuff = ConfigManager:getBattleCommonValueById(10002, {}, false)
	if type(commonBuff) == "table" and #commonBuff > 0 then
		for i, v in ipairs(commonBuff) do
			local list = self.plyMgr:getPlayers(1)
			list:safeWalkInverted(function(ply)  
				ply.bufMgr:addBufById(v, ply)
			end)

			local list = self.plyMgr:getPlayers(-1)
			list:safeWalkInverted(function(ply)
				ply.bufMgr:addBufById(v, ply)
			end)
		end
	end
	
	
	--攻击buf
	if self.attacker_buffs ~= nil then
		local list = self.plyMgr:getPlayers(1)
		for i = 1, list.Count do
			---@type PlayerModel
			local ply = list:get(i - 1);
			for i, v in ipairs(self.attacker_buffs) do
				ply.bufMgr:addBufById(v, ply)
			end
		end
	end
	--防守buf
	if self.defender_buffs ~= nil then
		local list = self.plyMgr:getPlayers(-1)
		for i = 1, list.Count do
			---@type PlayerModel
			local ply = list:get(i - 1);
			for i, v in ipairs(self.defender_buffs) do
				ply.bufMgr:addBufById(v, ply)
			end
		end
	end	
end

--- 设置每回合队伍的法阵buffs
function M:addTeamBuffs()
	--攻击buf
	if self.attacker_buffsList ~= nil then
		local list = self.plyMgr:getPlayers(1)
		for i = list.Count, 1, -1 do
			---@type PlayerModel
			local ply = list:get(i - 1);
			for k, v in ipairs(self.attacker_buffsList) do
				ply.bufMgr:addBufById(v, ply)
			end
		end
	end
	--防守buf
	if self.defender_buffsList ~= nil then
		local list = self.plyMgr:getPlayers(-1)
		for i = list.Count, 1, -1 do
			---@type PlayerModel
			local ply = list:get(i - 1);
			for k, v in ipairs(self.defender_buffsList) do
				ply.bufMgr:addBufById(v, ply)
			end
		end
	end
end

--创建新玩家 
function M:createNewPlayer(instanceID, hero_data, camp, index, userPos, master )
	local player = self.plyMgr:createPlayer(hero_data,camp,index,userPos,master)
	if camp == -1 then
		if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.WORLD_BOSS or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
			self:setBossDir(1)
		end
	end
	if player ~= nil then
		player:set_playerInstanceId(instanceID)
	end
	return player
end


function M:createStoryPlayers( mode, hero_id_list, callBack )
	local heroIndex = 0;
	if mode == Battle.BattleGlobalConfig.BATTLE_MODE.STAGE and hero_id_list ~= nil and next( hero_id_list ) then
		--创建英雄
		for i = 1, 5 do
			local v = hero_id_list[i];
			if v ~= 0 then
				local hero_data = { id = v, lv = 1, evo = 5 }
				self.plyMgr:createPlayer(hero_data,1,i-1,nil,nil)
				if callBack ~= nil then
					callBack();
				end
			end
		end
		--创建敌人
		for i = 6, 10 do
			local v = hero_id_list[i];
			if v ~= 0 then
				local hero_data = { id = v, lv = 1, evo = 5 }
				self.plyMgr:createPlayer(hero_data,-1,i-6,nil,nil)
			end
		end
	else
		if callBack ~= nil then
			callBack();
		end
	end
end


--后面移动到场景中的人
--一般剧情需要
--heroid = 英雄id
--index = 英雄站位
--camp = 英雄阵营
--type = 移动类型
function M:moveToScene( hero_id, index, camp, type, finish )
	local playerData = { id = hero_id, evo = 5, isStoryPlayer = true, moveType = type }
	local player = self.plyMgr:createPlayer(playerData,camp,index,function(ply)
		ply.storyMoveFinish = finish;
		ply:spawn();
	end)
end



--这里决定了，人物移动的时候摄像机是否移动
function M:setPositionFinish()
	self.playerSetPositionFinishIndex = self.playerSetPositionFinishIndex + 1;
	if self.playerSetPositionFinishIndex >= self.plyMgr.hero_list.Count then
		local ply = self.plyMgr.hero_list:get(0);
		local pos = self:findSpawnPosition(1, ply.index)
		local offset = GlobalTools:ToFloat(pos.x);
		self.cameraController.OpenTarget = self.plyMgr.hero_list:get(0).tran;
		self.cameraController:SetOffset(offset)
	end
end


function M:playerSpawnFinish()
	self:updatePlyUI();
end

function M:sceneBattleStart()
	if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI then --宠物斗技
		self.battleFSM:changeState(Battle.BattleFSM.BATTLE_STATES.PetContest)
	else
		self.battleFSM:changeState(Battle.BattleFSM.BATTLE_STATES.Battle) -- 宠物协战
	end
end

---英雄对战（原来的对战）/ 宠物斗技对战阶段
function M:playerBattleStart()
	self.tongjiData:setTeamRelic(self.attacker_relicList, 1)
	self.tongjiData:setTeamRelic(self.defender_relicList, -1)
	self.tongjiData:setTeamBuffs(self.attacker_buffsList, 1)
	self.tongjiData:setTeamBuffs(self.defender_buffsList, -1)
	self:set_sceneState(3)
	self:set_runframe( GlobalTools.base0 );
	self.curTime=0
	self:addCommonBuff()
	self.plyMgr:startBattle();
	-- 每回合的法阵buff加成
	self:addTeamBuffs()
	self.startBattle = true;
	self:sendEvent("start_battle_beging",nil,"GamePanel")
	TimeManager:set_timeSpeed( TimeManager:get_localSpeed() )
end

--配置战斗
function M:battleConfigCall()
	--LoopTime 就是帧数
	self:set_runframe( GlobalTools.base0 )
	self.linkSceneId = -1;
	--把人物全部销毁
	self.plyMgr:destroy();

	self.attacker_relicList = self.battleConfig["attacker_team"].relic
	self.defender_relicList = self.battleConfig["defender_team"].relic
	
	--法宝
	self.plyMgr.attacker_relicMgr:clear()
	self.plyMgr.defender_relicMgr:clear()
	if self.attacker_relicList ~= nil then
		for k,v in ipairs(self.attacker_relicList) do
			self.plyMgr.attacker_relicMgr:add(v)
		end
	end
	if self.defender_relicList ~= nil then
		for k,v in ipairs(self.defender_relicList) do
			self.plyMgr.defender_relicMgr:add(v)
		end
	end
	
	--if self.attacker_relicList ~= nil then
	--	for k,v in ipairs(self.attacker_relicList) do
	--		v["param"]["floor"] = self.param
	--		self.plyMgr.attacker_relicMgr:add(v["cid"], v["param"] or {})
	--	end
	--end
	--if self.defender_relicList ~= nil then
	--	for k,v in ipairs(self.defender_relicList) do
	--		v["param"]["floor"] = self.param
	--		self.plyMgr.defender_relicMgr:add(v["cid"], v["param"] or {})
	--	end
	--end
	-- --通过数据创建玩家
	--英雄最多5个位置
    --英雄生成列表 =====================================
    self:createConfig();
	--if self.aStar ~= nil then
	--	self.aStar:init();
	--end
	--如果是回放 战斗数据
	if self.m_replay then
		self.oneRoundBattleData = self.tongjiData:getOperationData();
	end
	-- for k,v in pairs(self.relicList) do
	-- 	v["param"]["floor"] = self.param
	-- 	self.plyMgr.relicMgr:add(v["cid"], v["param"])
	-- end
	--删除特效和摄像机
	-- 1 = DeleteEffectAndCamera
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelHandleEffectAndCamera,{ type = 1 } )
	
	--设定速度
	TimeManager:set_timeSpeed(TimeManager:get_localSpeed());
	EventDispatcher:dipatchEvent("addSkillBtns")
end

--创建配置数据
function M:createConfig( startBattle )
	-- 队伍数据
	self.plyMgr:createTeam()
	
	--英雄
	local heros = self.battleConfig["heros"]
	for k,v in pairs(heros) do
		local p_id = tonumber( v["Id"] )
		local PosIndex = tonumber( v["PosIndex"] )
		local data = self.battleConfig["attacker_team"]["heros"][k]
		local mystics = {}
		local mystic_buffs = {}
		local seal_character_buffs = data.seal_character_buffs
		for k, v in pairs(data.mystics or {}) do
			if v ~= 0 then
				mystics[k] = {id = v}
				for m, n in pairs(data.mystic_buffs or {}) do
					if n and n ~= 0 then
						mystic_buffs[tostring(v)] = {n}
					end
				end
			end
		end
		local plusSkillTab = {data.plusSkillId1 or 0, data.plusSkillId2 or 0}
		local oldSkillTab = {data.oldSkillId1 or 0, data.oldSkillId2 or 0}
		local power_win = self.battleConfig.douJiWin and 1 or 0
		local playerData = { id = p_id, evo = data.evo, skin = v["skin"],
							 lv = data.lv or 300,
							 fate_level = data.fate_level or 0, 
							 mystics = mystics,
							 mystic_buffs = mystic_buffs,
							 power_win = power_win,
							 seal_character_buffs = seal_character_buffs,
							 plusSkillTab = plusSkillTab,
							 oldSkillTab = oldSkillTab,
							 plus_level = data.plus_level or 0,
							 resonance_lv = data.resonance_lv or 0,
		}
		self.plyMgr:createPlayer(playerData,1,PosIndex, nil, nil)
	end
	--敌人
	local enemys = self.battleConfig["enemys"]
	for k,v in pairs(enemys) do
		local p_id = tonumber( v["Id"] )
		local PosIndex = tonumber( v["PosIndex"] )
		local data = self.battleConfig["defender_team"]["heros"][k]
		local mystics = {}
		local seal_character_buffs = data.seal_character_buffs
		for k, v in pairs(data.mystics or {}) do
			if v ~= 0 then
				mystics[k] = {id = v}
			end
		end
		local plusSkillTab = {data.plusSkillId1 or 0, data.plusSkillId2 or 0}
		local oldSkillTab = {data.oldSkillId1 or 0, data.oldSkillId2 or 0}

		local playerData = { id = p_id, evo = data.evo, skin = v["skin"],
							 lv = data.lv or 300,
							 fate_level = data.fate_level or 0,
							 mystics = mystics,
							 seal_character_buffs = seal_character_buffs,
							 plusSkillTab = plusSkillTab,
							 oldSkillTab = oldSkillTab,
							 plus_level = data.plus_level or 0,
							 resonance_lv = data.resonance_lv or 0,
		}
		self.plyMgr:createPlayer(playerData,-1,PosIndex,nil, nil)
	end


	self:createConfigPet(1, self.battleConfig["attacker_team"]["pet"])
	self:createConfigPet(-1, self.battleConfig["defender_team"]["pet"])
	self:createConfigFinish();
	if startBattle ~= nil then
		self:battleConfigStart();
	else
		if SceneManager.curScene.buzheng == false then
			self:battleConfigStart();
		end
	end
end


function M:battleConfigStart()
	self.checkBattle = 1;
	--发送增加技能按钮
	EventDispatcher:dipatchEvent("addSkillBtns")
	--设置玩家属性
	self:setConfigAttrs();
	--玩家出生
	self.plyMgr:playerSpawn()
	--发送配置战斗开始
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelConfigStart, nil,  function()
		self:sceneBattleStart();
	end)
end


function M:createConfigFinish()
	--进入运行阶段
	self:set_sceneState(2)
	self.curTime = 0;
	if self.spawnCount <= 0 then
		self:playerSpawnFinish()
	end
	if self.array_callBack ~= nil then
		self.array_callBack()
	end
end

--设定战斗数据
function M:setDataAttrs(data)
	--攻击方英雄
	if data ~= nil then
		local attacker_team = data["attacker_team"]
		--攻击方英雄布阵
		local atk_team = attacker_team["team"]
		local atk_heros = attacker_team["heros"]
		for k,v in pairs(atk_team) do
			--k 表示位置
			--v 表示玩家的instanceid
			if v ~= "" then
				local hero_data = atk_heros[v]
				local player = self.plyMgr:getPlayerByInstanceId(v)
				if player ~= nil then
					player:set_playerInstanceId(v);
					player.data:set_evo( hero_data.evo or 1 )
					--注册统计玩家数据
					self.tongjiData:register(player:get_playerInstanceId(), hero_data, player.camp, k-1,self.round)

					if self.replayFix then
						self.replayFix:registerPlayer(player)
					end
				else
					--Logger.logError(" Attacker InstanceId = " ..v .." 统计数据注册失败 ")
				end
			end
		end

		local atk_heros = attacker_team["heros"]
		for k,v in pairs(atk_team) do
			--k 表示位置
			--v 表示玩家的instanceid
			if v ~= "" then
				local hero_data = atk_heros[v]
				local player = self.plyMgr:getPlayerByInstanceId(v)
				if player ~= nil then
					self:setPlayerAttrubute(player, hero_data.attrs)
				else
					--Logger.logError(" Attacker InstanceId = " ..v .." 统计数据注册失败 ")
				end
			end
		end

		local defender_team = data["defender_team"]
		--防御英雄布阵
		local def_team = defender_team["team"]
		--防御方英雄
		local def_heros = defender_team["heros"]
		for k,v in pairs(def_team) do
			--k 表示位置
			--v 表示玩家的instanceid
			if v ~= "" then
				local enemy_data = def_heros[v]
				local player = self.plyMgr:getPlayerByInstanceId(v)
				if player ~= nil then
					player:set_playerInstanceId(v)
					player.data:set_evo( enemy_data.evo or 1 )
					--注册统计玩家数据
					self.tongjiData:register(player:get_playerInstanceId(), enemy_data, player.camp, k-1,self.round)
					if self.replayFix then
						self.replayFix:registerPlayer(player)
					end
				else
					--Logger.logError(" Defender InstanceId = " ..v .." 统计数据注册失败 ")
				end
			end
		end

		local def_heros = defender_team["heros"]
		for k,v in pairs(def_team) do
			--k 表示位置
			--v 表示玩家的instanceid
			if v ~= "" then
				local enemy_data = def_heros[v]
				local player = self.plyMgr:getPlayerByInstanceId(v)
				if player ~= nil then
					self:setPlayerAttrubute(player, enemy_data.attrs)
				else
					--Logger.logError(" Defender InstanceId = " ..v .." 统计数据注册失败 ")
				end
			end
		end
	end
end

--布阵创建玩家数据完成
function M:createPlayerAndEnemyFinish()
	
	--重置创建完成bool值
	self.create_player_finish = false;
	self.create_enemy_finish = false;
	
	self.playerSetPositionFinishIndex = 0;
	
	--销毁统计数据
	self.tongjiData:destroy()
	
	--
	self.curTime = 0;
	--进入运行阶段

	--是否布阵是移动进入
	self.buzhengMove = false;

	if self.plyMgr.hero_list.Count <= 0 then
		self.buzhengMove = false;
	else
		if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.STAGE or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.MULT_STAGE then
			local level = UserDataManager:getBattleStage();
			self.chapter = ConfigManager:getCfgByName("stage")[level];
			if self.chapter.fly_enter == 1 then
				self.buzhengMove = true;
			else
				self.buzhengMove = false;
			end
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
			local level = UserDataManager:getBattleStage();
			self.chapter = ConfigManager:getCfgByName("stage")[level];
			if self.chapter.fly_enter == 1 then
				self.buzhengMove = true;
			else
				self.buzhengMove = false;
			end
		end
	end
	
	--布阵移动
	if self.buzhengMove == true then
		self.gameover = false;
		self.plyMgr:startAiEngineAndAnimator(true);
		--self.cameraController:StartOpenMove();
	else
		self.gameover = true;
		self.plyMgr:startAiEngineAndAnimator(false);
		self:updatePlyUI();
	end
	
	if self.array_callBack ~= nil  then
		self.array_callBack()
	end
end

--通知视图层阵型更新-更新阵型
function M:updateBattleDeployment( data )
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelUpdateDeployment, data);
end


function M:updatePlyUI()
	if SceneManager.lastScene == SceneManager.SceneID.WuXingZhenScene then
		local enemy_ply;
		if self.plyMgr.enemy_list.Count > 0 then
			enemy_ply = self.plyMgr.enemy_list:get(0)
		end
		--0为无关系，1为克制，-1为被克制
		if enemy_ply ~= nil then
			for i = 1, self.plyMgr.hero_list.Count do
				local ply = self.plyMgr.hero_list:get(i-1)
				local result = GlobalTools:checkRace(ply, enemy_ply)
				if result == 1 then
					ply:CreateEffect("Buff_XiangKe_001")
				end
			end
		end
	end
	TimeTools:delayTime(GlobalTools.base1,function ()
		self:sendEvent("showFormation",nil,"Formation")
	end)
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelUpdatePlayerUI)
end


--data	   玩家数据
--mode	   模式
--def_data 防守方数据
function M:createPlayerAndEnemy()
	--布阵数据
	self:createPlayerTeam(self.m_array_data, true, true);
	local data,_ = UserDataManager.pet_data:getPetDataById(self.attacker_pet_id)
	if self.defender_pet_id and self.m_def_data.pets and next(self.m_def_data.pets) then
		local def_data = self.m_def_data.pets[self.defender_pet_id]
		self:createNewPet(self.defender_pet_id, def_data, -1)
	end
	local def_data,_ = UserDataManager.pet_data:getPetDataById(self.defender_pet_id)
	self:createNewPet(self.attacker_pet_id, data, 1)
	local battle_id = self.m_ext_data.battle_id or -1
	local formation_index = self.m_ext_data.formation_index or nil
	local battle_mode_cfg_item = Battle.BattleGlobalConfig.BATTLE_MODE_CFG[self.mode]
	if battle_mode_cfg_item then
		local create_enemy_type = battle_mode_cfg_item.create_enemy_type
		if create_enemy_type == 1 then -- 通过battle_id创建敌人
			--创建敌人队伍
			if GameVersionConfig.USE_LOCAL_BATTLE_DATA then
				self:createEnemyByData(self.m_def_data, true)
			else
				self:createEnemyTeam(battle_id, true, battle_mode_cfg_item.create_cfg_name, formation_index)
			end
		elseif create_enemy_type == 2 then -- 通过def_data创建敌人
			if self.m_ext_data.boss_pos ~= nil and self.m_ext_data.boss_size ~= nil then
				self.stageBossData = { index = self.m_ext_data.boss_pos, scale = GlobalTools:CommonToFix(self.m_ext_data.boss_size) }
			end
			--创建敌人队伍
			self:createEnemyByData(self.m_def_data, true)
		elseif  create_enemy_type == 3 then --  多阵容创建敌人
			if self.m_show_def_data == 0 then
				local temp_def_data = {}
				local formation_index = self.m_def_data.formation_index or 1
				if Battle.BattleGlobalConfig.BATTLE_MODE.ZF_ARENA_MUL == self.mode or Battle.BattleGlobalConfig.BATTLE_MODE.ZF_ARENA == self.mode then
					if self.m_def_data.teams then
						temp_def_data.team = self.m_def_data.teams[formation_index] or {}
					else
						temp_def_data.team = self.m_def_data.team or {}
					end
				elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.HERO_BOSS_PVP then
					temp_def_data.team = self.m_def_data.team
				else
					temp_def_data.team = self.m_def_data.teams[formation_index] or {}
				end
				temp_def_data.heros = self.m_def_data.heros
				self:createEnemyByData(temp_def_data, true)
			else
				self:createEnemyByData({  }, true)
			end
		else
			if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND then
				self:createLegendEnemyTeam(battle_id)
			else
				self:createEnemyFinish()
			end
		end
	else
		Logger.logError(self.mode, "createPlayerAndEnemy mode is error : ")
		self:createEnemyFinish()
	end
end

--给准备布阵数据
function M:arraying_players(data, mode, def_data, assist_heros, legend_heros, ext_data,show_def_data, callBack)
	--布阵数据
	self:readyArrayData(data, mode, def_data, assist_heros, legend_heros, ext_data,show_def_data)
	--布阵数据是否准备完成
	self.array_data_finish = true;
	--布阵完成
	self.array_callBack = callBack;
	--把所有延迟函数都kill掉
	TimeTools:killModel();

	if self.load_finish == true then
		self:arraying_players_set();
	end
end


--准备布阵数据
function M:readyArrayData( data, mode, def_data, assist_heros, legend_heros, ext_data,show_def_data )
	local array_data = {};
	array_data.data = data;
	array_data.def_data = def_data;
	array_data.mode = mode;
	if GameVersionConfig.USE_LOCAL_BATTLE_DATA == true then
		if mode == Battle.BattleGlobalConfig.BATTLE_MODE.HIGH_ARENA or mode == Battle.BattleGlobalConfig.BATTLE_MODE.HUASHAN_SWORD then -- 高阶竞技场
			local formation_index = def_data.formation_index or 1
			array_data = BattleDataManager:getMulArrayData(nil, formation_index);
		else
			array_data = BattleDataManager:getArrayData();
		end
	end
	
	--布阵数据
	self.m_array_data = array_data.data;
	self.attacker_pet_id = ext_data.m_pet;
	--协战宠物 敌方
	self.defender_pet_id = ext_data.d_pet;
	--战斗模式
	self.mode = array_data.mode or 0;
	-- 防守阵容
	self.m_def_data = array_data.def_data or {};
	--助阵英雄
	self.m_assist_heros = assist_heros or {};
	--江湖传说英雄
	self.m_legend_heros = legend_heros or {};
	--扩展数据
	self.m_ext_data = ext_data or {};
	--是否显示敌方英雄
	self.m_show_def_data = show_def_data
	--回放用的数据
	if self.replayData["arraying_data"] == nil then
		self.replayData["arraying_data"] = {}
		self.replayData["arraying_data"]["atk_team"] = self.data;
		self.replayData["arraying_data"]["mode"] = self.mode;
		self.replayData["arraying_data"]["def_team"] = self.m_def_data;
	end

	--更新布阵信息
	self:updateBattleDeployment(self.m_ext_data);
end


--将布阵数据用到布阵中
function M:arraying_players_set()
	--场景状态
	self:set_sceneState(2)
	--是否开始了战斗，布阵还没有开始战斗
	self.startBattle = false;
	self.buzheng = true;
	--布阵开始
	self.array_data_finish = false;
	--先把所有玩家移除
	self.plyMgr:destroy();
	--通知视图层 -- 发送开始布阵
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelArray, {config = self.isUseConfig, ext_data = self.m_ext_data, data = self.m_array_data})
	if self.isUseConfig == false then
		self:createPlayerAndEnemy()
	else
		self:createConfig();
	end
end

---根据战斗版本号做一些特殊设置
function M:initBattleVersionConfig(data, replay)
	-- 特殊兼容 在低于v1.3.0时，使用老版的战斗公式
	self.USE_NEW_DIS_ATD_DES_FORMULA = true

	if replay then
		local replayVersion = data.battle.cli_ver or "v1.2.28" -- 加入此功能时的版本，之后的版本号升级到v1.3.1+
		-- 判断内伤加深公式
		local flag = BattleTool:compareBattleVersion("v1.3.0", replayVersion)
		if flag == 1 then	-- 使用旧版公式
			self.USE_NEW_DIS_ATD_DES_FORMULA = false
		end
	end
end

--战斗开始
--数据配置所有玩家的攻击力和队伍
function M:battleStart( data, round, replay, fivePos, add_round )
	self:initBattleVersionConfig(data, replay)
	self.battleFSM:changeState(Battle.BattleFSM.BATTLE_STATES.Idle)

	if self.collectData then
		self.collectData:clear()
	end
	self.fivePos = fivePos or -1
	if self.fivePos == 0 then
		self.sceneCanshowHp = false;
		Logger.logError(" 不显示血条 ~~~~~~~~~~~~~~~~ ")
	end
	--放大招数据
	self.player_battle_operations = {}
	self.buzheng = false;
	self.startBattle = false;
	--战斗log，主要看每帧的同步信息
	if self.battleLog ~= nil then
		self.battleLog:init();
		self.log_roleId=data.battle.common.attacker_user.uid
	end
	--统计数据
	if self.tongjiData ~= nil then
		self.tongjiData:init();
	end
	
	--回放
	if replay ~= nil then
		self.m_replay = replay
	else
		self.m_replay = false
	end

	if Battle.BattleGlobalConfig.USE_REPLAY_FIX then
		self.replayFix = require("Battle.Data.ReplayFixData"):new()
		--self.replayFix:init(self.m_replay, )
		self.replayFix:init()
	end

	-- 初始化场景的战斗数据,例如记录的boss损失血量层数
	self:initBattleData()

	--local json = Json.encode(data)
	--io.writebattlelog("battle_data",json)
	
	--战斗数据
	if GameVersionConfig.USE_LOCAL_BATTLE_DATA == true then
		if self.m_replay == true then
			data = BattleDataManager:getBattleReplayData();
			if self.m_test_m_replay_data ~= nil then
				--Logger.logError( data.battle.output.rounds[1]," 原来的数据 ")
				--Logger.logError( self.m_test_m_replay_data.rounds[1]," 原来的数据计算数据 ")
				data.battle.output.rounds[1].operations = self.m_test_m_replay_data.rounds[1].operations;
				data.battle.output.rounds[1].autofight_operations = self.m_test_m_replay_data.rounds[1].autofight_operations;
			end
		else
			data = BattleDataManager:getBattleData();
		end
	end
	
	--战斗开始
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelBattleStart)
	--回放数据
	self.replayData.battle_data = data;
	--统计数据
	self.tongjiData.replay = self.m_replay;
	--是否使用配置
	if self.isUseConfig then
		Logger.log(" 使用配置数据 ~~~ 战斗开始 ~~~~~~~~~~~~~~~~~~ ")
		--配置战斗，固定种子50
		WRandom:setSeed(50, -1, false)
		self.mode = Battle.BattleGlobalConfig.BATTLE_MODE.STAGE;
		if self.battleConfig.douJiOpen then
			self.mode = Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI
		end
		self:battleConfigCall();
	else
		Logger.log(" 使用常规数据 ~~~ 战斗开始 ~~~~~~~~~~~~~~~~~~ ")
		--回合数
		if self.m_replay then
			self.round = round or 1
		else
			self.round = 0
		end
		self.m_add_round = add_round
		--给伪随机数设定种子
		self:readyBattleData( data )
		--如果是高阶竞技场 和 普通竞技场 直接设置成 自动战斗
		if Battle.BattleGlobalConfig.BATTLE_MODE_CFG[self.mode].pvp then
			--通知UI
			self:sendEvent("battleOnce",{ round = 0 },"GamePanel")
		end
		-- 宠物斗技有 比斗气 阶段  需要 场景每次重新初始化状态
		if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI then
			self:set_sceneState( SceneManager.SceneState.SceneInit )
		end
		--第一次战斗
		self:battleFrist();
	end
end

-- 初始化场景的战斗数据,例如记录的boss损失血量层数
function M:initBattleData()
	self.maxnum = 1
end

--准备战斗数据
function M:readyBattleData( data )
	--清空~战斗数据列表
	self.battleDataList:clear();
	local battle = data.battle
	--local jsonStr = Json.encode(battle);
	--if self.m_replay then
	--	io.writebattlelog("battleStartData_replay",jsonStr)
	--else
	--	io.writebattlelog("battleStartData",jsonStr)
	--end
	self.mode = battle.sort
	
	self:setMode(self.mode)
	self.common = battle.common
	--战斗类型，0为常规战斗，1为连续战斗，2为无双模式，3为生存模式
	self.battle_mode = self.common.battle_mode or 0
	self.checkBattle = battle.check_battle or 0;
	local seed = self.common.seed
	local seedTeam = self.common.seed_team
	--法宝
	self.attacker_relicList = self.common.attacker_relics
	self.defender_relicList = self.common.defender_relics
	--遗物
	self.attacker_heirloom = self.common.attacker_heirloom
	self.defender_heirloom = self.common.defender_heirloom
	--侠影试炼buff
	self.attacker_buffs = self.common.attacker_buffs
	self.defender_buffs = self.common.defender_buffs
	
	--Logger.logError(self.attacker_relicList," 服务器数据 attacker_relicList ")
	--Logger.logError(self.defender_relicList," 服务器数据 defender_relicList ")
	
	self.param = self.common.param
	self:setParam(self.common)
	self.plyMgr.attacker_element = self.common.attacker_element
	self.plyMgr.defender_element = self.common.defender_element
	
	--重新赋值统计数据
	self.tongjiData.data.common = self.common
	self.tongjiData.mode = self.mode
	--Logger.log(" 随机种子 seed "..seed.." seedTeam "..seedTeam )
	--设定种子
	WRandom:setSeed(seed, seedTeam, false)
	
	--客户端的输入
	local client_input = battle.client_input;
	
	--服务器输出
	local output = battle.output;
	--Logger.logError(output," 回放数据 ~~~~ ")
	
	--准备战斗数据
	if self.m_replay and self.round ~= 0 then
		self.battleDataList:add(output.rounds[self.round]);
	else
		if client_input ~= nil then
			for k,v in ipairs(client_input) do
				self.battleDataList:add(v);
			end
		else
			for k,v in ipairs(output.rounds or {}) do
				self.battleDataList:add(v);
			end
		end
	end
end

--所有方是否可以自动放大
function M:canAutoUseBigSkillAll()
	--if self.checkBattle == 1 then
	--	return false;
	--end
	--if self.m_replay == true then
	--	return false;
	--end
	return true;
end

--我方是否可以自动放大
function M:canAutoUseBigSkillHero()
	--不是PVP
	if Battle.BattleGlobalConfig.BATTLE_MODE_CFG[self.mode].isAuto ~= true then
		return self.plyMgr.isAutoFight;
	end
	return true;
end

---根据战斗数据mode返回战斗设置
function M:getBattleModeCfg()
	local cfg = Battle.BattleGlobalConfig.BATTLE_MODE_CFG[self.mode]
	if cfg.showSkill3Effect == nil then
		cfg.showSkill3Effect = true
		Logger.logError(string.format("%s 必须设置showSkill3Effect属性", tostring(self.mode)))
	end
	return cfg
end


--战斗第一次
function M:battleFrist()
	if self.battleDataList.Count > 0 then
		self:battleOnce();
	end
end

--循环战斗多次,战斗一次
function M:battleOnce()
	--LoopTime 就是帧数
	--重新设置关键帧
	self:set_runframe( GlobalTools.base0 )
	
	if self.battleLog ~= nil then
		self.battleLog:init();
	end

	local seed = self.common.seed
	local seedTeam = self.common.seed_team
	--设定种子
	WRandom:setSeed(seed, seedTeam, false)
	
	self.gameover = false;
	if not self.m_replay or self.m_add_round then
		self.round = self.round + 1;
	end

	self.m_next_battle_delay = false
	--准备战斗数据
	self.cur_battle_data = self.battleDataList:get(0);
	self.battleDataList:removeAt(0);
	
	--如果是回放 战斗数据
	if self.m_replay or self.checkBattle == 1 then
		self.oneRoundBattleData = self.cur_battle_data
		if self.replayFix then
			self.replayFix:setFixData(self.oneRoundBattleData.fix)
		end
		local list = self.oneRoundBattleData["autofight_operations"];
		if list ~= nil then
			local frame = self:get_runframe();
			local frameData = list[tostring(frame)]
			if frameData ~= nil then
				--Logger.logError(" 回放设置自动战斗 ["..frame.."] 自动战斗 "..tostring(frameData.autofight) )
				self.plyMgr:SetAutoFight(frameData.autofight);
			end
		end
	else
		self.oneRoundBattleData = nil;
	end
	
	self.tongjiData:initRoundData(self.round, self.cur_battle_data)
	
	self.attacker_relicList = self.cur_battle_data.attacker_team.relic
	self.defender_relicList = self.cur_battle_data.defender_team.relic
	-- 队伍数据
	self.plyMgr:createTeam()
	-- 每回合的法阵buff加成
	self.attacker_buffsList = self.cur_battle_data.attacker_team.buffs 
	self.defender_buffsList = self.cur_battle_data.defender_team.buffs
	
	self.linkSceneId = -1;
	----把人物全部销毁
	if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.LOCAL_ARENA 
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.HIGH_ARENA 
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.HUASHAN_SWORD 
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.MINING 
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.RACE_ARENA
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.TOP_RACE_ARENA
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.MULT_STAGE
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_MINING
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GU_JIAN_MULT
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.PET_DOUJI
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.XIAKEDAO
			or self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI
			or self.m_replay == true then
		self:sendEvent("battleOnce",{ round = self.round },"GamePanel");
		self.plyMgr:destroy();
	else
		if GameVersionConfig.IS_SERVER then
			self.plyMgr:destroy();
		end	
	end
	
	--强制把黑屏置回来
	self.plyMgr:dispatchEvent_Local(Battle.EventType.MV_PlayerManagerBlackScreen,{type = 2})
	
	--法宝
	self.plyMgr.attacker_relicMgr:clear()
	self.plyMgr.defender_relicMgr:clear()
	if self.attacker_relicList ~= nil then
		for k,v in ipairs(self.attacker_relicList) do
			self.plyMgr.attacker_relicMgr:add(v)
		end
	end
	if self.defender_relicList ~= nil then
		for k,v in ipairs(self.defender_relicList) do
			self.plyMgr.defender_relicMgr:add(v)
		end
	end

	--遗物
	if self.attacker_heirloom ~= nil then
		for k,v in ipairs(self.attacker_heirloom) do
			--v["param"]["floor"] = self.param
			self.plyMgr.attacker_relicMgr:add(v["cid"], v["param"] or {})
		end
	end
	if self.defender_heirloom ~= nil then
		for k,v in ipairs(self.defender_heirloom) do
			--v["param"]["floor"] = self.param
			self.plyMgr.defender_relicMgr:add(v["cid"], v["param"] or {})
		end
	end
	self:initBossInfo()
	--创建宠物
	self:createBattlePet(1, self.cur_battle_data)
	self:createBattlePet(-1, self.cur_battle_data)
	--通过数据创建玩家
	self:createBattlePlayer(self.cur_battle_data);
	
	--删除Effect和设置Camera
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelBattleOnce)
	self.curTime = 0;
	--阵法buf加成
	self:setZhenFaBuf(self.cur_battle_data);
end

function M:initBossInfo()
	--目前世界boss 和 侠客试炼 和 月影传说(原五行阵) (奇门遁甲)
	if self:isBossLevel() then
		if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE then
			self.hero_train = ConfigManager:getCfgByName("train_challenge")
			self.hero_train_cfg = self.hero_train[self.param] or {}
			self.lost_hp = self.hero_train_cfg["lost_hp"]
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.WORLD_BOSS then
			self.world_boss = ConfigManager:getCfgByName("world_boss")
			self.wolrd_boss_cfg = self.world_boss[self.param] or {}
			self.lost_hp = self.wolrd_boss_cfg["lost_hp"]
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
			local active_world_boss = ConfigManager:getCfgByName("active_world_boss")
			local boss_cfg = active_world_boss[self.param] or {}
			self.active_world_boss = boss_cfg[self.common.sub_param] or {}
			self.lost_hp = self.active_world_boss["lost_hp"]
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.FIVE_ARRAY then
			self.five_array = ConfigManager:getCfgByName("mood_shadow_stage")
			self.five_array_cfg = self.five_array[1] or {}
			self.lost_hp = self.five_array_cfg["lost_hp"]
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.EVIL_SHADOW then
			self.evil_array = ConfigManager:getCfgByName("hero_event_stage")
			self.evil_array_cfg = self.evil_array[1] or {}
			self.lost_hp = self.evil_array_cfg["lost_hp"]
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
			self.evil_array = ConfigManager:getCfgByName("chivalrous_practice_stage")
			self.evil_array_cfg = self.evil_array[1] or {}
			self.lost_hp = self.evil_array_cfg["lost_hp"]
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.COMMON_BATTLE then
			self.evil_array = ConfigManager:getCfgByName("active_train")
			self.evil_array_cfg = self.evil_array[self.param][self.common.sub_param][1] or {}
			self.lost_hp = self.evil_array_cfg["lost_hp"]
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.DRAGONSWORD then
			self.evil_array = ConfigManager:getCfgByName("evil_shadow_stage")
			self.evil_array_cfg = self.evil_array[2] or {}
			self.lost_hp = self.evil_array_cfg["lost_hp"]
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
			self.gve_stage = ConfigManager:getCfgByName("gve_stage")
			self.gve_stage_cfg = self.gve_stage[self.param] or {}
			self.lost_hp = self.gve_stage_cfg["lost_hp"]
		elseif self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS then
			self.hero_train = ConfigManager:getCfgByName("full_service_boss_hp") or {}
			self.hero_train_cfg = self.hero_train[100001] or {}
			self.lost_hp = self.hero_train_cfg["lost_hp"] or {}
		end

		EventDispatcher:registerEvent("calculateDamage", {self,self.calculateDamageHandler})
	end
end

-- 统一判断是否是boss关卡
function M:isBossLevel()
	--目前世界boss 和 侠客试炼 和 月影传说(原五行阵) (奇门遁甲)
	if self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.WORLD_BOSS or
			self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE_BOSS or
			self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE or
			(self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.FIVE_ARRAY and self.fivePos == 0 ) or
			self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.EVIL_SHADOW or
			self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.SORT_CHIVALROUS or
			self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.COMMON_BATTLE or
			self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS or
			self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.DRAGONSWORD or
			self.mode == Battle.BattleGlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS  then
		
		return true
	end
	return false
end


function M:setZhenFaBuf( data )
	local attacker_team = data["attacker_team"]
	local atk_deployment = attacker_team.deployment
	if atk_deployment ~= nil then
		self.plyMgr:addZhenFaBuf(1,atk_deployment);
	end

	local defender_team = data["defender_team"]
	local def_deployment = defender_team.deployment
	if def_deployment ~= nil then
		self.plyMgr:addZhenFaBuf(-1,def_deployment);
	end
end


-- 下阵
function M:goDownBattle()
	self:dispatchEvent_Local(Battle.EventType.MV_SceneModelGoDownBattle);
end


--注册场景大小 
function M:registerSceneArea()
	
	--4个区域点
	if self.areaPoslist.Count >= 4 then
		-- --左上点
		local top_left = self.areaPoslist:get(0)
		--左下点
		local bottom_left = self.areaPoslist:get(1)
		--右下点
		local bottom_right = self.areaPoslist:get(2)
		--右上点
		local top_right = self.areaPoslist:get(3)
		--上边界
		self.top = top_left.z;
		--下边界
		self.bottom = bottom_left.z;
		--左边上面多出来的一块
		self.left_out = bottom_left.x - top_left.x
		--最小左边
		self.left = top_left.x;
		--最小右边
		self.right = top_right.x;
       
		self.right_out = top_right.x - bottom_right.x
	end
end

--通过Z值返回  最大的X和最小的X
function M:getMinMaxXByZ( z_value )
	local rate = GlobalTools:Div((self.top - z_value),(self.top - self.bottom));
	local left_offset = GlobalTools:Mul( GlobalTools:Abs(self.left_out), rate);
	local x_left = self.left + left_offset;
	local right_offset =GlobalTools:Mul(GlobalTools:Abs(self.right_out), rate);
	local x_right = self.right - right_offset;
	return x_left,x_right
end

--是否在区域中
function M:isInArea( pos )
	if pos.z > self.top then
		return false
	elseif pos.z < self.bottom then
		return false
	end
	local min_x,max_x = self:getMinMaxXByZ(pos.z)
	if pos.x < min_x then
		return false
	elseif pos.x > max_x then
		return false
	end
	return true
end

--获取边界位置
function M:getAreaPosition( pos )
	local outX = false
	local outZ = false
	if pos.z > self.top then
		pos.z = self.top;
		outZ = true
	elseif pos.z < self.bottom then
		pos.z = self.bottom;
		outZ = true
	end
	local min_x,max_x = self:getMinMaxXByZ(pos.z)
	if pos.x < min_x then
		pos.x = min_x
		outX = true
	elseif pos.x > max_x then
		pos.x = max_x
		outX = true
	end
	return pos, outX, outZ;
end

--获取边缘位置
function M:getEdgePosition(pos, dir)
	pos = pos:Clone()
	dir = dir:Clone()
	pos = pos + dir * 50
	self:getAreaPosition(pos)
	return pos
end

function M:setPlayerScale(ply, _showid)
	
end

function M:setBossDir( _showid )
	local list = self.plyMgr:getPlayers(-1)
	for i = 1, list.Count do
		local ply = list:get(i - 1);
		local dir = -FixVector3.right()
		local pos = self.bossPoslist:get(_showid)
		if self.m_mode == Battle.BattleGlobalConfig.BATTLE_MODE.ACTIVE or self.m_mode == Battle.BattleGlobalConfig.BATTLE_MODE.HERO_BOSS_PVE or self.m_mode == Battle.BattleGlobalConfig.BATTLE_MODE.HERO_BOSS_PVP then
			pos = self:findSpawnPosition(-1,ply:get_index())
			ply:setRotationMode(1);
		end
		ply:setForward(dir,true);
		ply:setPos(pos,true);
		ply:callViewDestroyHpLabel();
		self:setPlayerScale(ply, _showid)
	end
end

return M;
