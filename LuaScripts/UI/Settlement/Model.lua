---@class SettlementModel:OODataBase
local M = class("SettlementModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_result = self.m_params.result 
	Logger.log(self.m_result,"self.m_result---->")
	self.m_mode = self.m_params.mode or 0 
	self.version = self.m_params.version or 1
	self.m_def_data = self.m_params.def_data or {}
	self.m_replay = self.m_params.replay
	self.m_five_pos = self.m_params.m_five_pos
	self.m_boss_id = self.m_params.boss_id
	self.m_quick_pass = self.m_params.quick_pass
	self.m_raid_sort = self.m_params.raid_sort
	self.m_stage_id = self.m_params.stage_id
	self.m_legend_value = self.m_params.value
	self.m_legend_level = self.m_params.legend_level
	self.m_legend_new_record = self.m_params.legend_new_record
	self.m_battle_time = self.m_params.battle_time or 0
	self.bl_new_panel = 0 -- self.m_params.ex_hero or 0
	self.m_full_mask_flag = self.m_params.full_mask_flag or false -- 是否需要全屏遮罩
	self.m_budo_floor = self.m_params.m_budo_floor
	self.m_skip_battle = self.m_params.skip_battle --跳过战斗
	self.m_special_open_id = self.m_params.special_open_id or nil -- 侠客志
	self.m_special_version = self.m_params.special_version or nil

	self.rta_wendaoBNum=self.m_params.rta_wendaoBNum
	self.rta_score=self.m_params.rta_score
	self.rta_preScore=self.m_params.rta_preScore
	self.rta_result=self.m_params.rta_result

	local damage = self.m_params.boss_dmg;

	local upload_data = nil
	if self.m_params.battle_data ~= nil and self.m_params.battle_data.battle then
		self.m_common = self.m_params.battle_data.battle.common
		upload_data = self.m_params.battle_data.upload_data or {}
		--if self.m_params.battle_data.battle.output ~= nil and self.m_params.battle_data.battle.output.rounds[1] then
		--	for k,v in pairs(self.m_params.battle_data.battle.output.rounds[1].attacker_stats) do
		--		damage = damage + v.atk
		--	end
		--end 
	else
		upload_data = {}
	end
	self.m_damage = damage
	if self.m_replay then
		if self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE or self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then -- 世界boss
			self.m_result = 1
		elseif self.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE or self.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE then -- 风云擂台
			local def_uid = self.m_params.battle_data.battle.common.defender_user.uid
			local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
			if def_uid == self_uid then
				self.m_result = self.m_params.battle_data.result == 1 and 0 or 1
			end
		end
		self:getData()
	else
		local mode_util_item = BattleModeUtil[self.m_mode]
		if mode_util_item and mode_util_item.settlementModel then
			mode_util_item.settlementModel(self, upload_data)
		else
			Logger.logError(self.m_mode, "mode is error : ")
		end
	end
end

function M:onEnter()
	self.m_battle_data = self.m_params.battle_data
	self.m_data = self.m_data or self.m_battle_data
	self.autoChapterNextOpen = false --自动下一关是否开启
	self.autoChapterDownTime = 8 -- 自动下一关倒计时
	self.auotChapterBl = UserDataManager.local_data:getUserDataByKey("auot_chapter_bl", 1) -- 自动下一关勾选状态
	self.auto_open_limit = true -- 自动下一关的开启限制
	self:checkChapterNextLimit()
	if self.m_data.battle == nil then
		self.m_data.battle = self.m_battle_data.battle
		local key_net_data = "net_data_" .. self.m_mode
		local key_battle_data = "battle_data_" .. self.m_mode
		if self.m_replay and UserDataManager:getTempData(key_net_data) then
			self.m_data = UserDataManager:getTempData(key_net_data)
			self.m_battle_data = UserDataManager:getTempData(key_battle_data)
		else
			UserDataManager:setTempData(key_net_data, self.m_data)
			UserDataManager:setTempData(key_battle_data, self.m_battle_data)
		end
		if self.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE and self.m_data.damage  then
			self.m_damage = self.m_data.damage
		end
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
		self.m_battle_data = self.m_battle_data and self.m_battle_data or self.m_data
		self.m_params.battle_data = self.m_params.battle_data and self.m_params.battle_data or self.m_data
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		self.m_battle_data = self.m_battle_data and self.m_battle_data or self.m_data
		self.m_params.battle_data = self.m_params.battle_data and self.m_params.battle_data or self.m_data
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
		self.m_battle_data = self.m_battle_data and self.m_battle_data or self.m_data
		self.m_params.battle_data = self.m_params.battle_data and self.m_params.battle_data or self.m_data
		self.m_damage = self.m_battle_data.damage
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.HERO_BOSS_PVE then
		self.m_battle_data = self.m_battle_data and self.m_battle_data or self.m_data
		self.m_params.battle_data = self.m_params.battle_data and self.m_params.battle_data or self.m_data
		self.m_damage = self.m_battle_data.damage
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.LEGEND then
		self.m_battle_data = self.m_battle_data and self.m_battle_data or self.m_data
		self.m_params.battle_data = self.m_params.battle_data and self.m_params.battle_data or self.m_data
		self.m_common = self.m_params.battle_data.battle.common
		self.m_legend_value = self.m_battle_data.value
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS or self.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE then
		self.m_battle_data = self.m_battle_data and self.m_battle_data or self.m_data
		self.m_params.battle_data = self.m_params.battle_data and self.m_params.battle_data or self.m_data
		self.m_result = self.m_data.result -- 跳过的战斗结果走后端
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_BOSS then
		self.m_battle_data = self.m_battle_data and self.m_battle_data or self.m_data
		self.m_params.battle_data = self.m_params.battle_data and self.m_params.battle_data or self.m_data
	end
	if self.m_data.result and self.m_battle_data.result == nil then
		self.m_battle_data.result = self.m_data.result
	end
	-- self.m_result = self.m_data.result
	self.m_rewards = RewardUtil:mergeRewardAndFormat(self.m_data.reward)
	if self.m_mode == GlobalConfig.BATTLE_MODE.RAID then --武道场
		local commom_rewards = RewardUtil:mergeRewardAndFormat(self.m_data.reward)
		local privilege_rewards = RewardUtil:mergeRewardAndFormat(self.m_data.special_reward)
		local total_reward = commom_rewards
		if privilege_rewards ~= nil then
			for i, v in ipairs(privilege_rewards) do
				if v. extra_type ~= nil then
					v.extra_type = 1
					table.insert(total_reward,v)
				end
			end
		end
		self.m_rewards = total_reward
	end
	--Logger.logError(self.m_rewards," 五行阵战斗结束 奖励数据 ~~~~~~~~~~~~~ ")
	self:addDefenderUserData()
	-- if self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then
	-- 	if self.m_data.race_floor_times ~= nil then
	-- 		for k,v in pairs(self.m_data.race_floor_times) do
	-- 			UserDataManager.race_floor_times[k] = v
	-- 		end
	-- 	else
	-- 		Logger.logError(" 种族塔数据 race_floor_times = nil 检查是否可以是 空")
	-- 	end
	-- end
	local map = LikeOO.Map2DControl.curMap2D
	local map_id = UserDataManager:getTempData("regional_battle_map_id")
	if map ~= nil and map_id ~= nil then
		local articlesData = UserDataManager:getArticlesData()
		map:callback(articlesData)
		--local task_id = UserDataManager:getTempData("regional_battle_task_id")
		--local task_data = articlesData[tostring(map.map_id)]["999"][tostring(task_id)]
		--map:refreshChoice(task_data)
		map:battleFinish(self.m_result, self.m_replay, self.m_data)
	end
	-- 随机江湖战斗完成后回调
	local new_map = LikeOO.NewMap2DControl.curMap2D
	local new_map_id = UserDataManager:getTempData("new_regional_battle_map_id")
	if new_map ~= nil and new_map_id ~= nil then
		local articlesData = UserDataManager:getNewMapArticlesData()
		new_map:callback(articlesData)
		new_map:battleFinish(self.m_result, self.m_replay, self.m_data)
	end
	if self.m_mode == GlobalConfig.BATTLE_MODE.LEGEND then
		static_rootControl:updateMsg("refresh_data", self.m_data, "Legend")
	end
end

function M:getTeams()
	self.main_team = {}
	local tt = table.copy(UserDataManager.hero_data:getTeamByKey("stage")) 
	for i = 1,5 do
		if tt[i] then
			self.main_team[i] = tt[i] 
		else
			self.main_team[i] = ""	
		end
	end
	return self.main_team
end

--是否为当前章节最后一关
function M:isLastStage()
	local chapter_over = UserDataManager:getChapterOver()
	return chapter_over
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "battle_end" then
		
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

function M:getBattleRounds()
	local show_data = {}
	local battle = self.m_data.battle or {}
	local output = battle.output or {}
	local rounds = output.rounds or {}
	for k,v in ipairs(rounds) do
		local attacker_team = v.attacker_team or  {}
		local team = attacker_team.team or {}
		local heros = attacker_team.heros or {}
		local left_team_data = GameUtil:getFormatTeamData(team, heros)
		
		local defender_team = v.defender_team or {}
		local team = defender_team.team or {}
		local heros = defender_team.heros or {}
		local right_team_data = GameUtil:getFormatTeamData(team, heros)
		table.insert(show_data, {left_team_data = left_team_data, right_team_data = right_team_data, round_data = v})
	end
	return show_data
end

function M:getVSNum()
	local show_data = {}
	local battle = self.m_data and self.m_data.battle
	battle = battle or self.m_params.battle_data.battle
	battle = battle or {}
	local output = battle.output or {}
	local rounds = output.rounds or {}
	local left_num = 0
	local right_num = 0
	for k,v in ipairs(rounds) do
		local result = v.result or 0
		if result == 1 then
			left_num = left_num + 1
		else
			right_num = right_num + 1
		end
	end
	return left_num, right_num
end

function M:getShowRecordFlag()
	return (self.m_mode ~= GlobalConfig.BATTLE_MODE.HIGH_ARENA or self.m_mode ~= GlobalConfig.BATTLE_MODE.HUASHAN_SWORD) and self.m_mode ~= GlobalConfig.BATTLE_MODE.WORLD_BOSS and self.m_mode ~= GlobalConfig.BATTLE_MODE.ACTIVE_BOSS
end

-- 设置防守阵容的user数据 ，pvp不需要
function M:addDefenderUserData()
	if self.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
		--local world_boss_cycle = ConfigManager:getCfgByName("world_boss_cycle")[self.m_data.battle_config_id]
		--if world_boss_cycle then
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
			self.m_battle_data.battle.common.defender_user = user
		--end
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
		local scene_model = SceneManager:getCurSceneModel()
		local world_boss = ConfigManager:getCfgByName("active_world_boss")
		local world_boss_item = world_boss[scene_model.m_data.m_open_id or 327] or {}
		local boss_cfg = world_boss_item[scene_model.m_data.m_version or 1] or {}
		--local stage_battle = ConfigManager:getCfgByName("stage_battle")
		local battle_cfg = ConfigManager:getCfgStageBattle(boss_cfg.battle_id)--stage_battle[boss_cfg.battle_id]
		local boss = battle_cfg.monster[battle_cfg.worldboss_position]
		local hero_detail = ConfigManager:getCfgByName("hero_detail")
		local boss_cfg = hero_detail[boss.id]
		local user = {}
		user.avatar = boss.id
		user.level = boss.lv
		user.name = boss_cfg.name
		self.m_battle_data.battle.common.defender_user = user
	end
end

-- 获取伤害最高的英雄spine
function M:getHeroBigAnim()
	local spine_anim_name = "hero_0106_SkeletonData"
	local hero_cfg = nil
	local battle = self.m_params.battle_data.battle or {}
	if battle.output ~= nil then
		local rounds = battle.output.rounds or {}
		local max_atk = 0
		for k,v in ipairs(rounds) do
			local attacker_stats = v.attacker_stats or {}
			local attacker_team = v.attacker_team or {}
			local heros = attacker_team.heros or {}
			if attacker_stats and next(attacker_stats) then
				for k,v in pairs(attacker_stats) do
					local atk = v.atk or 0
					local hero_data = heros[k] or {}
					if atk >= max_atk then
						max_atk = atk
						hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id or -1)
						local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, hero_cfg)
						if hero_skin_cfg then
							spine_anim_name = hero_skin_cfg.hero_spine
						end
					end
				end
			else
				local hero_id = ""
				local hero_combat = 0
				for i, v in pairs(heros) do
					if v.combat >= hero_combat then
						hero_id = i
						hero_combat = v.combat
					end
				end
				local hero_data = heros[hero_id] or {}
				hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id or -1)
				local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, hero_cfg)
				if hero_skin_cfg then
					spine_anim_name = hero_skin_cfg.hero_spine
				end
			end
		end
	end
	return spine_anim_name,hero_cfg
