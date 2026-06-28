---@class GamePanelModel : OODataBase
local M = class("GamePanelModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "animation"
    self.m_anim_name = "GamePanel_Enter"
	self:getData()
end

function M:onEnter()
	self.m_is_stop = false
	self.m_data = self.m_params.data
	if self.m_data.battle and self.m_data.battle.client_input and next(self.m_data.battle.client_input) ~= nil then
		self.m_def_data = self.m_data.battle.client_input[1].defender_team
	end
	self.m_team_nums=self.m_params.team_nums
	self.m_type = self.m_params.m_type;
	self.battle_config_id = self.m_params.battle_config_id --公会/世界 boss 配置id
	self.boss_hp = self.m_params.boss_hp
	self.m_mode = self.m_params.mode
	self.version = self.m_params.version
	self.open_id = self.m_params.open_id
	self.m_replay = self.m_params.replay
	self.m_node_id = self.m_params.node_id;
	self.m_rewardList = self.m_params.reward
	self.m_boss_id = self.m_params.boss_id
	self.m_boss_max_hp = self.m_params.m_boss_max_hp or 0
	self.m_boss_hp_cid = self.m_params.m_boss_hp_cid or 0
	self.m_round = self.m_params.round or 1
	self.m_raid_sort = self.m_params.raid_sort
	self.m_race = self.m_params.race or 0 -- 塔类型0 普通塔 1-4 种族塔
	self.m_server_hp_coef = self.m_params.m_server_hp_coef or 0
	self.m_server_dps_coef = self.m_params.m_server_dps_coef or 0
	self.m_addition_race = self.m_params.addition_race or {}
	self.m_five_pos = self.m_params.five_pos or 1
	self.m_floor = self.m_params.floor or 1
	self.m_bio_id = self.m_params.bio_id
	self.m_region_id = self.m_params.region_id
	self.m_chapter_id = self.m_params.chapter_id
	self.m_stage_id = self.m_params.stage_id
	self.m_legend_data = self.m_params.legend_data
	self.m_legend_heros = self.m_params.legend_heros
	self.m_maze_type = self.m_params.maze_type or 1 --迷宫格子类型
	self.m_budo_floor = self.m_params.budo_floor or 1
	self.m_battle_id_tab = self.m_params.battle_id_tab or {} --多阵容推图的战斗id
	self.m_formation_index = self.m_params.m_formation_index or 1
	self.m_races = self.m_params.races
	self.gve_def_data = self.m_params.def_data -- 重新开始战斗防守方数据
	self.m_gve_version = self.m_params.gve_version -- 奇门遁甲战斗version
	--新版本参数
	self.m_special_open_id = self.m_params.special_open_id or nil -- 侠客志
	self.m_special_version = self.m_params.special_version or nil

	--侠客岛
	self.m_layer=self.m_params.layer

	--RTA剑出鸿蒙
	self.rta_wendaoBNum=self.m_params.rta_wendaoBNum
	self.m_rta_score=self.m_params.rta_score
	self.m_rta_preScore=self.m_params.rta_preScore
	self.m_rta_result=self.m_params.rta_result
	if self.m_mode==GlobalConfig.BATTLE_MODE.RTA_ARENA then
		self.battleVSMode=2
	end

	-- 奇门遁甲参数
	if self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
		local max_hp = self.m_params.boss_max_hp
		if not self.m_params.boss_max_hp or self.m_params.boss_max_hp == 0  then
			max_hp = self.m_params.m_boss_max_hp
		end
		self.m_boss_max_hp = max_hp or 0
		self.m_lock_hids = self.m_params.lock_hids
		self.m_wall_coef = self.m_params.wall_coef
		self.m_combat_gve_battle = self.m_params.combat_gve_battle
		self.m_difficulty_reduce = self.m_params.difficulty_reduce
	end
	if self.m_mode == GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM then
		self.m_cur_stage_cfg = self.m_params.cur_stage_cfg or {}
	end
	if self.m_mode == GlobalConfig.BATTLE_MODE.HERO_FATE then
		self.m_cur_stage_cfg = self.m_params.cur_stage_cfg or {}
	end
	--是否移动摄像机
	self.m_isMoveCamera = self.m_params.move_camera or 0
	local battle_mode_cfg_item = GlobalConfig.BATTLE_MODE_CFG[self.m_mode]
	if battle_mode_cfg_item then
		local mode_util_item = BattleModeUtil[self.m_mode]
		if mode_util_item and mode_util_item.gamePanelModel then
			mode_util_item.gamePanelModel(self)
		else
			local team_key = battle_mode_cfg_item.team_key
			local default_team_key = battle_mode_cfg_item.default_team_key
			if team_key then
				self.main_team = table.copy(UserDataManager.hero_data:getTeamByKey(team_key, default_team_key))
			else
				Logger.logError(self.m_mode, "mode team key is error : ")
			end
		end
	else
		Logger.logError(self.m_mode, "mode is error : ")
	end
	self.m_battle_id = self.m_battle_id or self.m_params.battle_id
	local speed = nil
	if self:getBoolByCom(4) then
		speed = UserDataManager.local_data:getUserDataByKey("combat_speed",GlobalTools.base1_8)
	else
		speed = UserDataManager.local_data:getUserDataByKey("combat_speed",GlobalTools.base1_2)
	end
	self.m_speed2 = speed;
	TimeManager:set_localSpeed(speed)
	if self:isCanReleaseSkill() then
		self.m_auto = UserDataManager.local_data:getUserDataByKey("combat_auto", 1)
	else
		self.m_auto = 1 --自动打怪
	end
	self:addDefenderUserData()
end


function M:netData(data, tag)

end

function M:getNewBossRewardCfg()
	local world_boss_reward_cfg = ConfigManager:getCfgByName("world_boss_rewards")
	if self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS 
			and world_boss_reward_cfg 
			and next(world_boss_reward_cfg) and world_boss_reward_cfg[self.m_boss_id] then
		local reward_data = world_boss_reward_cfg[self.m_boss_id][self.m_boss_hp_cid]
		return reward_data.reward_lost_hp
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		world_boss_reward_cfg = ConfigManager:getCfgByName("active_world_boss_rewards")
		local reward_data = world_boss_reward_cfg[self.m_data.battle.common.param or 327] or {}
		local version_item = reward_data[self.m_data.battle.common.sub_param or 1] or {}
		return version_item.reward_lost_hp or {}
	end
	return {}
end

function M:getBossConfig()
	if self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
		self.hero_train= ConfigManager:getCfgByName("train_challenge")
		self.hero_train_cfg = self.hero_train[self.m_boss_id or 1] or {}
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE then
		self.hero_train= ConfigManager:getCfgByName("hero_boss")
		self.hero_train_cfg = self.hero_train[self.m_boss_id or 1] or {}
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then
		self.hero_train= ConfigManager:getCfgByName("mood_shadow_stage")
		self.hero_train_cfg = self.hero_train[self.m_boss_id or 1] or {}
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW then
		self.hero_train= ConfigManager:getCfgByName("hero_event_stage")
		self.hero_train_cfg = self.hero_train[self.m_boss_id or 1] or {}
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD then
		self.hero_train= ConfigManager:getCfgByName("evil_shadow_stage")
		self.hero_train_cfg = self.hero_train[self.m_boss_id or 2] or {}
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
		self.hero_train= ConfigManager:getCfgByName("chivalrous_practice_stage")
		self.hero_train_cfg = self.hero_train[self.m_boss_id or 1] or {}
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
		self.hero_train= ConfigManager:getCfgByName("active_train")
		self.hero_train_cfg = self.hero_train[self.m_params.open_id][self.m_params.version][self.m_boss_id or 1] or {}
	end
	return self.hero_train_cfg;
end

-- 世界boss配置
function M:getWorldBossCfg()
	local world_boss = ConfigManager:getCfgByName("world_boss")
	local world_boss_item = world_boss[self.m_boss_id or 1] or {}
	return world_boss_item
end

function M:updateTeam()
	self.main_team = UserDataManager.hero_data:getMainTeam()
end

function M:changeSpeed2()
	if self.m_speed2 == TimeManager.defaultTimeSpeed then
		self.m_speed2 = TimeManager.maxTimeSpeed
	elseif self.m_speed2 == TimeManager.maxTimeSpeed then
		self.m_speed2 = TimeManager.maxmaxTimeSpeed
	else
		self.m_speed2 = TimeManager.defaultTimeSpeed
	end
	return self.m_speed2
end

function M:changeAuto()
	if not self:isCanReleaseSkill() then
		return 0
	end
	if self.m_auto == 1 then
		self.m_auto = 0
	else	
		self.m_auto = 1
	end
	return self.m_auto
end

--查询卡牌是否在队伍中
function M:inquireInTeams(c_id)
	for k,v in pairs(self.main_team) do
		if v == c_id then
			return true
		end
	end   
	return false
end

--查询某个英雄中是否可以上阵
function M:inquireVacancy(c_id)
	if self:checkIsInTeam(c_id) then
		return false
	end
	if #self.main_team < 5 then
		return true
	end
	for k,v in pairs(self.main_team) do
		if v == "" then
			return true
		end
	end   
	return false
end

--添加进队伍
function M:addTeams(c_id)
	for k,v in pairs(self.main_team) do
		if v == "" then
			self.main_team[k] =	c_id
			return k
		end
	end
	if #self.main_team < 5 then
		self.main_team[#self.main_team + 1] = c_id
		return #self.main_team
	end
	return 1
end

--移出队伍
function M:removeTeams(c_id)
	for k,v in pairs(self.main_team) do
		if v == c_id then
			self.main_team[k] = ""
			return k
		end
	end

end

--移除所有
function M:removeAll()
	for k,v in pairs(self.main_team) do
		v.hero_id = nil
	end
end

--检查特定英雄是否在队伍中
function M:checkInTeams(oid)
	for k,v in pairs(self.main_team) do
		if v == oid then
			return true
		end
	end
	return false
end

--检查队伍中是否已有同名英雄
function M:checkIsInTeam(h_id)
	local h_data, h_cfg  = self:getHero(h_id)
	for k,v in pairs(self.main_team) do
		if #v > 0 then
			local c_data, c_cfg  = self:getHero(v)
				if h_cfg == c_cfg then
				return true	
			end
		end
	end
	return false
end

function M:getAllHeroCount()
	return UserDataManager.hero_data:getHerosCount()
end

function M:getAllHeroIds()
	return UserDataManager.hero_data:getHerosId()
end

--根据id获得英雄数据
function M:getHero(id)
	return UserDataManager.hero_data:getHeroDataById(id)
end

--检查当前buff级别
function M:getAddBuffLv(cur_round)
	local res1, res2, race1, race2 = self:checkArray(cur_round)
	return {lv1 = res1, lv2 = res2, race1 = race1, race2 = race2}
end

function M:checkArray(cur_round)
	local plyDataList = {}
	local input_index = 1
	if self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then -- 推图，古剑奇谭
		input_index = cur_round
	end
	if self.m_data.battle and self.m_data.battle.client_input and self.m_data.battle.client_input[input_index] then
		local client_input = self.m_data.battle.client_input[input_index]
		local m_teams = client_input.attacker_team.heros
		for k,v in pairs(m_teams) do
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id) 
			table.insert(plyDataList, cfg)
		end
	elseif cur_round and self.m_data.battle and self.m_data.battle.output and self.m_data.battle.output.rounds and self.m_data.battle.output.rounds[cur_round] then
		local round_data  = self.m_data.battle.output.rounds[cur_round]
		local m_teams = {}
		if round_data.attacker_team and round_data.attacker_team.heros then
			m_teams = round_data.attacker_team.heros
		end
		for k,v in pairs(m_teams) do
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
			table.insert(plyDataList, cfg)
		end
	else
		for k,v in pairs(self.main_team) do
			local data, cfg = self:getHero(v)
			table.insert(plyDataList, cfg)
		end
	end
	local res1, res2, race1, race2 = GlobalTools:checkArray(plyDataList, 1)
	return res1, res2, race1, race2
end

--检查敌人buff级别
function M:getEnemyAddBuffLv(cur_round)
	local res1, res2, race1, race2 = self:checkEnemyArray(cur_round)
	return {lv1 = res1, lv2 = res2, race1 = race1, race2 = race2}
end

function M:checkEnemyArray(cur_round)
	local enemyDataList = {}
	if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE then -- 推图
		--通过关卡表读取敌人
		local stage_tab = ConfigManager:getCfgByName("stage")
		local curLevel = UserDataManager:getBattleStage()
		local data = stage_tab[curLevel]
		local battle_id = data["battle_id"]
		--local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")
		local battle_data = ConfigManager:getCfgStageBattle(battle_id)--stage_battle_tab[battle_id]
		local monsters = battle_data["monster"]
		for k,v in pairs(monsters) do
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id) 
			table.insert(enemyDataList, cfg)
		end
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then -- 多队推图
		--通过关卡表读取敌人
		local stage_tab = ConfigManager:getCfgByName("stage")
		local curLevel = UserDataManager:getBattleStage()
		local data = stage_tab[curLevel]
		local battle_id_tab = data["battle"] or {}
		
		local battle_id = battle_id_tab[cur_round]
		--local stage_battle_tab = ConfigManager:getCfgByName("stage_battle" .. (cur_round == 1 and "" or cur_round)) or {}
		local battle_data = ConfigManager:getCfgStageBattle(battle_id) or {}--stage_battle_tab[battle_id] or {}
		local monsters = battle_data["monster"] or {}
		for k,v in pairs(monsters) do
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
			table.insert(enemyDataList, cfg)
		end
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then -- 古剑奇谭，多队伍
		--通过关卡表读取敌人
		local stage_tab = ConfigManager:getCfgByName("sword_main")
		local data = stage_tab[self.m_stage_id]
		local battle_id = data["battle_id"][cur_round]
		--local stage_battle_tab = ConfigManager:getCfgByName("stage_battle")
		local battle_data = ConfigManager:getCfgStageBattle(battle_id)--stage_battle_tab[battle_id]
		if not battle_data then
			Logger.logErrorAlways(tostring(self.m_stage_id).."--"..tostring(cur_round).."--"..tostring(battle_id),"stage_id -- cur_round -- battle_id")
		else
			local monsters = battle_data["monster"]
			for k,v in pairs(monsters) do
				local cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
				table.insert(enemyDataList, cfg)
			end
		end
		
	elseif cur_round and self.m_data.battle and self.m_data.battle.output and self.m_data.battle.output.rounds and self.m_data.battle.output.rounds[cur_round] then
		local round_data  = self.m_data.battle.output.rounds[cur_round]
		local m_teams = {}
		if round_data.defender_team and round_data.defender_team.heros then
			m_teams = round_data.defender_team.heros
		end
		for k,v in pairs(m_teams) do
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
			table.insert(enemyDataList, cfg)
		end	
	else
		if self.m_def_data and next(self.m_def_data) ~= nil then
			for k,v in pairs(self.m_def_data.heros) do
				local cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id) 
				table.insert(enemyDataList, cfg)
			end
		end
	end

	local res1, res2, race1, race2 = GlobalTools:checkArray(enemyDataList, -1)
	return res1, res2, race1, race2
