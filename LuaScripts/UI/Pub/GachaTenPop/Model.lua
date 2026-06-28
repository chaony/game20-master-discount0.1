---@class GachaTenPopModel:OODataBase
local M = class("GachaTenPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open = {}
	self.m_is_open_all = false
	self.m_cards = self.m_params.cards
	self.m_card_count = #self.m_cards
	self.m_pool_id = self.m_params.pool_id
	self.m_type_index = self.m_params.type_index
	self.m_new_card = table.copy(self.m_params.new_card) or {}
	self.m_open_new_card = {}
	self.m_new_card_indexes = {}
end

function M:openCard(index)
	self.m_open[index] = true
	self:isNewCard(index)
end

function M:openAllCard()
	for i=1, self.m_card_count do
		if self.m_open[i] ~= true then
			self:isNewCard(i)
		end
		self.m_open[i] = true
	end
end

function M:cardIsOpen(index)
	return self.m_open[index]
end

function M:getCloseCard(index)
	index = index or 1
	local card_hero_cfg = ConfigManager:getCfgByName("card_hero")
	for i=index, self.m_card_count do
		if not self.m_open[i] then
			local card = self.m_cards[i]
			local card_id = card[2]
			local cfg = card_hero_cfg[card_id]
			if cfg.hero_evo < 5 then
				return i, true
			else
				return i, false
			end
		end 
	end
end

function M:isNewCard(index)
	local card = self.m_cards[index]
	for i,v in ipairs(self.m_new_card) do
		if v == card[2] then
			self:addOpenNewCard(v)
			table.remove(self.m_new_card, i)
			self.m_new_card_indexes[index] = index
			return
		end
	end
end

-- 尾部插入
function M:addOpenNewCard(card_id)
	table.insert(self.m_open_new_card, card_id)
end

-- 头部删除
function M:getOpenNewCard()
	local card_id = self.m_open_new_card[1]
	table.remove(self.m_open_new_card, 1)
	return card_id
end

function M:checkIsNewCard(index)
	for i,v in pairs(self.m_new_card_indexes) do
		if v == index then
			return true
		end
	end
	return false
end

return M
