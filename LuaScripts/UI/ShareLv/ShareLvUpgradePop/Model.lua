local M = class("ShareLvUpgradePopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callfunc = self.m_params.callback
	self.m_data = self.m_params.data
end

function M:getCombat()
	local combat = 0
	for k,v in ipairs(self.m_data.crystal_slot) do
		if v.hid ~= "" then
			local data, cfg = UserDataManager.hero_data:getHeroDataById(v.hid)
			combat = combat + data.combat
		end
	end
	return combat
end

function M:computeCombat()
	local combat = 0
	for k,v in ipairs(self.m_data.crystal_slot) do
		if v.hid ~= "" then
			local data, cfg = UserDataManager.hero_data:getHeroDataById(v.hid)
			local hero_data = table.copy(data)
			hero_data.clv = hero_data.clv + 1
			local attrs = UserDataManager:computeHeroAttrsClient(hero_data)
			hero_data.attrs = attrs
			local value = UserDataManager:computeHeroCombat(hero_data, cfg)
			combat = combat + value
		end
	end
	return combat
end

return M