end

function M:getStageBattleName()
    if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then -- 推图
        local stage_tab = ConfigManager:getCfgByName("stage")
        local curLevel = UserDataManager:getBattleStage()
        local data = stage_tab[curLevel]
        return Language:getTextByKey(data["map_point_name"])
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.TOWER then -- 天机楼
		return Language:getTextByKey("world_str_009").."：".. Language:getTextByKey("budo_str_001",self.m_budo_floor)
    elseif self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then -- 种族塔    
        return Language:getTextByKey("new_str_0869",self.m_budo_floor)
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then -- 种族塔    
		return Language:getTextByKey("budoServer_text_0007").."：".. Language:getTextByKey("budo_str_001",self.m_budo_floor)
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then -- 古剑奇谭   
		local stage = ConfigManager:getCfgByName("sword_main")
		local stage_cfg = stage[self.m_stage_id] or {}
		return Language:getTextByKey(stage_cfg.name) or ""
	else
		return ""	
    end
end

function M:getUserInfoBySort(sort)
	local battle = self.m_data.battle or {}
	local common = battle.common or {}
	if sort == 1 then -- 左边
		return common.attacker_user or {}
	else --  右边
		return common.defender_user or {}
	end
end

function M:getBattleResults()
	local show_data = {}
	local battle = self.m_data.battle or {}
	local output = battle.output or {}
	local rounds = output.rounds or {}
	for k,v in ipairs(rounds) do
		local result = v.result or 0
		show_data[k] = result
	end
	return show_data