end

-- pvp展示英雄，展示自己的
function M:getPvpHeroBigAnim()
	local spine_anim_name = "hero_0106_SkeletonData"
	local hero_cfg = nil
	local battle = self.m_params.battle_data.battle or {}
	if battle.output ~= nil then
		local rounds = battle.output.rounds or {}
		local max_atk = 0
		local def_uid = self.m_params.battle_data.battle.common.defender_user.uid
		local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
		for k,v in ipairs(rounds) do
			local attacker_stats = {}
			local attacker_team =  {}
			if def_uid == self_uid then
				attacker_stats = v.defender_stats or {}
				attacker_team = v.defender_team or {}
			else
				attacker_stats = v.attacker_stats or {}
				attacker_team = v.attacker_team or {}
			end
			
			local heros = attacker_team.heros or {}
			if attacker_stats and next(attacker_stats) then
				for k,v in pairs(attacker_stats) do
					local atk = v.atk or 0
					local hero_data = heros[k] or {}
					if atk >= max_atk then
						max_atk = atk
						hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id or -1)
						local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, hero_cfg)
						if hero_skin_cfg then
							spine_anim_name = hero_skin_cfg.hero_spine
						end
					end
				end
			else
				local hero_id = ""
				local hero_combat = 0
				for i, v in pairs(heros) do
					if v.combat >= hero_combat then
						hero_id = i
						hero_combat = v.combat
					end
				end
				local hero_data = heros[hero_id] or {}
				hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id or -1)
				local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, hero_cfg)
				if hero_skin_cfg then
					spine_anim_name = hero_skin_cfg.hero_spine
				end
			end
		end
	end
	return spine_anim_name,hero_cfg
