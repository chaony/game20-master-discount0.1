local M = class("EquipmentRecoinPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.hero_id = self.m_params.hero_oid
	self.m_pos =  self.m_params.pos
	self.m_random_index = 0
	self.m_roundNum = 0 --转动轮数
	self.m_race_tab = self:getRaces()
end

function M:getEqpData()
	local h_data, h_cfg =  UserDataManager.hero_data:getHeroDataById(self.hero_id)
	local equips = h_data.equips
	self.m_equip_data = equips[tostring(self.m_pos)]
	local cfg =	UserDataManager.equip_data:getEquipConfigByCid(self.m_equip_data.id) 
	return self.m_equip_data, cfg
end

function M:getRaces()
	local race_tab = {}
	local data, cfg = self:getEqpData()
	for i = 1, 6 do
		if i ~= data.race then
			table.insert(race_tab, i)
		end
	end
	return race_tab
end

function M:turnNum()
	if self.m_random_index >= 5 then
		self.m_random_index = 1
		self.m_roundNum = self.m_roundNum + 1
	else
		self.m_random_index = self.m_random_index + 1
	end
end

function M:canStop()
	if self.m_roundNum >= 3 and  self.m_race_tab[self.m_random_index] == self.m_resultRace then
		self.m_roundNum = 0
		return true
	else
		return false	
	end
end

function M:activateRace()
	local h_data, h_cfg =  UserDataManager.hero_data:getHeroDataById(self.hero_id)
	local e_data, e_cfg = self:getEqpData()
	if h_cfg and e_data and h_cfg.race == e_data.race then
		return true
	end
	return false
end

function M:getCons()
	local cons_cfg = ConfigManager:getCommonValueById(82)
	local consItem = RewardUtil:getProcessRewardData(cons_cfg[1])
	return consItem
end

function M:checkRecoin()
	local h_data, h_cfg =  UserDataManager.hero_data:getHeroDataById(self.hero_id)
	local e_data, e_cfg = self:getEqpData()
	self.m_resultRace = e_data.race -- 新的种族
end


--- 网络数据回调，需要复写
function M:netData(data, tag)
	if tag == "eqp_recast" then
		self:checkRecoin()
	elseif tag == "cancel_recast_recast" then
		self:checkRecoin()
	end
end


return M