end

function M:isShowVSFlag()
	return self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA 
			or self.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD
			or self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA
			or self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA
	or self.m_mode==GlobalConfig.BATTLE_MODE.ZF_ARENA_MUL
end

function M:isCanReleaseSkill()
	return not (GlobalConfig.BATTLE_MODE_CFG[self.m_mode].pvp or self.m_replay)
end

function M:autoStop()
	self.m_is_stop = not self.m_is_stop
end

function M:getGuildTable()
	local list = {}
	if	self.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS then -- 世界boss
		local gu_table = ConfigManager:getCfgByName("guild_boss")[self.battle_config_id]
		for k,v in pairs(gu_table.reward_lost_hp) do 
			list[k] = { dmg = v, is_show = false }
		end
	end
	return list
end	

--公会boss血量百分比
function M:unionBossHp(dmg)
	if	self.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS then
		local gu_table = ConfigManager:getCfgByName("guild_boss")[self.battle_config_id]
		local max_hp = gu_table.real_hp
		local cur_hp = self.boss_hp - dmg
		return cur_hp/max_hp
	end
	return 1
end
--公会boss血量
function M:unionBossHpNum(dmg)
	if	self.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS then
		local gu_table = ConfigManager:getCfgByName("guild_boss")[self.battle_config_id]
		local max_hp = gu_table.real_hp
		local cur_hp = self.boss_hp - dmg
		return cur_hp.."/"..max_hp
	end
	return 0