end

function M:getSpinePos(cfg)
	if cfg == nil then
		return Vector3(0,0,0)
	end
	local id = cfg.id
	local hero_tab = ConfigManager:getCfgByName("hero_detail")
	local data_pos = hero_tab[id]["spine_position"]
	local data_scale = hero_tab[id]["hero_scale"] or 1
	return data_pos, data_scale
end

function M:getDefByFloor()
	if self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY 
			or self.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW 
			or self.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD 
			or self.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE 
			or self.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
		--local tab = ConfigManager:getCfgByName("stage_battle")
		local tower_tab = ConfigManager:getCfgByName("five_element_tower")
		local allelopathy_tab = ConfigManager:getCfgByName("five_element_allelopathy")
		if self.m_floor > #tower_tab then
			return nil
		end
		local b_ids= tower_tab[self.m_floor+1]["battle_id_list"]
		local elem_list = tower_tab[self.m_floor+1]["element_list"]
		local cur_element = elem_list[self.m_five_pos] or 1
		for k,v in pairs(allelopathy_tab) do
			if v.enemy_type == cur_element then
				return v
			end
		end
		return nil
	end
	return nil
end

function M:checIsSkip()
	if self.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE or self.m_mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE then
		return false
	end
	if self.m_replay == true and self.m_params.battle_data and self.m_params.battle_data.battle_id then
		return true
	else
		return false	
	end
