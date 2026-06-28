local M = class("YinTowerModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("dark_tower_index")
end

function M:onEnter()
	self:updateDownTimeData()
	if self.m_data.update == 1 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		self.m_control:updateMsg(99999)
	end
	if self.m_data["end"] == 1 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		self.m_control:updateMsg(99999)
		return
	end
	self.current_flood = self.m_data.floor + 1
	self.is_battle = false
	self:getAssistHeroLv()
end

--更新数据
function M:updateServerData(serverdata)
	table.merge(self.m_data,serverdata)
	self.current_flood = self.m_data.floor + 1
end

function M:getAssistHeroLv()
	local lv = 0
	for i, v in pairs(self.m_data.assist_heros) do
		lv = v.lv or 300
		lv = GameUtil:getDisplayLvByHeroData({ lv = lv, clv = lv })
		break
	end
	return lv
end

function M:checkTeam()
	local cur_team = UserDataManager.hero_data:getTeamByKey("dark_tower")
	for i = 1, #cur_team do
		local hero_id = cur_team[i]
		if hero_id ~= "" then
			local hero_data, _ = UserDataManager.hero_data:getHeroDataById(hero_id)
			if not(self.m_data.assist_heros[hero_id]) and hero_data == nil then
				UserDataManager.hero_data:updateTeams({dark_tower = {}})
				return
			end
		end
	end
end

--判断最大层数
function M:isMaxFloor()
	local yinyang_tower = ConfigManager:getCfgByName("yinyang_tower")
	local vsn = self.m_data.vsn or 1
	local cur_cfg = yinyang_tower[vsn] or {}
	local max_floor = #cur_cfg
	return self.m_data.floor >= max_floor
end

--获取是否可碾压
function M:getQuickPass(position)
	local events = self.m_data.events[tostring(position)] or {}
	return events.quick_pass or 0
end

--获取是否可一键碾压 找到战力最大的能不能碾压
function M:getAutoQuickPass()
	local can_pass = 0
	local def_combat = 0
	for i, v in pairs(self.m_data.events) do
		if def_combat <= v.def_combat then
			def_combat = v.def_combat
			can_pass = v.quick_pass
		end
	end
	return can_pass
end

--获取每层显示数据
function M:getTowerStageData()
	local nfour_tower_stage = ConfigManager:getCfgByName("yinyang_tower_stage")
	return nfour_tower_stage[self.m_data.stage].events
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
	local yinyang_tower_version = ConfigManager:getCfgByName("yinyang_tower_version") or {}
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
	local team = UserDataManager.hero_data:getTeamByKey("dark_tower") or {}
	local assist_heros = self.m_data.assist_heros or {} --雇佣的英雄
	local heirlooms = self.m_data.heirlooms or {}
	return GameUtil:getHeirloomCombatAddRatio(team, assist_heros, heirlooms)
end

--获取队伍战力
function M:getHeroCombat()
	local team = UserDataManager.hero_data:getTeamByKey("dark_tower") or {}
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

--显示的里程奖励
function M:getDisPlayReward()
	local nfour_tower_reward_week = self:getTowerRewardWeek()
	local reward = nfour_tower_reward_week[1]
	local reward_id = 1
	if self.m_data.win_times >= reward.cfg.num then
		return reward,reward_id
	end
	for i, v in ipairs(nfour_tower_reward_week) do
		local isReceive = self:isReceive(v.id)
		if not isReceive and v.id < reward.id  then
			reward = nfour_tower_reward_week[i]
			reward_id = i
		end
	end
	return reward,reward_id
end

--获取最大奖励层数
function M:getMixReward()
	local nfour_tower_reward_week = self:getTowerRewardWeek()
	local reward_num = nfour_tower_reward_week[1].cfg.num
	for i, v in ipairs(nfour_tower_reward_week) do
		if v.cfg.num > reward_num then
			reward_num = v.cfg.num
		end
	end
	return reward_num
end

--获取里程列表显示以及高亮位置
function M:getDisPlayRewardPos()
	local nfour_tower_reward_week = self:getTowerRewardWeek()
	local display_num,display_id = 1,nfour_tower_reward_week[1].id
	for i, v in ipairs(nfour_tower_reward_week) do
		local next_floor_cfg = (i+1) <= #nfour_tower_reward_week and nfour_tower_reward_week[i+1] or nfour_tower_reward_week[i]
		if self.m_data.win_times >= next_floor_cfg.cfg.num and self.m_data.win_times < v.cfg.num then
			display_num = i
			display_id = v.id
			return display_num,display_id
		end
	end
	if self.m_data.win_times == 0 then
		display_num = #nfour_tower_reward_week
		display_id = nfour_tower_reward_week[#nfour_tower_reward_week].id
	end
	return display_num,display_id
end

--获取下一层奖励
function M:getNextReward()
	local nfour_tower_reward_week = self:getTowerRewardWeek()
	table.sort(nfour_tower_reward_week,function(data1,data2)
		return data1.id < data2.id
	end)
	for i, v in ipairs(nfour_tower_reward_week) do
		if v.cfg.num > self.m_data.win_times then
			return v,i
		end
	end
	return nfour_tower_reward_week[1],1
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
	self.m_activityData = UserDataManager:getActivesDataByOpenId(244)
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
