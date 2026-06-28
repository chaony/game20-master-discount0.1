local M = class("CombatRepressInfoModel", LikeOO.OODataBase)
function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_hero_id = self.m_params.hero_oid or 0
	self.m_hero_spine = self.m_params.spine_name or "hero_0003_SkeletonData"
	self.m_select_id = 1
	self.m_tab_btn_node = {
		{btn_key = "tog_1",  text_name = "tog_1_text",text_key = "", red_point_img = "tog_1_red_point_img" },
		{btn_key = "tog_2",  text_name = "tog_2_text",text_key = "",red_point_img = "tog_2_red_point_img" },
		{btn_key = "tog_3",  text_name = "tog_3_text",text_key = "", red_point_img = "tog_3_red_point_img" },
		--{btn_key = "tog_4",  text_name = "tog_4_text",text_key = "",red_point_img = "tog_4_red_point_img"},
		--{btn_key = "tog_5",  text_name = "tog_5_text",text_key = "",red_point_img = "tog_5_red_point_img"},
	}
	self.combat_repress_level_data = ConfigManager:getCfgByName("combat_repress_level")
	self.combat_repress_data = ConfigManager:getCfgByName("combat_repress")
	self.combat_repress_max_nums_list = GameUtil:countMaxCfg()
	self.cfg_max_nums = 0
	for k,v in ipairs(self.combat_repress_max_nums_list) do
		self.cfg_max_nums = self.cfg_max_nums + v
	end		
	self.m_hero_table = {}
	self.m_global_table = {}
	self.m_hero_nums = 0
	self.m_global_nums = 0
	self.m_hero_table,self.m_hero_nums = GameUtil:countCombatRepressGrade(self.m_hero_id)
	self.m_global_table,self.m_global_nums = GameUtil:countGlobalCombatRepressGrade()
	self.m_locate_type_data = {}
	self:getTypeName()
end

function M:getTypeName()
	for k,v in ipairs(self.m_tab_btn_node) do
		self.m_locate_type_data[k] = {}
		for k1,v1 in pairs(self.combat_repress_data) do
			if v1.locate_type == k then
				self.m_tab_btn_node[k].text_key = v1.locate1_type_des
				table.insert(self.m_locate_type_data[k],v1)
			end
		end
	end
end

function M:getLocateType()
	local types = self.m_locate_type_data[self.m_select_id] or {}
	table.sort(types,function(data1,data2)
		return data1.id < data2.id
	end)
	return types
end

function M:getStarsData()
	local types = {{},{},{}}
	return types
end

return M

