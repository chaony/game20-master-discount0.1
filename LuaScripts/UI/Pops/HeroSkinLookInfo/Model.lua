local M = class("HeroSkinLookInfoModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_skin_id = self.m_params.skin_id --皮肤id
	self.m_is_new = self.m_params.is_new --皮肤id
	self.m_shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = self.m_skin_id}, self.m_hero_cfg)
	self.m_hero_id = self.m_shin_data_cfg.hero
	self.m_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_hero_id)
	self.random_cfg = self:getSkinRandomLineCfg()
end

function M:getEvo()
	if self.m_params.evo then
		return self.m_params.evo
	else
		return self.m_hero_cfg.evo
	end
end

function M:subName()
	local name_path = self.random_cfg.bank
	return name_path
end

function M:se_ID()
	local name_path = self.random_cfg.bank
	return name_path
end

function M:getSkinRandomLineCfg()
	local cfg_tab = ConfigManager:getCfgByName("random_lines")
	for k,v in pairs(cfg_tab) do
		if v.skin == self.m_skin_id then
			return v
		end
	end
end

function M:getHeroTypeDes()
	return self.m_hero_cfg.type_des02
end

--获取技能信息
function M:getHeroSkill()
	local max_lv = ConfigManager:getHeroMaxlv(self.m_hero_id)
	return self.m_hero_cfg.skill, max_lv
end

-- 获取角色皮肤配置
function M:getHeroSkinCfg(id)
	local hero_skin_cfg = ConfigManager:getCfgByName("hero_skin")
	local hero_skin_cfg_item = hero_skin_cfg[checknumber(id)]
	return hero_skin_cfg_item
end

return M
