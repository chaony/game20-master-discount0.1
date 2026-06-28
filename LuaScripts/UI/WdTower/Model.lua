local M = class("WdTowerModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("wdtower_index")
end

function M:onEnter()
	self.m_wdtower_battle_cfg = ConfigManager:getCfgByName("wdtower_battle")
	self.m_wdtower_stage_cfg = ConfigManager:getCfgByName("wdtower_stage")
	local wdtower_reward = ConfigManager:getCfgByName("wdtower_reward")
	self.m_wdtower_score_cfg = ConfigManager:getCfgByName("wdtower_score")
	self:updateServerData()
	self:updateDownTimeData()
	if self.m_data.update == 1 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		self:updateMsg(99999)
	end
	if self.m_data["end"] == 1 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		self:updateMsg(99999)
		return
	end
	self.current_flood = self.m_data.floor + 1
	self.is_battle = false
	self:getAssistHeroLv()
end

function M:getEnemyScore()
	local cur_combat = self.m_data.top5_combat or 0
	local score_tab = {0,0,0}
	for i, v in ipairs(self.m_wdtower_score_cfg) do
		local ability = v.ability
		if cur_combat >= ability[1] and cur_combat < ability[2] then
			score_tab[1] = v.score1
			score_tab[2] = v.score2
			score_tab[3] = v.score3
		end
	end
	return score_tab
end

function M:getRaceType()
	local player_type = self:getTowerStageRace()
	local race_num_tab = {}
	for i, v in pairs(player_type) do
		if race_num_tab[tonumber(v)] == nil then
			race_num_tab[tonumber(v)] = 1
		else
			race_num_tab[tonumber(v)] = 1 + race_num_tab[tonumber(v)]
		end
	end
	return race_num_tab
end

function M:getResetTimes()
	local total_times = self:getDesByKey("day_remake") or 3
	local cur_times = self.m_data.reset_times or 0
	local reset_times = math.max(0, total_times - cur_times)
	return reset_times
end

function M:getBattleCfgByKey(cfg_key)
	local floor = self.m_data.floor or 1
	local cur_vsn_cfg = self.m_wdtower_battle_cfg[self.m_version] or {}
	local cur_floor_cfg = cur_vsn_cfg[self.current_flood] or {}
	local value = cur_floor_cfg[cfg_key]
	return value
end

function M:getCellScaleAndPos()
	local floor = self.m_data.floor or 1
	local cur_vsn_cfg = self.m_wdtower_battle_cfg[self.m_version] or {}
	local cur_floor_cfg = cur_vsn_cfg[self.current_flood] or {}
	local bg_name = cur_floor_cfg.background or ""
	return bg_name
end

--更新数据
function M:updateServerData(serverdata)
	table.merge(self.m_data,serverdata)
	self.current_flood = self.m_data.floor + 1
	self.m_version = self.m_data.vsn or 1
	self.m_day = self.m_data.day or 1
end

function M:getAssistHeroLv()
	local lv = 0
	--for i, v in pairs(self.m_data.assist_heros) do
	--	lv = v.lv or 300
	--	lv = GameUtil:getDisplayLvByHeroData({ lv = lv, clv = lv })
	--	break
	--end
	return lv
end

function M:getOtherNums()
	local race_num_tab = self:getRaceType()
	local other_nums = 5
	local yin_nums = race_num_tab[6] or 0
	local yang_nums = race_num_tab[5] or 0
	other_nums = other_nums - yin_nums - yang_nums
	return other_nums
end

function M:checkTeam()
	local race_num_tab = self:getRaceType()
	local cur_num_tab = {}
	local cur_team = UserDataManager.hero_data:getTeamByKey("wdtower")
	local change_flag = false
	local otherNums = self:getOtherNums()
	for i = 1, #cur_team do
		local hero_id = cur_team[i]
		if hero_id ~= "" then
			local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
			if race_num_tab[hero_cfg.race] == nil and hero_cfg.race ~= 7 then
				cur_team[i] = ""
				change_flag = true
			elseif hero_cfg.race == 7 and otherNums == 0 then --本期只能上阴阳卡的情况
				cur_team[i] = ""
				change_flag = true
			else
				if hero_cfg.race ~= 7 then
					if cur_num_tab[hero_cfg.race] == nil then
						cur_num_tab[hero_cfg.race] = 1
					else
						cur_num_tab[hero_cfg.race] = 1 + cur_num_tab[hero_cfg.race]
					end
					if cur_num_tab[hero_cfg.race] > race_num_tab[hero_cfg.race] or ( hero_cfg.race < 5 and otherNums <=0) then
						cur_team[i] = ""
						change_flag = true
					elseif hero_cfg.race < 5 then
						otherNums = otherNums - 1
					end
				elseif hero_cfg.race == 7 then
					if otherNums <= 0 then
						cur_team[i] = ""
						change_flag = true
					else
						otherNums = otherNums - 1
					end
				end
			end
		end
	end
	return change_flag
end

--判断最大层数
function M:isMaxFloor()
	return false
	--local yinyang_tower = ConfigManager:getCfgByName("yinyang_tower")
	--local vsn = self.m_data.vsn or 1
	--local cur_cfg = yinyang_tower[vsn] or {}
	--local max_floor = #cur_cfg
	--return self.m_data.floor >= max_floor
end

--获取是否可碾压
function M:getQuickPass(position)
	local events = self.m_data.events[tostring(position)] or {}
	return events.quick_pass or 0
end

--获取每层显示数据
function M:getTowerStageData()
	local nfour_tower_stage = ConfigManager:getCfgByName("wdtower_stage")
	return nfour_tower_stage[self.m_data.stage].events
end

--获取每层显示数据
function M:getTowerStageRace()
	local nfour_tower_stage = ConfigManager:getCfgByName("wdtower_battle") or {}
	local cur_cfg = nfour_tower_stage[self.m_version] or {}
	return cur_cfg[self.current_flood].palyer_type
end

function M:getTowerStageBattleScale()
	local battle_scale = {1,1,1}
	local nfour_tower_stage = ConfigManager:getCfgByName("wdtower_battle") or {}
	local cur_cfg = nfour_tower_stage[self.m_version] or {}
	for i = 1, 3 do
		if cur_cfg[self.current_flood]["battle" .. i] and cur_cfg[self.current_flood]["battle" .. i] ~= 0 then
			battle_scale[i] = cur_cfg[self.current_flood]["battle" .. i]
		end
	end
	return battle_scale
end

--获取英雄信息
function M:getHeroInfo(hero_id)
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	return hero_detail[hero_id]
end

--获取当前事件奖励
function M:getEventsGifs(position)
	local events = self.m_data.events[tostring(position)] or {}
	return events.gifts
end

--获取遗物id
function M:getHeirloomId(position)
	local events = self.m_data.events[tostring(position)] or {}
	return events.heirloom_id
end

function M:getDesByKey(get_key)
	local vsn = self.m_data.vsn or 1
	local yinyang_tower_version = ConfigManager:getCfgByName("wdtower_base") or {}
	if yinyang_tower_version and yinyang_tower_version[vsn] and yinyang_tower_version[vsn][get_key] then
		return yinyang_tower_version[vsn][get_key]
	end
	return nil
end

function M:getCurRaceByVsnAndDay()
	local yinyang_tower_npc = ConfigManager:getCfgByName("yinyang_tower_npc")
	local vsn = self.m_data.vsn or 1
	local day = self.m_data.day or 1
	local races = {}
	if yinyang_tower_npc[vsn] then
		day = math.min(day, #yinyang_tower_npc[vsn])
		if yinyang_tower_npc[vsn][day] then
			races = yinyang_tower_npc[vsn][day]["race"]
		end
	end 
	return races
end

--获取遗物奖励
function M:getHeirloom(position)
	local heirloom_id = self:getHeirloomId(position)
	local heirloom = ConfigManager:getCfgByName("heirloom")
	return heirloom[heirloom_id]
end

--获取当前事件敌人等级
function M:getHeroLv(position)
	local events = self.m_data.events[tostring(position)] or {}
	for i, v in pairs(events.heros) do
		return v.lv
	end
end

--获取四象阵碾压所需的战斗力比例
function M:getRolling()
	local common = ConfigManager:getCfgByName("common")
	return common[508].value or 0.8
end

--获取付费宝箱消耗
function M:getDiamond()
	local common = ConfigManager:getCfgByName("common")
	local money = self.m_data.buy_box_times + 1 > #common[488].value and common[488].value[#common[488].value] or common[488].value[self.m_data.buy_box_times + 1]
	return money or 0
end

--获取四象阵每周增加次数
function M:getWeekTimes()
	local common = ConfigManager:getCfgByName("common")
	return common[502].value or 0
end


--计算是否可以碾压
function M:battleOrRolling(position)
	local rolling = self:getRolling()
	local enemy_combat = self:getEnemyCombat(position) --战力
	local user_combat = self:getHeirloomCombatAddRatio() + 1
	local hero_combat = self:getHeroCombat()
	local compete_value = hero_combat * user_combat * rolling
	if compete_value > enemy_combat then
		return 1 --碾压
	end
	return 0  --挑战
end

--敌人的战力
function M:getEnemyCombat(position)
	local events = self.m_data.events[tostring(position)] or {}
	local atk_team = events.heros or {} --队伍
	local enemy_combat = 0 --战力
	for k, v in pairs(atk_team) do
		if v.combat ~= nil then
			enemy_combat = v.combat + enemy_combat
		end
	end
	return enemy_combat
end

-- 遗物战斗力加成计算
function M:getHeirloomCombatAddRatio()
	local team = UserDataManager.hero_data:getTeamByKey("wdtower") or {}
	local assist_heros = self.m_data.assist_heros or {} --雇佣的英雄
	local heirlooms = self.m_data.heirlooms or {}
	return GameUtil:getHeirloomCombatAddRatio(team, assist_heros, heirlooms)
end

--获取队伍战力
function M:getHeroCombat()
	local team = UserDataManager.hero_data:getTeamByKey("wdtower") or {}
	local hero_combat = 0
	for i, v in pairs(team) do
		local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
		local combat = 0
		if hero_data ~= nil then
			combat = UserDataManager:computeHeroCombat(hero_data, hero_cfg)
		end
		hero_combat = hero_combat + combat
	end
	return hero_combat
end

--根据id获得英雄数据
function M:getHero(id)
	local hero_data, hero_cfg = nil
	hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(id)
	return hero_data, hero_cfg
end

--获取当前层类型
function M:getMultiple()
	--local nfour_tower = ConfigManager:getCfgByName("nfour_tower")
	--return nfour_tower[self.m_data.floor].multiple
end

--宝箱层获取宝箱领取状态
function M:getIsStatue(position)
	local events = self.m_data.events[tostring(position)] or {}
	return events.status
end

--判断是否可以下一层 true：可以到下一层 fales：不能到下一层
function M:IsNextFlood()
	local events = self.m_data.events or {}
	for i, v in pairs(events) do
		if v.status == 1 then
			return true
		end
	end
	return false
end

--获取里程奖励数据
function M:getTowerRewardWeek()
	local reward = {}
	local nfour_tower_reward_week = ConfigManager:getCfgByName("nfour_tower_reward_week")
	for i, v in pairs(nfour_tower_reward_week[self.m_data.week_group].detail) do
		local is_status = self:setStatus(i,v)
		table.insert(reward,{id = i,cfg = v,status = is_status})
	end
	table.sort(reward,function(data1,data2)
		return data1.id > data2.id
	end)
	return reward
end

--设置奖励状态
function M:setStatus(id,cfg)
	local is_receive = self:rewardIsReceive(id)
	local is_flood = self.m_data.win_times
	if is_receive then --已领取
		return -1
	elseif is_flood >= cfg.num and not is_receive then --可领取
		return 2
	else
		return 0
	end
	return 0
end

--是否已领取奖励
function M:rewardIsReceive(id)
	if self.m_data.received ~= nil then
		for i, v in ipairs(self.m_data.received) do
			if v == id then
				return true
			end
		end
	end
	return false
end

--奖励是否领取
function M:isReceive(id)
	for i, v in ipairs(self.m_data.received) do
		if v == id then
			return true
		end
	end
	return false
end

--获取vip额外购买次数(四象阵每周额外挑战次数)
function M:getExtraTime()
	local vip = ConfigManager:getCfgByName("vip")
	local userdata = UserDataManager.user_data
	local current_vip = userdata["user_status"]["vip"]
	return vip[current_vip].four_tower_open_times or 0
end

--返回剩余可挑战次数
function M:getRemainTimes()
	local week_times = self:getWeekTimes()
	local vip_times = self:getExtraTime()
	local remain_times = week_times + vip_times - self.m_data.clg_times
	return remain_times
end

--获取难度等级
function M:getFloodDifficulty()
	local events = self.m_data.events or {}
	for i, v in pairs(events) do
		if v.type == 2 then
			for i, v in pairs(v.heros) do
				UserDataManager.local_data:setLocalDataByKey("YinYangDifficulty",v.lv)
				return v.lv
			end
		end
	end
	return UserDataManager.local_data:getLocalDataByKey("YinYangDifficulty",1)
end

function M:updateDownTimeData()
	self.m_activityData = UserDataManager:getActivesDataByOpenId(294)
end

function M:getEndTs()
	if self.m_activityData and self.m_activityData.end_ts then
		return self.m_activityData.end_ts - UserDataManager:getServerTime()
	end
	return 0
end

function M:getActStatus()
	if self.m_activityData and self.m_activityData.open_status then
		return self.m_activityData.open_status
	end
	return 0
end
return M