end

function M:setRoundResult()
	if self.m_params.battle_data ~= nil then
		local round = self.m_params.battle_data.battle.output.rounds[1]
		if round then
			round.result = self.m_result
		end
	end
end

--开启自动下一关倒计时
function M:setChapterDownTime()
	local limit_stage = ConfigManager:getCommonValueById(384, 0) or 0
	local m_stage = UserDataManager:getCurStage()
	if (self.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE) and self.m_result == 1 and m_stage >= limit_stage then -- 推图 
		self.autoChapterNextOpen = true
		self.autoChapterDownTime = 5
	elseif 	self.m_mode == GlobalConfig.BATTLE_MODE.TOWER and self.m_result == 1 then
		self.autoChapterNextOpen = true
		self.autoChapterDownTime = 5
	elseif 	self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER and self.m_result == 1 then
		self.autoChapterNextOpen = true
		self.autoChapterDownTime = 5
	else
		self.autoChapterNextOpen = false
	end
end

--开启下一关限制
function M:checkChapterNextLimit()
	local vip_tab = ConfigManager:getCfgByName("vip")
	local limit_stage = ConfigManager:getCommonValueById(384, 0) or 0
	local m_stage = UserDataManager:getCurStage()
	local m_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
	local stage = ConfigManager:getCfgByName("stage")
	local vip_cfg = vip_tab[m_vip]
	if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
		if vip_cfg.auto_battle and vip_cfg.auto_battle <= 0 then
			self.auto_open_limit = false
			return 1
		end
		if m_stage < limit_stage then	
			local stage_item = stage[limit_stage]
			self.auto_open_limit = false
			return 2, Language:getTextByKey(stage_item.map_point_name) 
		end
	else
		if vip_cfg.tower_auto and vip_cfg.tower_auto <= 0 then
			self.auto_open_limit = false
			return 1
		end
	end
	return 3
