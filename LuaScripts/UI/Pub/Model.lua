local M = class("PubPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("gacha_index")
	--self.m_transfer = "animation"
	--self.m_anim_name = "Pub_Enter"
end

function M:onEnter()
	self.m_index = 2
	self.m_pool_id = 1
	self.m_last_chest_times = self.m_data.cur_chest_times
	self.m_last_chest_rank = self.m_data.cur_chest_rank
	
	self.m_skip_anim_flag = UserDataManager.local_data:getUserDataByKey("gacha_skip_anim_flag", false)
	--槽位
	self.slot = {
		[1] = {
			hero_id = 0,
			finish = 0,
		},
		[2] = {
			hero_id = 0,
			finish = 0,
		},
		[3] = {
			hero_id = 0,
			finish = 0,
		},
	}
	--心愿单数据
	self.m_bless_data = 
	{
		--祝福值
		bless_value = self.m_data.bless_value;
		--祝福值侠客
		bless_hero = self.m_data.bless_hero;
		--祝福值抽卡侠客 旧（对线上对兼容）
		bless_success = self.m_data.bless_success;
		--祝福值抽卡侠客 新
		bless_received = self.m_data.bless_received;
		--普通抽次数
		normal_times = self.m_data.normal_times;
		--英雄祝福列表
		hero_wish_list = self.m_data.hero_wish_list;
		--已经实现的侠客
		wish_success =  self.m_data.wish_success;
		--祝福次数
		cur_bless_times = self.m_data.cur_bless_times;
		--最大祝福次数
		max_bless_times = self.m_data.max_bless_times;
	}
	if self.m_data.normal_times > 10 then
		self.frist_purple = 1
	else
		self.frist_purple = self.m_data.first_purple
	end
	self.week_etime = self.m_data.week_etime
	self.m_show_reward = {}
	self.m_lock_change = false
	self.hero_detail = ConfigManager:getCfgByName("hero_detail")
	self:updateData()
	self:updateMaxValue()
	self:updateSlot(self.m_bless_data.hero_wish_list)
	self.m_is_yinyang = false --祝福侠客是否是阴阳卡

	--积分
	local gacha_cfg = ConfigManager:getCfgByName("gacha")
	self.m_score_consume = gacha_cfg[GlobalConfig.GACHA_SCORE_ID].cost[1][3]
	self.m_score = self.m_data.integral
end

--是否是已经实现的英雄
function M:isFinishHero( hero_id )
	for i, v in ipairs(self.m_bless_data.wish_success) do
		if v == hero_id then
			return 1
		end
	end
	return 0
end
 
function M:updateBlessData( data )
	if data.gacha_data.bless_value ~= nil then
		self.m_bless_data.bless_value = data.gacha_data.bless_value
	end
	if data.gacha_data.bless_hero ~= nil then
		self.m_bless_data.bless_hero = data.gacha_data.bless_hero
	end
	if data.gacha_data.bless_success ~= nil then
		self.m_bless_data.bless_success = data.gacha_data.bless_success
	end
	if data.gacha_data.bless_received ~= nil then
		self.m_bless_data.bless_received = data.gacha_data.bless_received
	end
	if data.gacha_data.normal_times ~= nil then
		self.m_bless_data.normal_times = data.gacha_data.normal_times
	end
	if data.gacha_data.hero_wish_list ~= nil then
		self.m_bless_data.hero_wish_list = data.gacha_data.hero_wish_list
	end
	if data.gacha_data.wish_success ~= nil then
		self.m_bless_data.wish_success = data.gacha_data.wish_success
	end
	if self.m_bless_data.hero_wish_list ~= nil then
		self:updateSlot(self.m_bless_data.hero_wish_list)
	end
	self.m_bless_data.cur_bless_times = data.gacha_data.cur_bless_times
	self.m_bless_data.max_bless_times = data.gacha_data.max_bless_times
	self:updateMaxValue()
end

function M:getGachaHyperbless()
	local gacha_hyperbless = ConfigManager:getVipValueByKey("gacha_hyperbless", 0)
	return gacha_hyperbless
end

function M:getYinYangTimes()
	local yinyang_times =  ConfigManager:getCommonValueById(516, 0)
	return yinyang_times
end

function M:getBlessTimes()
	local hero_cfg = ConfigManager:getCfgByName("hero_detail")[self.m_bless_data.bless_hero]
	local yinyang_success_times = 0
	local success_times = 0
	if hero_cfg ~= nil then
		self.m_is_yinyang = hero_cfg.race > 4
		local bless_success = self.m_bless_data.bless_received and self.m_bless_data.bless_received or {}
		for k, v in pairs(bless_success) do
			if tonumber(k) > 4 then
				yinyang_success_times = yinyang_success_times + bless_success[k]
			elseif tonumber(k) <= 4 then
				success_times = success_times + bless_success[k]
			end
		end
	end
	return yinyang_success_times, success_times
end

function M:updateMaxValue()
	--龙庭（青龙）金--race_id 1
	--草莽（朱雀）火--race_id 2
	--世族（玄武）木--race_id 3
	--异族（白虎) 水--race_id 4
	--阳--race_id 5
	--阴--race_id 6
	local hero_cfg = ConfigManager:getCfgByName("hero_detail")[self.m_bless_data.bless_hero]
	if hero_cfg == nil then
		self.maxValue = 100
		return
		--self.m_is_yinyang = hero_cfg.race > 4
		--local value_list = { 100 }
		--if hero_cfg.race == 5 or hero_cfg.race == 6 then
		--	value_list = ConfigManager:getCommonValueById(429)
		--else
		--	value_list = ConfigManager:getCommonValueById(428)
		--end
		--local yinyang_times, times = self:getBlessTimes()
		--local index = self.m_is_yinyang and yinyang_times or times
		--if value_list ~= nil and #value_list > 1 then
		--	self.maxValue = value_list[index+1] or value_list[#value_list]
		--else
		--	self.maxValue = 999;
		--end
	end
	local index = hero_cfg["gacha_bless_cost_id"] --通过此配置获得下标索引
	index = index + 1 --对应0开始的下标
	local value_list = ConfigManager:getCommonValueById(428)
	self.maxValue = value_list[index]
end

--更新栏位
function M:updateSlot( data )
	for i, v in ipairs(data) do
		self.slot[i].hero_id = v
		self.slot[i].finish = self:isFinishHero(v)
	end
end

--更新 祝福 英雄
function M:update_bless_hero( data )
	self.m_bless_data.bless_hero = data.bless_hero
end


function M:update_hero_wish_list( data )
	self.m_bless_data.hero_wish_list = data.hero_wish_list
	self:updateSlot(self.m_bless_data.hero_wish_list)
end

function M:getSendSlot()
	return self.slot
end

--获取英雄数据
function M:getHeroData(hero_id)
	local hero_cfg = self:getHero(hero_id)
	--获取道具人物头像数据
	local itemData = RewardUtil:getHeroConfigData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_cfg.id, 1})
	itemData.quality = hero_cfg.evo
	itemData.oid = hero_cfg.oid
	return itemData
