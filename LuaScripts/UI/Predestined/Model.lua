--涉及配置
--gacha 抽卡消耗 根据卡池id
--common 抽卡次数 编号357,443
--high_gacha 抽卡显示道具
local M = class("PredestinedModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	if self.m_params and self.m_params.pool_id == GlobalConfig.GACHA_SP_ID then
		self.m_is_sp = true --此参数作废
		self:getData("high_gacha_sp_index")
	else
		self.m_is_sp = false
		self:getData("high_gacha_index")
	end
end

function M:onEnter()
	self.m_gacha_id_tab = {7,7,7,7,9,9,10}
	self:updateGachaId()
	self:setTimes()
end

function M:getStageReward()
	local cur_stage = UserDataManager:getCurStage()
	local need_stage_tab = {}
	local high_gacha = ConfigManager:getCfgByName("high_gacha")
	for k, v in pairs(high_gacha) do
		need_stage_tab[#need_stage_tab + 1] = k
	end
	table.sort(need_stage_tab)
	local stage_index = 1
	for i = 1, #need_stage_tab do
		if need_stage_tab[i] <= cur_stage then
			stage_index = i
		end
	end
	return high_gacha[need_stage_tab[stage_index]]
end

function M:getShowItem()
	local items = {}
	if self.m_gacha_id then
		local high_gacha = ConfigManager:getCfgByName("high_gacha")
		local reward_cfg = {}
		if high_gacha[1] and high_gacha[1].sort then
			reward_cfg = high_gacha
		else
			reward_cfg = self:getStageReward()
		end
		--local type = self.m_gacha_id == 7 and 1 or 2
		local types = {[7] = 1, [9] = 2, [10] = 3, [GlobalConfig.GACHA_SP_ID] = 6}
		local type = types[self.m_gacha_id]
		for i,v in pairs(reward_cfg) do
			if v.show > 1 and type == v.type then
				items[#items + 1] = {sort = v.show, reward = v.reward[1]}
			end
		end
	end
	table.sort(items,function(d1,d2)
		return d1.sort < d2.sort
	end)
	return items
end

function M:setArmHero(response)
	if response then
		self.m_data.aim_hero = response.aim_hero
	end
	self:updateGachaId()
	self:setTimes()
end

function M:updateData(response)
	if response then
		self.m_data.aim_hero = response.aim_hero
		self.m_data.guarantee_times = response.guarantee_times
		self.m_data.today_times = response.today_times or 0
		self.m_data.diamond_times = response.diamond_times or 0
	end
	self:updateGachaId()
	self:setTimes()
end

function M:updateGachaId()
	--是否是sp抽卡
	if self.m_is_sp then
		self.m_gacha_id = GlobalConfig.GACHA_SP_ID
		return
	end
	if self.m_data.aim_hero and self.m_data.aim_hero > 0 then
		local cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_data.aim_hero)
		if cfg.is_sp == 0 then
			self.m_gacha_id = self.m_gacha_id_tab[cfg.race]
		else
			self.m_gacha_id = GlobalConfig.GACHA_YUAN_ID
		end
	end
end

function M:changeHeroControl(cid)
	local flag = false
	local times = 0
	local name = ""
	if self.m_gacha_id == nil or self.m_gacha_id == GlobalConfig.GACHA_SP_ID then
		return flag, times, name
	end

	local cfg = UserDataManager.hero_data:getHeroConfigByCid(cid)
	if cfg == nil then
		return flag, times, name
	end
	--sp抽卡
	if self.m_gacha_id == GlobalConfig.GACHA_SP_ID then
		flag = true
		local total_times = ConfigManager:getCommonValueById(357, {100,100, 120, 70})[4]
		times = total_times - self.m_data.guarantee_times[self.m_gacha_id]
		name = Language:getTextByKey(cfg.name)
		return flag, times, name
	end
	--原抽卡
	local gacha_id = cfg.is_sp == 0 and self.m_gacha_id_tab[cfg.race] or GlobalConfig.GACHA_YUAN_ID
	if self.m_gacha_id ~= gacha_id then
		flag = true
		local index = 1
		if gacha_id == 7 then
			index = 1
		elseif gacha_id == 9 then
			index = 2
		elseif gacha_id == 10 then
			index = 3
		end
		local total_times = ConfigManager:getCommonValueById(357, {100,100, 120, 70})[index]
		times = total_times - self.m_data.guarantee_times[tostring(gacha_id)]
		name = Language:getTextByKey(cfg.name)
	end
	return flag, times, name
end

function M:setTimes()
	if self.m_gacha_id then
		local index = 1
		if self.m_gacha_id == 7 then
			index = 1
		elseif self.m_gacha_id == 9 then
			index = 2
		elseif self.m_gacha_id == 10 then	
			index = 3
		elseif self.m_gacha_id == GlobalConfig.GACHA_SP_ID then
			index = 4
		end
		local cfg = ConfigManager:getCommonValueById(357, {100,100,120,70})
		local total_times = cfg[index]
		self.m_times = total_times - self.m_data.guarantee_times[tostring(self.m_gacha_id)]
		self.m_times = self.m_times > 0 and self.m_times or 1
	else
		self.m_times = 100
	end
end

function M:isMaxTime()
	local max_times = self:getMaxTimes()
	local cur_times = self.m_data.today_times or 0
	local is_max_time = false
	if max_times == 0 then
	elseif cur_times >= max_times then
		is_max_time = true
	end
	return is_max_time
end

function M:getMaxTimes()
	local id = self.m_is_sp and 830 or 443
	local max_times = ConfigManager:getCommonValueById(id,0)
	return max_times
end

function M:getItemCount(times)
	local item_num = 0
	if self.m_gacha_id then
		local gacha = ConfigManager:getCfgByName("gacha")[self.m_gacha_id]
		local cost = times == 1 and gacha.cost or gacha.ten_cost
		for i,v in ipairs(cost) do
			local itemData = RewardUtil:getProcessRewardData(v)
			if itemData.user_num >= itemData.data_num then
				if itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
					item_num = itemData.user_num
				end
				return true, item_num
			else
				if itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
					item_num = itemData.user_num
					local min_count = gacha.limit or 10
					if itemData.user_num >= min_count and itemData.user_num > 0  then
						return true, item_num
					end
				end
			end
		end
	end

	return false, item_num
end

return M