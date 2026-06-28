local M = class("HeroNewPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_is_new = self.m_params.is_new or false
	self.m_callback = self.m_params.callback
	self.m_hero_id = self.m_params.hero_id
	self.m_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_hero_id)
end

function M:getHero_SPInfo()
	local is_sp=self.m_hero_cfg.is_sp~=0 and self.m_hero_cfg.is_sp
	local sp_bg_name="sp_yaodao_bg"
	local sp_mul_lan_name=""
	local sp_efffect_name=""
	if is_sp then
		local settingData=GlobalConfig.SP_TYPE_SETTING[self.m_hero_cfg.is_sp]
		sp_bg_name=settingData.sp_bg_name
		sp_mul_lan_name=Language:getTextByKey(settingData.name)
		sp_efffect_name=settingData.sp_bg_effect_name
	end
	return is_sp,sp_bg_name,sp_mul_lan_name,sp_efffect_name
end

function M:getEvo()
	if self.m_params.evo then
		return self.m_params.evo
	else
		return self.m_hero_cfg.evo
	end
end

function M:subName()
	local cur_skin = 0
	if self.m_hero_cfg then
		local skin = self.m_hero_cfg.skin or {}
		cur_skin = skin[1]
	end
	local skinCfg = self:getHeroSkinCfg(cur_skin)
	local name_path = skinCfg.bank
	return name_path
end

function M:getHeroTypeDes()
	return self.m_hero_cfg.type_des02
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

-- 获取角色皮肤配置
function M:getNewHeroSkinCfg()
	local cur_skin = 0
	if self.m_hero_cfg then
		local skin = self.m_hero_cfg.skin or {}
		cur_skin = skin[1]
	end
	local hero_skin_cfg = ConfigManager:getCfgByName("hero_skin")
	local hero_skin_cfg_item = hero_skin_cfg[checknumber(cur_skin)]
	return hero_skin_cfg_item
end

return M
