local M = class("AdmirationModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

--[[

m_hero_cfg数据
{
	["prefab"] = "W_TianC_101/W_TianC",
	["atk_base"] = 2.05,
	["type_des03"] = "tid#HeroDes_717",
	["icon"] = "TX_101",
	["bank"] = "Vo_TCe",
	["age"] = 27,
	["atk_coef"] = 0.82,
	["skin"] = 
	{
		[1] = 10101,
	},
	["characteristic"] = "tid#Herocharacteristic_101",
	["def_base"] = 0.41,
	["id"] = 101,
	["stand_img"] = "tiance_jq",
	["height"] = 177,
	["jump_id"] = 
	{
		[1] = 9,
	},
	["def_coef"] = 0.82,
	["skill"] = 
	{
		[1] = 
		{
			[1] = 
			{
				[1] = 10111,
				[2] = 1,
			},
			[2] = 
			{
				[1] = 10112,
				[2] = 81,
			},
			[3] = 
			{
				[1] = 10113,
				[2] = 161,
			},
		},
		[2] = 
		{
			[1] = 
			{
				[1] = 10121,
				[2] = 11,
			},
			[2] = 
			{
				[1] = 10122,
				[2] = 21,
			},
			[3] = 
			{
				[1] = 10123,
				[2] = 101,
			},
			[4] = 
			{
				[1] = 10124,
				[2] = 181,
			},
		},
		[3] = 
		{
			[1] = 
			{
				[1] = 10131,
				[2] = 41,
			},
			[2] = 
			{
				[1] = 10132,
				[2] = 121,
			},
			[3] = 
			{
				[1] = 10133,
				[2] = 201,
			},
		},
		[4] = 
		{
			[1] = 
			{
				[1] = 10141,
				[2] = 61,
			},
			[2] = 
			{
				[1] = 10142,
				[2] = 141,
			},
			[3] = 
			{
				[1] = 10143,
				[2] = 221,
			},
		},
		[5] = 
		{
			[1] = 
			{
				[1] = 10151,
				[2] = 1,
			},
		},
	},
	["hero_scale"] = 1.0,
	["legend_skill"] = 
	{
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
	},
	["like"] = "tid#Herolike_101",
	["class"] = "tid#Heroclass_101",
	["skill3pos"] = 
	{
		[1] = 0,
		[2] = -82,
	},
	["skill3pic"] = "tiance_jq",
	["hp_base"] = 26.499,
	["nature"] = "tid#Heronature_101",
	["type_des01"] = "type_des01101",
	["show_position"] = 
	{
		[1] = 8,
		[2] = -152,
	},
	["s_battle_icon"] = "icon_zdhero_101",
	["type_des02"] = "type_des02101",
	["critrate_base"] = 0.0,
	["spine_position"] = 
	{
		[1] = -31,
		[2] = -110,
	},
	["title"] = "tid#title_101",
	["evo"] = 5,
	["skill3name"] = "tid#Skill3name_15",
	["name"] = "tid#HeroName_101",
	["race"] = 1,
	["unlock_playericon"] = 1,
	["type"] = 1,
	["face"] = 0,
	["des"] = "tid#HeroDes_101",
	["vo"] = "Vo_PanCi_TCe",
	["role_type"] = 2,
	["legend"] = 
	{
		[1] = "tid#Herolegend1_101",
		[2] = "tid#Herolegend2_101",
		[3] = "tid#Herolegend3_101",
		[4] = "tid#Herolegend4_101",
		[5] = "tid#Herolegend5_101",
	},
	["is_visible"] = 1,
	["equip_heroes_id"] = 101,
	["hp_coef"] = 0.8833,
	["is_new"] = 1,
	["map_event_team"] = 0,
	["poetry"] = "tid#poetry_101",
	["player_icon"] = "a_ui_ptx_101",
	["interest"] = "tid#Herointerest_101",
	["locate"] = 
	{
		[1] = 2,
		[2] = 1,
	},
	["hate"] = "tid#Herohate_101",
	["initial_rage"] = 102400,
	["max_evo"] = 24,
	["class_img"] = "",
	["life"] = "tid#Herolife_101",
	["sex"] = 2,
	["weight"] = 122880,
	["fight_type"] = 1,
	["hero_spine"] = "hero_0101_SkeletonData",
	["image"] = "",
	["m_battle_icon"] = "icon_zdhero_m_101",
	["join_sound"] = "",
}
--]]
function M:onEnter()
    self.m_hero_cfg = self.m_params.hero_cfg
    self.m_hero_id = self.m_hero_cfg.id
    self.m_active_time = self.m_params.active_time
    self.m_hero_bought = self.m_params.hero_bought
    self.m_hero_vsn = self.m_params.hero_vsn
	self.m_is_token = self.m_params.is_token or false
end

--获取技能
function M:getHeroSkill()
    local max_lv = ConfigManager:getHeroMaxlv(self.m_hero_id)
    return self.m_hero_cfg.skill, max_lv
end

--获取spine
function M:getSpinePos(cfg)
    if cfg == nil then
        return Vector3(0, 0, 0)
    end

    local id = cfg.id
    local hero_tab = ConfigManager:getCfgByName("hero_detail")
    local data_pos = hero_tab[id]["spine_position"]
    local data_scale = hero_tab[id]["hero_scale"] or 1
    return data_pos, data_scale
end

--加载价格信息
function M:getMoney()
    --价格信息加载
    if self.m_params.skin_cfg then
		local check_table = ConfigManager:getCfgByName("chest_clothes")
		local check_item = check_table[self.m_params.skin_vsn][1]
		--self.return_per = check_item.return_per;
		return check_item
	else

		local check_table = ConfigManager:getCfgByName("chest_hero")
		local check_item = check_table[self.m_hero_vsn][1]
		--self.return_per = check_item.return_per;
		return check_item
	end
end

--更新服务器数据
function M:updateServerData(data)
	if data and data["end"] then

		UserDataManager.active_121_end = true
		static_rootControl:updateMsg("end_summer", nil, "Summer.SummerMain")
		
		
	end

    if self.m_params.skin_cfg then
		self.m_params.skin_vsn =data.clothes_vsn 
		self.m_params.skin_bought =data.clothes_bought 
    else
        self.m_hero_vsn = data.hero_vsn
        self.m_hero_bought = data.hero_bought
    end
end

return M
