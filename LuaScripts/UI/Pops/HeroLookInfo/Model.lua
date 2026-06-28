---@class HeroLookInfoModel :OODataBase
local M = class("HeroLookInfoModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_hero_id = self.m_params.hero_id
	self.m_skin_id = self.m_params.skin_id --皮肤id
	self.m_is_open_type = self.m_params.is_open_type or 0 --0 无限制
	self.m_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_hero_id)
	self.m_shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = self.m_skin_id}, self.m_hero_cfg)
	self:updateHeroRoleData()
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


function M:updateHeroRoleData()
	self.m_heroRoleCfg, self.m_heroRoleEvo, self.m_role_level = self:getHeroRoleCfg()
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

function M:getCurFetterLv(lv)
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[self.m_hero_cfg.role_type or 1]
		return fet_tab[lv]
	end
	return nil
end

-- 获取职业等级配置信息
function M:getHeroRoleCfg( level )
	local heroRoleCfg = {}
	local role_level = 0
	local cur_season = UserDataManager:getCurSeason() -- 当前赛季
	local evo, heroId = UserDataManager.hero_data:getHeroHighEvoByCid(self.m_hero_id)
	if heroId and heroId~=0 then
		role_level = UserDataManager.hero_data:getHeroRoleLevelById(heroId) -- 职业等级
		if level then role_level = level end -- 消耗要读下一级
		if role_level and self.m_hero_cfg then
			local role_type = self.m_hero_cfg.role_type or 0
			if role_type ~= 0 then
				local herorole = ConfigManager:getCfgByName("herorole")
				local heroRoleItem = herorole[role_type] or {}
				local seasonHeroRoleCfg = heroRoleItem[role_level] or {}
				if seasonHeroRoleCfg.season and seasonHeroRoleCfg.season <= cur_season then -- 根据赛季取配置
					heroRoleCfg = seasonHeroRoleCfg
				end
			end
		end
	end
	return heroRoleCfg, evo, role_level
end
-- 获取吃卡个数 和 品质
function M:getHeroRoleCostNum()
	local num , quality = 0, 0
	local consume_item = {}
	if self.m_role_level then
		local heroRoleCfg = self:getHeroRoleCfg(self.m_role_level+1)
		if heroRoleCfg and _G.next(heroRoleCfg) then
			local consume_hero = heroRoleCfg.consume_hero
			num = consume_hero[1][2]
			quality = consume_hero[1][3]
			consume_item = heroRoleCfg.consume_item
		end
	end
	return num, quality, consume_item
end

-- 获取吃卡列表
function M:getCanCostHeroList()
	local num, quality, consume_item  = self:getHeroRoleCostNum()
	local hero_list = UserDataManager.hero_data:getHeroListByCidEvo(self.m_hero_id, quality)
	local sel_list = {}
	for i = 1, num do
		if hero_list[i] then
			sel_list[i] = hero_list[i]
		end
	end
	local universal = nil
	if self.m_hero_cfg.islink and self.m_hero_cfg.islink > 0 then
		if self.m_hero_cfg.universal and self.m_hero_cfg.universal > 0 then
			if self.m_hero_cfg.high_gacha_time and self.m_hero_cfg.high_gacha_time ~= "" then
				local high_gacha_time = string.split(self.m_hero_cfg.high_gacha_time,"~")
				local start_time = high_gacha_time[1] or ""
				local end_time = high_gacha_time[2] or ""
				if start_time ~= "" and end_time ~= "" then
					local start_ts = GameUtil:stringToTimesTamp(start_time)
					local end_ts = GameUtil:stringToTimesTamp(end_time)
					local cur_time = UserDataManager:getServerTime()
					if cur_time < start_ts or cur_time > end_ts then
						local num = 0
						if quality == 5 then
							num = 1
						elseif quality == 6 then
							num = 2
						end
						universal = {RewardUtil.REWARD_TYPE_KEYS.ITEM, self.m_hero_cfg.universal, num }
					end
				end
			end
		end
	end
	return sel_list, num, quality, consume_item, universal
end

-- 图鉴升级职业属性加成
function M:getHeroRoleAllAttr()
	local hero_roles = UserDataManager.hero_roles
	local attrs = {}
	local heroRoleCfg = ConfigManager:getCfgByName("herorole")
	for role_type, v in pairs(hero_roles) do
		if tonumber(self.m_hero_cfg.role_type) == tonumber(role_type) then
			local hero_role_item = heroRoleCfg[tonumber(role_type)] or {}
			for lv, oidList in pairs(v) do
				local hero_role_lv_item = hero_role_item[tonumber(lv)]
				if hero_role_lv_item and hero_role_lv_item.role_att and table.nums(oidList) > 0 then
					for i = 1, table.nums(oidList) do -- 同职业同等级有几个人就循环加几遍
						table.insertto(attrs, hero_role_item[tonumber(lv)].role_att)
					end
				end
			end
		end
	end
	local all_attrs = {}
	for k,v in pairs(attrs) do
		all_attrs[v[1]] = (all_attrs[v[1]] or 0) + v[2]
	end
	local temp_attr = {}
	for attrId, v in pairs(all_attrs) do
		temp_attr[#temp_attr+1] = {attrId,v}
	end
	
	return temp_attr
end

--- 获取单个卡牌的职业升级属性
function M:getRoleAtt()
	local heroRoleCfg = self:getHeroRoleCfg(self.m_role_level)
	return heroRoleCfg.role_att
end

return M
