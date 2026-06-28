local M = class("BattleBossTipsModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_hero_id = self.m_params.hero_id
	self.m_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_hero_id)
	self.m_shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = self.m_hero_cfg.skin[1]}, self.m_hero_cfg)
end

function M:getEvo()
	if self.m_params.evo then
		return self.m_params.evo
	else
		return self.m_hero_cfg.evo
	end
end

function M:subName()
	local name_path = self.m_hero_cfg.bank
	return name_path
end

function M:getHeroTypeDes()
	return self.m_hero_cfg.type_des02
end

--获取技能信息
function M:getHeroSkill()
	local max_lv = ConfigManager:getHeroMaxlv(self.m_hero_id)
	return self.m_hero_cfg.skill, max_lv
end

function M:getSpinePos(cfg)
	if cfg == nil then
		return Vector3(0,0,0)
	end
	local id = cfg.id
	local hero_tab = ConfigManager:getCfgByName("hero_detail")
	local data_pos = hero_tab[id]["spine_position"]
	local data_scale = hero_tab[id]["hero_scale"] or 1
	return data_pos, data_scale
end

-- 获取角色皮肤配置
function M:getHeroSkinCfg(id)
	local hero_skin_cfg = ConfigManager:getCfgByName("hero_skin")
	local hero_skin_cfg_item = hero_skin_cfg[checknumber(id)]
	return hero_skin_cfg_item
end

return M
