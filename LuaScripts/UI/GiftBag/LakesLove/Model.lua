local M = class("LakesLoveModel", LikeOO.OODataBase)

function M:onCreate()
	self:getData("lakes_love_index")
end

function M:onEnter()
	self.m_version = self.m_data.vsn
	self.m_hero_id = self.m_data.hero
	self.m_conds = self.m_data.conds
	self.m_end_ts = self.m_data.end_ts
	self.m_select_hero_id = 0
	self.m_title_name = self.m_params.title_name
	--cond
	local all_cfg = ConfigManager:getCfgByName("lakes_love_cond")
	self.m_cond_cfg = all_cfg[self.m_version]
	local all_base_cfg = ConfigManager:getCfgByName("lakes_love_base")
	local cfg = all_base_cfg[self.m_version]
	self.m_help_content = cfg.desc
end

function M:getHeroes()
	local all_cfg = ConfigManager:getCfgByName("lakes_love_base")
	local cfg = all_cfg[self.m_version]
	if cfg == nil then
		return nil
	end
	return cfg.heroes
end

--根据索引获取条件
function M:getCond(index)
	local conds = self.m_cond_cfg
	local i = 1
	for k, v in pairs(conds) do
		if index == i then
			return k, v
		end
		i = i + 1
	end
end

function M:getHeroSkill()
	local max_lv = ConfigManager:getHeroMaxlv(self.m_select_hero_id)
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_select_hero_id)
	return hero_cfg.skill, max_lv
end

return M