end

function M:getAutoVipLvByType(type)
	local vip_tab = ConfigManager:getCfgByName("vip")
	local lv = 0
	for i = 0, #vip_tab + 1 do
		local cur_cfg = vip_tab[i]
		if cur_cfg then
			if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
				if cur_cfg.auto_battle >= 1 then
					lv = i
					break
				end
			elseif self.m_mode == GlobalConfig.BATTLE_MODE.TOWER or self.m_mode == GlobalConfig.BATTLE_MODE.RACE_TOWER then
				if cur_cfg.tower_auto >= 1 then
					lv = i
					break
				end
			end
		end
	end
	return lv
end


function M:getIsNewChapter()
	local flag = false
	if self.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
		flag = self.m_result == 1 and self:isLastStage()
		if self.m_replay == true and self.m_data.new_chapter ~= nil then
			flag = self.m_data.new_chapter
		end
	end
	return flag
end

function M:getChapterOverRewards()
	local main_quest_auto = self.m_data.main_quest_auto or {} -- 当前章奖励
	local rewards = {}
	local quest_id = nil
	for k, v in pairs(main_quest_auto) do
		rewards = RewardUtil:mergeRewardAndFormat(v)
		quest_id = k
		break
	end
	return rewards, quest_id
end
function M:getLegendBreakValue()
	local legend_upgrade_table = ConfigManager:getCfgByName("legend_upgrade")
	local legend_type = self.m_common.battle_mode - 1
	local cfg = legend_upgrade_table[legend_type][self.m_legend_level]
	local break_value = 0
	if cfg ~= nil then
		break_value = cfg.unlock_param
	end
	return break_value
end

function M:getBattleInfo()
	return self.m_legend_value or 0
