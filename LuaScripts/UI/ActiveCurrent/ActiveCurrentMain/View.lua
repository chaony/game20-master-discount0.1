local M = class("ActiveCurrentMainView",LikeOO.OOPopBase)

M.m_uiName = "ActiveCurrent/ActiveCurrentMain"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	local info_data = self.m_model:BasicInfo() --获取配置
	if info_data then
		self:setTextByLanKey("close_title_text", info_data.name) --活动名称
		self:setHeroInfo(info_data.spine) --设置spine
		local bg_img = self:findGameObject("bg_img")
		GameUtil:updateResourcesImg(bg_img,"Texture/ActiveCurrent/"..info_data.background) --设置背景
		local word_img = self:findGameObject("word_img")
		GameUtil:updateResourcesImg(word_img,"Texture/zh_cn/"..info_data.slogan) --设置文字
		self.active_team_data = info_data.event_team
		self.background = info_data.background
	end
	self.m_gray_material = self:findText("material_node").material
	local start_time_table,end_time_table = self.m_model:changeActiveTimeToString(270)
	self:setText("time_text", Language:getTextByKey("active_current_str_0001",start_time_table[2],start_time_table[3],end_time_table[2],end_time_table[3]))
	self:setTextByLanKey("grow_btn_text", "gf_str_0006")
	--成长礼包显示设置
	local event_cfg = self.m_model:BasicInfo()
	local is_grow_open = event_cfg.hero_gift ~= nil and event_cfg.hero_gift > 0
	is_grow_open = self.m_model.m_data.hero_gift_open and self.m_model.m_data.hero_gift_open == 1 --成长礼包开放时间，比鬼忍活动本身要短，所以不一定同步开启
	self:setObjectVisible("grow_btn", is_grow_open)
	self:refreshUI()
end

function M:refreshRedPoint()
	local hero_event_gift = UserDataManager:getRedDotByKey("hero_event_gift")
	self:setObjectVisible("grow_btn_red_point_img", hero_event_gift == 1)
end

function M:refreshUI()
	self:refreshActive()
	self:refreshRedPoint()
end

--设置英雄信息
function M:setHeroInfo(hero_skin_id)
	self.m_model.hero_skin_data = self.m_model:getSkinData(hero_skin_id)  --英雄皮肤信息
	self.m_model.hero_id = self.m_model.hero_skin_data.hero or 602
	self.m_model.hero_skin_id = hero_skin_id
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_model.hero_id)
	local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({}, hero_cfg)
	
	local class_str = Language:getTextByKey(hero_cfg.class)
	local name_str = Language:getTextByKey(shin_data_cfg.name)
	self:setTextByLanKey("hero_name", name_str)
	self:setTextByLanKey("hero_name2", class_str)
	local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
	self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
	--local frame_data = GlobalConfig.QUALITY_FRAME[hero_cfg.max_evo]
	self:setImg(GameUtil:get_lineframename(hero_cfg.Ex_hero,hero_cfg.max_evo), "common_ui","hero_evo")
	
	local spine_name = self.m_model.hero_skin_data.hero_spine or "hero_0001_SkeletonData"
	local play_img = self:findGameObject("hero_spine")
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
end

--刷新活动
function M:refreshActive()
	self.m_click_cell_object = nil
	self.m_model.show_data = self.m_model:getShowOpenData(self.active_team_data)
	if self.m_rightloop_scroll_view == nil then
		local loopscroll = self:findGameObject("btns_loopscroll")
		local params = {
			show_data = self.m_model.show_data,
			one_line_count = 2,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				local transform = cell_object.transform
				if luaBehaviour then
					local active_img_bg = luaBehaviour:FindGameObject("active_img_bg")
					local bg_img = cell_data.cfg.entrance_img ~= "" and cell_data.cfg.entrance_img or "a_bffl_rukou1"
					GameUtil:updateResourcesImg(active_img_bg, "Texture/ActiveCurrent/" .. bg_img)
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"active_name",cell_data.cfg.name)
					local is_has_red_point = self.m_model:IsHasRedPoint(cell_data.open_id)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"red_point",is_has_red_point)
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("open_active", {index = index,cell_data = cell_data})
			end
		}
		self.m_rightloop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_rightloop_scroll_view:reloadData(self.m_model.show_data, true)
	end
end

return M