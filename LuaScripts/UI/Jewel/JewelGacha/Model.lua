local M = class("JewelGachaModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("jewel_index")
end

function M:onEnter()
	self.m_total_num = self.m_data.gacha_total_num
	self.m_week_num = self.m_data.gacha_week_num
	local wishes = self.m_data.gacha_wishes
	--self.m_total_num = self.m_params.gacha.total
	--self.m_week_num = self.m_params.gacha.week
	--local wishes = self.m_params.gacha.wishes
	self.m_show_reward = {} --寻宝所得碎片和其他道具
	--self.m_reward = {} --抽卡奖励
	--
	self.m_wishes = {}
	local wish_tab = ConfigManager:getCfgByName("jewel_gacha_wish")
	for k,v in pairs(wish_tab) do
		local index = #self.m_wishes + 1
		self.m_wishes[index] = {times = k, jewel = 0, award = 0}
		local wish = wishes and wishes[tostring(k)] or nil
		if wish then
			self.m_wishes[index].jewel = wish.jewel
			self.m_wishes[index].award = wish.award
		end
	end
	local function sortFunc(a, b)
		return a.times < b.times
	end
	table.sort(self.m_wishes, sortFunc)
	--消耗
	local base_tab = ConfigManager:getCfgByName("jewel_gacha_base")
	self.m_one_cost = base_tab.one_cost[1]
	self.m_ten_cost = base_tab.ten_cost[1]
end

function M:isCanGetWish(times)
	if self.m_week_num < times then
		return false
	end
	for i, v in pairs(self.m_wishes) do
		if v.times == times and v.jewel > 0 and v.award == 0 then
			return true
		end
	end
	return false
end

function M:updateWish(times, jewel_id, state)
	for i, v in pairs(self.m_wishes) do
		if v.times == times then
			if jewel_id then
				v.jewel = jewel_id
			end
			if state then
				v.award = state
			end
		end
	end
end

function M:mergeReward(reward)
	--self.m_show_reward = {}
	for i = 1, #reward do
		for k, v in pairs(reward[i].item or {}) do
			self.m_show_reward[#self.m_show_reward + 1] = {103, tonumber(k), v}
		end
	end
end

function M:getWishValue()
	local length = #self.m_wishes
	local max = self.m_wishes[length].times
	local times = self.m_week_num
	local value_text = times .. "/" .. max
	if times <= 0 then
		return 0, value_text
	end
	if times >= max then
		return 1, value_text
	end
	local last_times = 0
	local index = 0
	for i, v in pairs(self.m_wishes) do
		if times > v.times then
			index = i
			last_times = v.times
		end
	end
	local wish_times = self.m_wishes[index + 1].times
	local value = (1 / length) * (times - last_times) / (wish_times - last_times)
	value = value + (1 / length) * index
	return value, value_text
end

function M:updateGacha(response)
	self.m_total_num = response.gacha_total_num
	self.m_week_num = response.gacha_week_num
	self:mergeReward(response.reward) --实际奖励
	--self.m_reward = response.reward --原始奖励
	--self:checkNewJewel(response.reward) --新宝物
	for i = 1, #response.reward do
		local reward = response.reward[i]
		if self:isNewJewel(reward) then --新宝物
			UserDataManager.jewel_data:updateActive(reward.jewel)
		end
	end
	UserDataManager.jewel_data:updateEffects(response.effects) --秘宝效果
end

--检查新获得宝物
--[[function M:checkNewJewel(rewards)
	self.m_open_new_card = {}
	for i = 1, #rewards do
		local reward = rewards[i]
		if self:isNewJewel(reward) then --新宝物
			table.insert(self.m_open_new_card, reward.jewel)
		else
			local cfg = UserDataManager.jewel_data:getDetailCfg(reward.jewel)
			if cfg.quality >= 6 then --抽到天级及以上品质宝物时，无论是否拥有该宝物，都展示一次该宝物的获得界面效果
				table.insert(self.m_open_new_card, reward.jewel)
			end
		end
	end
end]]--

function M:isNewJewel(reward)
	if reward.jewel == nil or reward.item ~= nil then
		return false
	end
	return true
end

--获得新宝物
--[[function M:getOpenNewCard()
	local card_id = self.m_open_new_card[1]
	table.remove(self.m_open_new_card, 1)
	return card_id
end]]--

return M