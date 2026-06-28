local M = class("ShareLvHeroPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self:setData(self.m_params)
end

function M:setData(data)
	self.m_data = data
	self.m_list = {}
	for i=1,self.m_data.max_slot_num do
		self.m_list[i] = 1
	end
end

function M:getSoltDataByIndex(index)
	return self.m_data.crystal_slot[index]
end

function M:setSoltData(data)
	for k,v in pairs(data.slot) do
		self.m_data.crystal_slot[tonumber(k)] = v
	end
end

function M:getClearTimeCost(index)
	local system_cost = ConfigManager:getCfgByName("system_cost")[4].cost
	local data = self:getSoltDataByIndex(index)
	local time = data.etime - UserDataManager:getServerTime()
	if time > 0 then
		return math.ceil(system_cost[1][3]*time/(24*3600))
	end
	return system_cost[3]
end

function M:isHaveSameHero(oid)
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	for i,v in ipairs(self.m_data.level_top) do
		local data2 = UserDataManager.hero_data:getHeroDataById(v[1])
		if data.id == data2.id then
			return true, cfg.name
		end
	end

	for k,v in pairs(self.m_data.crystal_slot) do
		if v.hid ~= "" then
			local data2 = UserDataManager.hero_data:getHeroDataById(v.hid)
			if data.id == data2.id then
				return true, cfg.name
			end
		end
	end
end

return M
