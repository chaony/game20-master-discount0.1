local M = class("StarDetailsModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_star_data = self.m_params.star_data
	self.m_fates = self.m_params.fates or {}
end


--获取显示英雄数据
function M:getHeroData()
	local data_table = {}
	local hero_data = ConfigManager:getCfgByName("hero_detail")
	for i, v in ipairs(self.m_star_data.cfg.hero_group) do
		local hero_info =  hero_data[v] or {}
		table.insert(data_table,hero_info)
	end
	return data_table
end

--英雄是否被激活
function M:getIsActivation(hero_id)
	local data_list = self.m_fates.heros or {}
	for i, v in pairs(data_list) do
		if tonumber(i) == hero_id then
			return true
		end
	end
	return false
end

--获取加成数据
function M:setAdditionData()
	local add_base = 0
	if self.m_star_data ~= nil and self.m_star_data.cfg ~= nil and self.m_star_data.cfg.add_base ~= nil then
		add_base = self.m_star_data.cfg.add_base
	end
	local light_hero_num = 0
	for i, v in pairs(self.m_fates.heros) do
		light_hero_num =  light_hero_num + 1
	end
	local hp_value = add_base[light_hero_num] or 0
	local atk_value = add_base[light_hero_num] or 0
	local def_value = add_base[light_hero_num] or 0
	return hp_value,atk_value,def_value
end

return M
