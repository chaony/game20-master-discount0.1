local M = class("FirstRechargePopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	local first_recharge = ConfigManager:getCfgByName("first_recharge")
	self.m_gift = first_recharge[1].gift
	for i,v in ipairs(self.m_gift) do
		if v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROS then
			self.m_hero = v[2]
			break
		elseif v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
			local card_hero = ConfigManager:getCfgByName("card_hero")
			self.m_hero = card_hero[v[2]].hero_id
		end
	end
end

function M:getDataByIndex(index)
	return self.m_gift[index]
end

return M
