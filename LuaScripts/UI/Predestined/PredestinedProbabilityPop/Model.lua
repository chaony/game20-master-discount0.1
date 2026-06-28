local M = class("PredestinedProbabilityPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_arm_hero = self.m_params.arm_hero
	self.m_gacha_id = self.m_params.gacha_id
	self.m_is_sp = self.m_params.is_sp --是否是SP
	self.m_relation = {[7] = 1, [9] = 2, [10] = 3, [GlobalConfig.GACHA_SP_ID] = 6}
	self.m_season = UserDataManager:getCurSeason() -- 获取赛季信息
end

function M:getStageReward()
	local cur_stage = UserDataManager:getCurStage();
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

function M:getListData()
	local cardWeight = 0
	local allWeight = 0
	local type = self.m_relation[self.m_gacha_id]
	local high_gacha = ConfigManager:getCfgByName("high_gacha")
	local reward_cfg = {}
	if high_gacha[1] and high_gacha[1].sort then
		reward_cfg = high_gacha
	else
		reward_cfg = self:getStageReward()
	end
	local data = {}
	for i,v in pairs(reward_cfg or {}) do
		if not v.season then v.season = 0 end
		if v.type == type and v.show_swich == 1 and self.m_season >= v.season then
			data[#data + 1] = v
			allWeight = allWeight + v.weight
			cardWeight = (v.sort == 1) and v.weight or cardWeight
		end
	end
	table.sort(data, function(data1, data2)
		return data1.sort < data2.sort
	end)
	-- 总权重排除自选卡
	allWeight = allWeight - cardWeight
	return data, allWeight, cardWeight
end

function M:getItemShowWeight(itemData, allWeight, cardWeight)
	-- 概率算法：
	-- 自选卡 weight / 10000,   	--sort=1为自选卡
	-- 其他物品 weight / allWeight * ((10000 - 自选卡weight) / 10000)
	local curWeight = 0
	local basicsValue = 10000
	local minWeight = 0.01
	if itemData.sort == 1 then
		curWeight = itemData.weight / basicsValue
	else
		curWeight = itemData.weight / allWeight * ((basicsValue - cardWeight) / basicsValue)
	end
	curWeight = curWeight * 100
	curWeight = (curWeight > minWeight) and curWeight or minWeight
	return curWeight
end

return M