end

--根据id获得英雄数据
function M:getHero(id)
	local hero_data_config = self.hero_detail[id]
	if hero_data_config ~= nil then
		local hero_data_config_copy = table.copy(hero_data_config)
		--得到当前英雄id的我拥有的所有英雄
		local heros = UserDataManager.hero_data:getHeroIdsByCid( id )
		if #heros >0 then
			local max_evo = 1
			local oid = 1
			for i, v in pairs(heros) do
				local hero_data = UserDataManager.hero_data:getHeroDataById(v)
				if hero_data.evo > max_evo then
					max_evo = hero_data.evo
					oid = hero_data.oid
				end
			end
			hero_data_config_copy.evo = max_evo
			hero_data_config_copy.oid = oid
		end
		return hero_data_config_copy
	else
		return nil
	end
end

function M:setSelectIndex(index)
	self.m_index = index
	self.m_pool_id = self.m_list_data[index]
end

function M:updateData(data)
	if data then
		self.m_data = data
	end
	--Logger.log(self.m_data,"self.m_data ====")
	local races = UserDataManager.gacha_open_race_pools
	--self.m_race = data and self.m_data.cur_gacha_race or races[1]
	self.m_race = self.m_data.cur_gacha_race or  races[1]  -- 种族对应 pool_id 取值3456
	self.m_list_data = {1,2,self.m_race}
	self:setSelectIndex(self.m_index)
