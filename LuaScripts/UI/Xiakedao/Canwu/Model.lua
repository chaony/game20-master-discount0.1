---@class CanwuModel:OODataBase
local M = class("CanwuModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("hero_isle_idle_show")
end

M.dataTime = 22

function M:onEnter()
	self.netDataTime = self.dataTime
	self.m_sel_tab_index =  nil
	self.m_event_point = 1
	self.m_no_get_pop = 0 --不再弹出奖励弹窗bl
	self.m_day = GameUtil:dayCompute()
	--self.m_no_get_pop = UserDataManager.local_data:getUserDataByKey("quick_hangreward_pop"..self.m_day, 0)
	--self.m_callback = self.m_params.callback
	--self.m_bag_pos = self.m_params.pos or Vector3(0,0,0)
	--self.m_target = self.m_params.target
	--self.m_mode = self.m_params.mode
	self.m_mode =1
	self.m_open_tab_index =1
	--self.m_double_id = UserDataManager.active_double_id
	--self.m_double_bl = GameUtil:checkDoubleActiveByType(1)
	self.m_double_bl = false
	self:initData()
	--self:getNum()

	local hero_isle_layer_cfg=ConfigManager:getCfgByName("hero_isle_layer")
	self.somelayer_cfg=hero_isle_layer_cfg[self.m_params.layer]

	self.bonus=1
	if self.m_data.privilege_bought==1 then
		self.bonus=self.m_params.hero_isle_privilege_cfg.bonus
		self.bonus=1+self.bonus
	end
end

function M:initData(data)
	if data then 
		self.m_data = data
	end
	--UserDataManager.idle_info.qi_free_times = self.m_data.qi_free_times or 0
	--UserDataManager.idle_info.qi_pay_times = self.m_data.qi_pay_times or 0
	--UserDataManager.idle_info.idle_start_time = self.m_data.idle_start_time
	--UserDataManager.idle_info.idle_end_time = self.m_data.idle_end_time
	--self.m_tim =  UserDataManager:getServerTime() - self.m_data.idle_start_ts
	self.reward = self.m_data.reward
	local money_guide = ConfigManager:getCfgByName("money_guide")
	local function listsort(data1,data2)
		local info = money_guide[data1[1]] or {}
		local info2 = money_guide[data2[1]] or {}
		local type_1 =  info.itype == 1 and 1 or 0 ----货币类型
		local type_2 =  info2.itype == 1 and 1 or 0
		if type_1 == type_2 then 
			return data1[1] < data2[1]
		else
			return type_1 > type_2	
		end
	end
	table.sort(self.reward, listsort)
	--新增挂机奖励排序 货币资源展示在最前面
	--local tab_cfg = ConfigManager:getCfgByName("vip")
	--local cur_vip = 0
	--local vip_cfg = tab_cfg[cur_vip]
	--local hour = vip_cfg.idle_time_limit

	--self.max_second = self.m_data.idle_end_ts - self.m_data.idle_start_ts
	self:refreshTime(self.m_data.idle_start_ts,self.m_data.idle_end_ts)
end

function M:getTime()
	return GameUtil:formatTimeBySecond(math.min(self.max_second, (UserDataManager:getServerTime() - self.start_ts)), 999)
end

function M:refreshTime(start_ts,end_ts)
	self.max_second = end_ts - start_ts
	self.start_ts=start_ts
end

function M:getDownEndTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(UserDataManager:getServerTime())
	local time = next_fresh_time + 24 * 3600
	return GameUtil:formatTimeBySecond(time - UserDataManager:getServerTime(), 999)
end

function M:getTarget()
	local bag_img = static_rootControl.m_view:findGameObject("bag_btn")
	return bag_img
end

function M:checkMaxTim(tim)
	if tim < 0 then
		return 0
	end
	if tim >= self.max_second then
		return GameUtil:formatTimeBySecond(self.max_second)  
	else
		return GameUtil:formatTimeBySecond(tim)	
	end
end

--快速挂机展示的奖励
function M:getQuickShowReward()
	local stage_id = UserDataManager:getCurStage()
	local stage_tab = ConfigManager:getCfgByName("stage_idle_show")
	for k = 1, #stage_tab do 
		local cur_tab = stage_tab[k]
		if k < #stage_tab then
			local next_tab = stage_tab[k+1]
			if cur_tab.stage_id <= stage_id and next_tab.stage_id > stage_id then
				return self:getQuickShowSeasonReward(cur_tab)
			end
		end
	end
	return  self:getQuickShowSeasonReward(stage_tab[#stage_tab])--stage_tab[#stage_tab].idle_reward_show
end

function M:getQuickShowSeasonReward(cur_stage_idle_cfg)
	local cur_season = UserDataManager:getCurSeason()
	local total_idle_reward = {}
	if cur_stage_idle_cfg.season_reward_show and next(cur_stage_idle_cfg.season_reward_show) then
		local season_reward_show = cur_stage_idle_cfg.season_reward_show
		for seaon = 0, cur_season do
			if season_reward_show[seaon] then
				local season_idle_reward = season_reward_show[seaon]
				for i = 1, #season_idle_reward do
					total_idle_reward[#total_idle_reward + 1] = season_idle_reward[i]
				end
			end
		end
	else
		total_idle_reward = cur_stage_idle_cfg.idle_reward_show
	end
	
	--超前开启条件
	if cur_season < 2 then
		local cur_stage = UserDataManager:getCurStage()
		if cur_stage >= 3438 then
			local idle_reward_show3 = cur_stage_idle_cfg.idle_reward_show3
			if idle_reward_show3 and next(idle_reward_show3) then
				for i = 1, #idle_reward_show3 do
					total_idle_reward[#total_idle_reward + 1] = idle_reward_show3[i]
				end
			end
		end
	end
	
	return total_idle_reward
end

--挂机收益表
function M:getStagepIdle()
    local stage_id = UserDataManager:getCurStage()
    local stage_tab = ConfigManager:getCfgByName("stage")
    local stage_idle_tab = ConfigManager:getCfgByName("stage_idle")
    local idle_id =  stage_tab[stage_id].idle_id
    local idle_cfg = stage_idle_tab[idle_id]
    return idle_cfg
end

--挂机突破丹收益表
function M:getStagepIdle2()
    local stage_id = UserDataManager:getCurStage()
    local stage_tab = ConfigManager:getCfgByName("stage")
    local stage_idle_tab = ConfigManager:getCfgByName("stage_idle")
    local idle_id =  stage_tab[stage_id].idle_id
	local idle_cfg = stage_idle_tab[idle_id]
	local dust = idle_cfg.idle_drop.dust
	local idle_drop = ConfigManager:getCfgByName("idle_drop")
	local item = idle_drop[dust[1]]
    return item.random_reward.rewards[1][3], dust[2]
end

--悬赏令收益表
function M:getStagepIdle3()
    local stage_id = UserDataManager:getCurStage()
    local stage_tab = ConfigManager:getCfgByName("stage")
    local stage_idle_tab = ConfigManager:getCfgByName("stage_idle")
    local idle_id =  stage_tab[stage_id].idle_id
	local idle_cfg = stage_idle_tab[idle_id]
	local dust = idle_cfg.idle_drop.idle_drop7 or {}
	local idle_drop = ConfigManager:getCfgByName("idle_drop")
	if next(dust) ~= nil then
		local item = idle_drop[dust[1]]
		return item.random_reward.rewards[1][3], dust[2]
	end
	return 0,0
end

--挂机玄铁尘收益表
function M:getStagepIdle4()
    local stage_id = UserDataManager:getCurStage()
    local stage_tab = ConfigManager:getCfgByName("stage")
    local stage_idle_tab = ConfigManager:getCfgByName("stage_idle")
    local idle_id =  stage_tab[stage_id].idle_id
	local idle_cfg = stage_idle_tab[idle_id]
	local dust = idle_cfg.idle_drop_2.equip_exp
	if dust == nil then
		return 0,0
	end
	local idle_drop = ConfigManager:getCfgByName("idle_drop")
	local item = idle_drop[dust[1]]
	--产出数量   间隔时间
    return item.random_reward.rewards[1][3], dust[2]
end

--掉落突破丹
function M:getQuickIdlePlayerExp()
	local item_num, inter  = self:getStagepIdle2()
	local num = item_num * 7200
    return math.floor(num/inter)
end

--掉落金币
function M:getIdleMoney()
	local cfg = self:getStagepIdle()
	local coin_add, hero_exp_add = self:getVipAdd()
	local num = ((60/cfg.rewards_cd)*cfg.coin)
	local add_num = 1+coin_add
    return GameUtil:formatNum(num* add_num) 
end

--每分钟侠隐宝玉
function M:getIdleHERO_ISLE_COIN()
	local per_minute_value=0
	if self.somelayer_cfg then
		local cfg=self.somelayer_cfg.idle_drops[1]
		local minute=cfg.cd/60

		per_minute_value=cfg.rewards[1][3]/minute
		per_minute_value=self.bonus*per_minute_value
		per_minute_value=string.format("%.1f",per_minute_value)
	end
	return per_minute_value
end

--每分钟铜币
function M:getIdleCoin()

	local per_minute_value=0
	if self.somelayer_cfg then
		local cfg=self.somelayer_cfg.idle_drops[2]
		local minute=cfg.cd/60

		per_minute_value=cfg.rewards[1][3]/minute
		per_minute_value=self.bonus*per_minute_value
		per_minute_value=string.format("%.1f",per_minute_value)
	end
	return per_minute_value
end

--掉落 悬赏令
function M:getIdleXSL()
	local item_num, inter  = self:getStagepIdle3()
	local num = item_num * 60
	if item_num == 0 then
		return 0
	end
    return math.floor(num/inter)
end

function M:getQuickItem()
	local q_item = ConfigManager:getCommonValueById(338)
    local itemData = RewardUtil:getProcessRewardData(q_item[1])
	return itemData
end

--掉落英雄经验
function M:getIdleHeroExp()
	local cfg = self:getStagepIdle()
	local coin_add, hero_exp_add = self:getVipAdd()
	local num = ((60/cfg.rewards_cd)*cfg.hero_exp)
	local add_num = 1+hero_exp_add
    return GameUtil:formatNum(num*add_num)
end

--掉落玩家经验
function M:getIdlePlayerExp()
    local cfg = self:getStagepIdle()
	local num = ((60/cfg.rewards_cd)*cfg.player_exp)
    return GameUtil:formatNum(num)
end

--掉落玄铁尘
function M:getIdleEquipExp()
	local season = UserDataManager:getCurSeason()
	if season < 2 then
		return 0
	end
	local item_num, inter = self:getStagepIdle4()
	local num = ((60/inter)*item_num)
	local user_data = UserDataManager.user_data
	local vip = user_data:getUserStatusDataByKey("vip")
	local vip_cfg = ConfigManager:getCfgByName("vip")[vip] or ConfigManager:getCfgByName("vip")[1]
	local ratio = vip_cfg.idle_equip_exp or 0
    return GameUtil:getPreciseDecimal(num * (1 + ratio),1 )
end

function M:getVipAdd()
	local user_data = UserDataManager.user_data
	local vip = user_data:getUserStatusDataByKey("vip")
	local vip_cfg = ConfigManager:getCfgByName("vip")[vip] or ConfigManager:getCfgByName("vip")[1]
	return vip_cfg.idle_coin, vip_cfg.idle_hero_exp
end

--快速挂机次数
function M:getNum()
	local now_tim = UserDataManager:getServerTime()
	local user_data = UserDataManager.user_data
	local vip = user_data:getUserStatusDataByKey("vip")
	local vip_cfg = ConfigManager:getCfgByName("vip")[vip] or ConfigManager:getCfgByName("vip")[1]
	--快速挂机次数
	self.use_num = UserDataManager.idle_info.qi_free_times + UserDataManager.idle_info.qi_pay_times --已使用的次数
	local free_num = ConfigManager:getCommonValueById(337) or 1
	local subscr_tim = 0 
	local idle_auto_etime = UserDataManager.m_subscribe.idle_auto_etime or 0
	local end_time = idle_auto_etime - UserDataManager:getServerTime()
	if idle_auto_etime > 0 and end_time > 0 then
		local sub_tab = ConfigManager:getCfgByName("auto_subscribe")
		local sub_cfg = sub_tab[3]
		subscr_tim = sub_cfg.diamond_quick_times + sub_cfg.free_quick_times
	end
	local all_num = table.copy(vip_cfg.quick_idle_times) + free_num + subscr_tim  --加上免费次数
	self.m_quick_idle_times = all_num - self.use_num
	if self.m_quick_idle_times < 0 then
		self.m_quick_idle_times = 0
	end
	self.m_down_tim  = UserDataManager.end_ts - now_tim
end

--是否还有免费
function M:quickFree()
	local f_num = ConfigManager:getCommonValueById(337)
	idle_auto_etime =  UserDataManager.m_subscribe.idle_auto_etime or 0
	local end_time =  idle_auto_etime - UserDataManager:getServerTime()
	if idle_auto_etime > 0 and end_time > 0 then
		local sub_tab = ConfigManager:getCfgByName("auto_subscribe")
		local sub_cfg = sub_tab[3]
		f_num = f_num + sub_cfg.free_quick_times
	end
	if f_num > UserDataManager.idle_info.qi_free_times then
		return true
	end
	return false
end

--快速挂机奖励
function M:getNumByType(t)
	if t == RewardUtil.REWARD_TYPE_KEYS.DUST then
		return self:getQuickIdlePlayerExp()
	elseif	t == RewardUtil.REWARD_TYPE_KEYS.COIN then
		local num = self:getIdleMoney()
		return math.floor(num * 120) 
	elseif	t == RewardUtil.REWARD_TYPE_KEYS.HERO_EXP then
		local num = self:getIdleHeroExp()
		return math.floor(num * 120) 
	elseif	t == RewardUtil.REWARD_TYPE_KEYS.EXP then
		local num = self:getIdlePlayerExp()
		return math.floor(num * 120) 
	elseif	t == RewardUtil.REWARD_TYPE_KEYS.EQUIP_EXP then
		local num = self:getIdleEquipExp()
		return math.floor(num * 120) 
	end
	return 0
end

function M:getCost()
	local renovate_tab = ConfigManager:getCfgByName("renovate")
	local cfg = renovate_tab[5]
	return cfg.cost[UserDataManager.idle_info.qi_pay_times + 1]
end

function M:getCfg()
	local id = self.m_data.idle_events[self.m_event_point]
	local _cfg = ConfigManager:getCfgByName("idle_event")
	return _cfg[id]
end

function M:getRewardByType(id)
	for k,v in pairs(self.reward) do
		if id == v[1] then
			return v[3]
		end
	end
	return 0
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "get_idle_reward" then
		Logger.log(data,"GG")
	elseif tag == "idle_reward_show" then
		self:initData(data)
	end
end

return M