end

function M:weekWinNum()
	return self.m_data.week_win_times or 0
end

function M:weekWinMaxNum()
	local arena_reward_week = nil
	if self.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA then
		arena_reward_week = ConfigManager:getCfgByName("arena_reward_week")
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.RACE_ARENA then
		arena_reward_week = ConfigManager:getCfgByName("race_arena_reward_week")
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA then
		arena_reward_week = ConfigManager:getCfgByName("top_race_arena_reward_week")
	elseif self.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA then
		arena_reward_week = ConfigManager:getCfgByName("season_race_arena_reward_week")
	end
	if arena_reward_week == nil then
		return 20
	end
	local max_num = arena_reward_week[#arena_reward_week].num
	for k,v in pairs(arena_reward_week) do
		if self.m_data.week_win_times <= v.num then
			max_num = v.num
			break
		end
	end
	return max_num
end

function M:isActiveTowerMaxFloor()
	if self.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER then
		local tab_tower_all = ConfigManager:getCfgByName("tower_stage_active") or {}
		local cur_tower_cfg = tab_tower_all[self.version] or {}
		local max_floor = table.nums(cur_tower_cfg)
		if self.m_budo_floor >= max_floor then
			return true
		end
	end
	return false
end

function M:petAtkShowData()
	local show_data = {}
	local battle = self.m_data.battle or {}
	local output = battle.output or {}
	local rounds = output.rounds or {}
	local round_data = rounds[1] or {}
	local attacker_team = round_data.attacker_team or {}
	local team = attacker_team.team or {}
	local heros = attacker_team.heros or {}
	show_data = GameUtil:getFormatPetTeamData(team, heros, false)
	-- 统计数据
	local attacker_stats = round_data.attacker_stats or {}
	local max_statistics_data = {}
	for k, v in pairs(show_data) do
		v.statistics_data = attacker_stats[v.card_id] or {}
		v.max_statistics_data = max_statistics_data
		for k1, v1 in pairs(v.statistics_data) do
			if max_statistics_data[k1 .. "_max"] == nil then
				max_statistics_data[k1 .. "_max"] = v1
			else
				max_statistics_data[k1 .. "_max"] = math.max(max_statistics_data[k1 .. "_max"], v1)
			end
		end
	end
	return show_data
end

function M:petDefShowData()
	local show_data = {}
	local battle = self.m_data.battle or {}
	local output = battle.output or {}
	local rounds = output.rounds or {}
	local round_data = rounds[1] or {}
	local defender_team = round_data.defender_team or {}
	local team = defender_team.team or {}
	local heros = defender_team.heros or {}
	show_data = GameUtil:getFormatPetTeamData(team, heros, false)
	-- 统计数据
	local defender_stats = round_data.defender_stats or {}
	local max_statistics_data = {}
	for k, v in pairs(show_data) do
		v.statistics_data = defender_stats[v.card_id] or {}
		v.max_statistics_data = max_statistics_data
		for k1, v1 in pairs(v.statistics_data) do
			if max_statistics_data[k1 .. "_max"] == nil then
				max_statistics_data[k1 .. "_max"] = v1
			else
				max_statistics_data[k1 .. "_max"] = math.max(max_statistics_data[k1 .. "_max"], v1)
			end
		end
	end
	return show_data
end

function M:optianalRelicData()
	local show_data = {}
	local heirlooms = self.m_data.drop_heirlooms or {}
	local heirloom = ConfigManager:getCfgByName("heirloom")
	for k,v in pairs(heirlooms) do
		local cfg = heirloom[v]
		if cfg then
			table.insert(show_data, {id = v, cfg = cfg})
		end
	end
	table.sort(show_data, function(data1, data2)
		return data1.cfg.quality > data2.cfg.quality
	end)
	return show_data
end


function M:destroy()
	M.super.destroy(self)
	-- local key = "battle_data_" .. self.m_mode
	-- UserDataManager:setTempData(key, nil)
end

return M