end

function M:updateChestRewards(data)
	self.m_data.chest_rewards = data.chest_rewards
end

function M:canReceiveRewards()
	if self.m_data.chest_rewards and next(self.m_data.chest_rewards[tostring(self.m_index)] or {}) then
		return true
	end
	return false
end

function M:mergeReward(reward)
	for k,v in pairs(reward or {}) do
		if self.m_show_reward[k] then
			if k == "item" then
				for kk,vv in pairs(v) do
					if self.m_show_reward[k][kk] then
						self.m_show_reward[k][kk] = self.m_show_reward[k][kk] + vv
					else
						self.m_show_reward[k][kk] = vv
					end
				end
			else
				if self.m_show_reward[k] then
					self.m_show_reward[k] = self.m_show_reward[k] + v
				else
					table.insert(self.m_show_reward[k],v)
				end
			end
		else
			self.m_show_reward[k] = v
		end
	end
end

function M:redPointCheck(index)
	local pool_id = self.m_list_data[index]
	if pool_id == nil then
		return false
	end
	local gacha = ConfigManager:getCfgByName("gacha")[pool_id]
	--for i,v in ipairs(gacha.cost) do
	--	local itemData = RewardUtil:getProcessRewardData(v)
	--	if itemData.user_num >= itemData.data_num then
	--		if itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
	--			return true
	--		end
	--		break
	--	end
	--end
	local ten_cost = gacha.ten_cost
	if UserDataManager:hasGachaSubscribe() then
		ten_cost = gacha.special_ten_cost
	end

	for i,v in ipairs(ten_cost or {}) do
		local itemData = RewardUtil:getProcessRewardData(v)
		if itemData.user_num >= itemData.data_num then
			if itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
				return true
			end
		else
			if index == 1 then
				local min_count = gacha.limit or 10
				local once_cost = gacha.cost_item[1][3]
				if itemData.user_num >= min_count*once_cost and itemData.user_num > 0  then
					return true
				end
			elseif index == 2 and itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
				local min_count = gacha.limit or 10
				--if itemData.user_num >= min_count and itemData.user_num > 0  then
				--	return true
				--end
			elseif index == 3 then
				local min_count = gacha.limit or 10
				if itemData.user_num >= min_count and itemData.user_num > 0  then
					return true
				end
			end
		end
	end
	return false
end

function M:getSubDiamond()
	local consume_diamond = self.m_data.consume_diamond
	local all_num = (consume_diamond * ConfigManager:getCommonValueById(422))*0.01
	return GameUtil:formatNum(all_num)
end

function M:isMaxTime()
	local max_times = self:getGachaLimitNums()
	local cur_times = self.m_data.today_times_dict[tostring(self.m_index)] or 0
	local is_max_time = false
	if max_times == 0 then
	elseif cur_times >= max_times then
		is_max_time = true
	end
	return is_max_time
end

function M:getGachaLimitNums()
	local limit_id = 0
	if self.m_index == 2 then
		limit_id = 441
	elseif self.m_index == 3 then
		limit_id = 442
	end
	local max_times = ConfigManager:getCommonValueById(limit_id,0)
	return max_times
end

function M:changeSkipAnimFlag()
	self.m_skip_anim_flag = not self.m_skip_anim_flag
	UserDataManager.local_data:setUserDataByKey("gacha_skip_anim_flag", self.m_skip_anim_flag)
end

--是否已经兑换过
function M:hasBless(hero_id)
	local bless_received = self.m_bless_data.bless_received
	if bless_received == nil or #bless_received == 0 then
		return false
	end
	for k,v in pairs(bless_received) do
		if hero_id == v then
			return true
		end
	end
	return false
end

return M