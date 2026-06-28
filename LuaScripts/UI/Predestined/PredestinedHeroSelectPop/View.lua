local M = class("PredestinedHeroSelectPopView",LikeOO.OOPopBase)

M.m_uiName = "Predestined/PredestinedHeroSelectPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {
	{btn = "martial_all_toggle", name = "martial_all_text",},
	{btn = "martial_1_toggle", name = "martial_1_text",},
	{btn = "martial_4_toggle", name = "martial_4_text",},
	{btn = "martial_2_toggle", name = "martial_2_text",},
	{btn = "martial_3_toggle", name = "martial_3_text",},
	{btn = "martial_6_toggle", name = "martial_6_text",},
	{btn = "martial_5_toggle", name = "martial_5_text",},
	{btn = "martial_7_toggle", name = "martial_7_text",},
}
function M:onEnter()
	if self.m_model.m_is_sp then
		self:setObjectVisible("RaceToggle", false) --SP抽卡没有页签可切换
	else
		self:setObjectVisible("RaceToggle", true)
		for i,v in ipairs(__TAB_BTN_NODE) do
			local tog_btn = self:findToggle(v.btn)
			local item = self:findGameObject(v.btn)
			local lan_text = "a_ui_all"
			if i > 1 then
				lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].big_race_icon
			end
			local img= UIUtil.findImage(item.transform,"Background")
			UIUtil.setImg(img, lan_text, ResourceUtil:getLanAtlas())
			UIUtil.setObjectVisible(item.transform, self.m_model.m_index == i,"UI_ShareLv_Xuanze_01")
			UIUtil.addToggleListener(tog_btn, function(is_on, data)
				if is_on then
					self:updateMsg("tab_btn",data)
					local lan_text = data > 1 and GlobalConfig.TYPE_HERO_RACE[i-1].name or "new_str_0065"
					self:setTextByLanKey("race_toggle_btn_text", lan_text)
					UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
				else
					UIUtil.setObjectVisible(item.transform, false,"UI_ShareLv_Xuanze_01")
				end
			end, i, self.m_uiName)
		end
	end
	
	self:setTextByLanKey("common_title_text", "predestined_str_006")
	self:setTextByLanKey("list_tips_text", self.m_model.m_is_sp and "predestined_str_021" or "predestined_str_009")
	self:setTextByLanKey("times_des_text", "predestined_str_007")
	self:setTextByLanKey("times_des_text2", "predestined_str_008")
	self:setTextByLanKey("ok_btn_text", "new_str_0006")

	self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_times > 0 then
		self:setObjectVisible("times_text", true)
		self:setTextByLanKey("times_des_text", "predestined_str_007")
	else
		self:setObjectVisible("times_text", false)
		self:setTextByLanKey("times_des_text", "predestined_str_016")
	end
	self:setText("times_text", self.m_model.m_times)
	self:updateListScroll()
	self:refreshHeroSpine()
end

function M:refreshHeroSpine()
	if self.m_model.m_arm_hero and self.m_model.m_arm_hero > 0 then
		self:setObjectVisible("hero_sp",true)
		local cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_model.m_arm_hero)
		local hero_skin_cfg = UserDataManager.hero_data:getHeroDefaultSkinCfgByHeroCfg(cfg)
		local spine = hero_skin_cfg.hero_spine or "hero_0001_SkeletonData"
		local hero_sp = self:findGameObject("hero_sp")
		GameUtil:updateSpineLoadSet(hero_sp, "RoleSpine/"..spine, "idle", 0, true)
		self:setTextByLanKey("times_name_text", cfg.name)
	else
		self:setObjectVisible("hero_sp",false)
	end
end

function M:updateListScroll()
	local data = self.m_model.m_heros
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				self:updateHeroData(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("select_hero", cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, true)
	end
end

function M:updateHeroData(obj, data)
	GameUtil:updateItemElement(obj,{RewardUtil.REWARD_TYPE_KEYS.HEROS,data,1}, false, false)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"light_img", data == self.m_model.m_arm_hero)
end

return M