end

function M:getBossBufImg()
	if self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
		--local wo_table = ConfigManager:getCfgByName("world_boss_cycle")[self.battle_config_id]
		local world_boss = ConfigManager:getCfgByName("world_boss")
		local world_boss_item = world_boss[self.m_boss_id or 1] or {}
		return world_boss_item["buff_icon"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		local world_boss = ConfigManager:getCfgByName("active_world_boss")
		local world_boss_item = world_boss[self.m_data.battle.common.param or 327] or {}
		local version_item = world_boss_item[self.m_data.battle.common.sub_param or 1] or {}
		return version_item["buff_icon"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
		local hero_gather = ConfigManager:getCfgByName("train_challenge")
		local hero_gather_item = hero_gather[self.m_boss_id or 1] or {}
		return hero_gather_item["buff_icon"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then
		local hero_gather = ConfigManager:getCfgByName("mood_shadow_stage")
		local hero_gather_item = hero_gather[self.m_boss_id or 1] or {}
		return hero_gather_item["buff_icon"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW then
		local hero_gather = ConfigManager:getCfgByName("hero_event_stage")
		local hero_gather_item = hero_gather[self.m_boss_id or 1] or {}
		return hero_gather_item["buff_icon"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD then
		local hero_gather = ConfigManager:getCfgByName("evil_shadow_stage")
		local hero_gather_item = hero_gather[self.m_boss_id or 2] or {}
		return hero_gather_item["buff_icon"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
		local hero_gather = ConfigManager:getCfgByName("chivalrous_practice_stage")
		local hero_gather_item = hero_gather[self.m_boss_id or 1] or {}
		return hero_gather_item["buff_icon"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
		local hero_gather = ConfigManager:getCfgByName("active_train")
		local hero_gather_item = hero_gather[self.m_params.open_id][self.m_params.version][self.m_boss_id or 1] or {}
		return hero_gather_item["buff_icon"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS then
		local gu_table = ConfigManager:getCfgByName("guild_boss")
		local b_data = gu_table[self.battle_config_id]
		return b_data["buff_icon"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
		local gve_stage = ConfigManager:getCfgByName("gve_stage")
		local gve_stage_item = gve_stage[self.m_stage_id or 1] or {}
		return gve_stage_item["buff_icon"] or ""
	end
	return ""
end

function M:getBossBufTips()
	if 	self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
		--local wo_table = ConfigManager:getCfgByName("world_boss_cycle")[self.battle_config_id]
		local world_boss = ConfigManager:getCfgByName("world_boss")
		local world_boss_item = world_boss[self.m_boss_id or 1] or {}
		return world_boss_item["buff_des"] or ""
	elseif 	self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		local world_boss = ConfigManager:getCfgByName("active_world_boss")
		local world_boss_item = world_boss[self.m_data.battle.common.param or 327] or {}
		local version_item = world_boss_item[self.m_data.battle.common.sub_param or 1] or {}
		return version_item["buff_des"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
		return "new_str_0763";
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS then
		local gu_table = ConfigManager:getCfgByName("guild_boss")[self.battle_config_id]
		return gu_table["buff_des"] or ""
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
		local gve_stage = ConfigManager:getCfgByName("gve_stage")
		local gve_stage_item = gve_stage[self.m_stage_id or 1] or {}
		return gve_stage_item["buff_des"] or ""

	end
end


--[[
    STAGE = 1, -- 推图
    TOWER = 2, -- 爬塔
    RACE_TOWER = 3, -- 种族塔
    MAZE = 4, -- 迷宫
    LOCAL_ARENA = 5, -- 普通竞技场
    MULT_FORMATION = 10, -- 多编队
    HIGH_ARENA = 11, -- 高阶竞技场
    HIGH_ARENA_DEFENSE = 12, -- 高阶竞技场防守阵容
    LOCAL_ARENA_DEFENSE = 13, -- 竞技场防守阵容
    WORLD_BOSS = 14, -- 世界boss
    RACE_ARENA = 23 -- 种族竞技场
]]
function M:isShowEnemyUI()
	if self.m_mode == 1 or self.m_mode == 2 or self.m_mode == 3 or self.m_mode == 4 or self.m_mode == 5 or self.m_mode == 11 or self.m_mode == 14 or self.m_mode == 27  then
		return true
	else
		return false
	end
end

--公会boss世界boss不显示羁绊
function M:isShowUI()
	if	self.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS or self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		return false
	else
		return true	
	end
end

-- 设置防守阵容的user数据 ，pvp不需要
function M:addDefenderUserData()
	if self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or self.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS then
		--local boss_cycle
		--if 	self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
		--	boss_cycle = ConfigManager:getCfgByName("world_boss_cycle")[self.battle_config_id]
		--elseif self.m_mode == GlobalConfig.BATTLE_MODE.UNION_BOSS then
		--	boss_cycle = ConfigManager:getCfgByName("guild_boss")[self.battle_config_idbattle_config_id]
		--end
		local world_boss = ConfigManager:getCfgByName("world_boss")
		local world_boss_item = world_boss[self.m_boss_id or 1] or {}
		--local stage_battle = ConfigManager:getCfgByName("stage_battle")
		local battle_cfg = ConfigManager:getCfgStageBattle(world_boss_item.battle_id)--stage_battle[world_boss_item.battle_id]
		local boss = battle_cfg.monster[battle_cfg.worldboss_position]
		local hero_detail = ConfigManager:getCfgByName("hero_detail")
		local boss_cfg = hero_detail[boss.id]
		local user = {}
		user.avatar = boss.id
		user.level = boss.lv
		user.name = boss_cfg.name
		self.m_data.battle.common.defender_user = user
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		local world_boss = ConfigManager:getCfgByName("active_world_boss")
		local world_boss_item = world_boss[self.m_data.battle.common.param or 327] or {}
		local version_item = world_boss_item[self.m_data.battle.common.sub_param or 1] or {}
		--local stage_battle = ConfigManager:getCfgByName("stage_battle")
		local battle_cfg = ConfigManager:getCfgStageBattle(version_item.battle_id)--stage_battle[version_item.battle_id]
		local boss = battle_cfg.monster[battle_cfg.worldboss_position]
		local hero_detail = ConfigManager:getCfgByName("hero_detail")
		local boss_cfg = hero_detail[boss.id]
		local user = {}
		user.avatar = boss.id
		user.level = boss.lv
		user.name = boss_cfg.name
		self.m_data.battle.common.defender_user = user
	end
end

function M:getBoolByCom(index)
	local cur_stage = UserDataManager:getCurStage()
	if index == 1 then --自动按钮显示
		local num = ConfigManager:getCommonValueById(255)
		return cur_stage >= num
	elseif index == 2 then --暂停按钮显示
		local num = ConfigManager:getCommonValueById(256)
		return cur_stage >= num
	elseif index == 3 then --双倍按钮显示
		local num = ConfigManager:getCommonValueById(257)
		return cur_stage >= num
	elseif index == 4 then --双倍按钮可用	
		local num = ConfigManager:getCommonValueById(258)
		return cur_stage >= num
	end
end

-- 快速通关按钮
function M:openQuickFlag()
	local open_quick_flag = false
	if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
		local quick_charlenge = ConfigManager:getVipValueByKey("quick_charlenge", 0)
		open_quick_flag = quick_charlenge == 1 and not self.m_replay
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
			local quick_charlenge = ConfigManager:getVipValueByKey("quick_charlenge", 0)
			open_quick_flag = quick_charlenge == 1 and not self.m_replay
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.HIGH_ARENA then
		local quick_charlenge = ConfigManager:getVipValueByKey("high_arena_jump", 0)
		open_quick_flag = quick_charlenge == 1 and not self.m_replay
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD then
		open_quick_flag =  not self.m_replay
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA
	or self.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA
	or self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA 
	or self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA
	or self.m_mode == GlobalConfig.BATTLE_MODE.PET_DOUJI
	or self.m_mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA then
		open_quick_flag = true
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS 
			or self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS
			or self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS
			or self.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS
			or self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
		
		open_quick_flag = not self.m_replay
	end
	return open_quick_flag
end

--获得战斗类型数据 子id
function M:getSubId()
	if self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then --五行阵 pos
		return self.m_five_pos
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then  --种族塔race 
		return self.m_race
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.MAZE or self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE then  --迷宫 格子类型
		return self.m_maze_type
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.RAID then  -- 武道场类型raid_sor
		return self.m_raid_sort
	end
	return 0
end

function M:getWorldBossHp(total_damage)
	local boss_max_hp = self.m_boss_max_hp
	total_damage = math.min(total_damage, boss_max_hp)
	local cur_boss_hp = boss_max_hp - total_damage
	local total_hp_percent = total_damage / boss_max_hp
	local cur_part = 0
	local cur_part_damage = 0
	local cur_hp_percent = 0
	for i = 4, 1, -1 do
		if cur_boss_hp >= (i-1)/4 * boss_max_hp then
			cur_part = 4 - i
			cur_hp_percent = (total_damage - cur_part / 4 * boss_max_hp) / (boss_max_hp / 4)
			break
		end
	end
	return cur_part, cur_hp_percent, total_hp_percent
end

--检查是否显示关卡进度/天机楼进度
function M:checkShowStageName()
    if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or 
		self.m_mode == GlobalConfig.BATTLE_MODE.TOWER or self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER 
			or self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER or
		self.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        return true
    else
        return false    
    end
end

return M
