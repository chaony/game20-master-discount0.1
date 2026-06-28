local M = class("FiveLinesRestraintPopNewModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_cur_element = self.m_params or 1
end

function M:getKeZhi()
	local tab_element_all = ConfigManager:getCfgByName("five_element_allelopathy")
	for k,v in pairs(tab_element_all) do
		if v.my_type == self.m_cur_element then
			return v
		end
	end
	return nil
end

function M:getBeiKe()
	local tab_element_all = ConfigManager:getCfgByName("five_element_allelopathy")
	for k,v in pairs(tab_element_all) do
		if v.enemy_type == self.m_cur_element then
			return v
		end
	end
	return nil
end

function M:getAttr(data)
	local id = data[2][2]
	local enumeration = ConfigManager:getCfgByName("hero_enumeration")
	local cfg = enumeration[id]
	return cfg
end

return M
