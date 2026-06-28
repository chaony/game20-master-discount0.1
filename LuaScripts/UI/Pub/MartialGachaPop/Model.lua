local M = class("MartialGachaPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_card = nil
	self.m_gacha_id = nil
	self.m_item_id = self.m_params.item_id
end

function M:setGachaIndex(id)
	self.m_gacha_id = id
end

function M:setGachaData(response)
	self.m_card = response.reward.hero_show[1]
	self.m_new_card = response.reward.need_alert
end

return M
