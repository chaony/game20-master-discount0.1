local M = class("JewelGachaResultPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open = {}
	self.m_is_open_all = false
	self.m_cards = self.m_params.reward
	self.m_open_new_card = {}
	for i = 1, #self.m_cards do
		local reward = self.m_cards[i]
		if self:isNewJewel(reward) or UserDataManager.jewel_data:checkActiveUI(reward.jewel) == true then --新宝物
			table.insert(self.m_open_new_card, reward.jewel)
		end
	end
	local base_tab = ConfigManager:getCfgByName("jewel_gacha_base")
	self.m_cost = #self.m_cards == 10 and base_tab.ten_cost[1] or base_tab.one_cost[1] --消耗
end

function M:isNewJewel(reward)
	if reward.jewel == nil or reward.item ~= nil then
		return false
	end
	return true
end

function M:isJewelChip(reward)
	if reward.jewel and reward.jewel > 0 and reward.item ~= nil then
		return true
	end
	return false
end

function M:getItem(reward)
	local item = reward.item
	if item == nil then
		return nil
	end
	for k, v in pairs(item) do
		return tonumber(k), v
	end
end

function M:getCloseCard(index)
	index = index or 1
	for i = index, #self.m_cards do
		if not self.m_open[i] then
			--local reward = self.m_cards[i]
			--if self:isNewJewel(reward) then --新宝物
			--	return i, false
			--else
				return i, true
			--end
		end
	end
end

function M:openCard(index)
	self.m_open[index] = true
end

function M:cardIsOpen(index)
	return self.m_open[index]
end

function M:getOpenNewCard()
	local card_id = self.m_open_new_card[1]
	table.remove(self.m_open_new_card, 1)
	return card_id
end

return M