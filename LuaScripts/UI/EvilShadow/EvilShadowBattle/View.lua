local M = class("EvilShadowBattleView",LikeOO.OOPopBase)

M.m_uiName = "EvilShadow/EvilShadowBattle"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "evil_shadow_str_004")
	self:setTextByLanKey("chakan_btn_text", "evil_shadow_str_006")
	self:refreshUI()
	RedPointUtil:saveLocalRedPointFreshTime("EvilShadowBattle")
end

--刷新UI
function M:refreshUI()
	self:setText("damage_ward_1_text", self.m_model:getMaxDamage())
	self:updateLoopScroll()
	if self.m_model:getRankType() == 1 then
		self:setTextByLanKey("paihang_title_text", "evil_shadow_str_007")
	else
		self:setTextByLanKey("paihang_title_text", "evil_shadow_str_008")	
	end
	self:setObjectVisible("switch_btn", false)
	if self.m_model.m_open_status == 2 then
		self:setObjectVisible("Tiaozhan", false)
	end
	self.hero_item = self:findGameObject("hero_item")
	self:update_Gift(self.hero_item, self.m_model.cur_hero);
	self:setHeroInfo()
end

function M:updateMaxDamage()
	self:setText("damage_ward_1_text", self.m_model:getMaxDamage())
end

function M:updateLoopScroll()
	local data = self.m_model:getRankData()
	--只展示前三名
	local data_three = {}
	for i = 1, 3 do
		if data[i] ~= nil then
			table.insert(data_three, data[i])
		end
	end
	self:setObjectVisible("paihang_sub_img", #data_three == 0)
	self:setObjectVisible("paihang_sub_text", #data_three == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data_three,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data_three)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local user = data.user or {}
	local rank = data.rank or 0
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local top_three_flag = rank > 0 and rank < 4
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "index_img", top_three_flag)
	if rank == 1 then
		LuaBehaviourUtil.setImg(luaBehaviour,"index_img", "a_yycs_diyiicon", "active_ui")
	elseif rank == 2 then
		LuaBehaviourUtil.setImg(luaBehaviour,"index_img", "a_yycs_diericon", "active_ui")
	elseif rank == 3 then
		LuaBehaviourUtil.setImg(luaBehaviour,"index_img", "a_yycs_disanicon", "active_ui")
	end
	LuaBehaviourUtil.setText(luaBehaviour, "index_text", rank)
	if user.name == nil or user.name == "" then
		LuaBehaviourUtil.setText(luaBehaviour, "name_text", tostring(user.uid))
	else
		LuaBehaviourUtil.setText(luaBehaviour, "name_text", tostring(user.name))
	end
end

 --左下角
function M:update_Gift(cell_obj, hero_data)
	if hero_data ~= nil then
		local evo_item = self:getMoodShadowEvoData(self.m_model:getCurrentDay());
		if evo_item ~= nil and hero_data.evo >= evo_item.evo then
			local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
			if luaBehaviour then
				local heroNode = luaBehaviour:FindGameObject("HeroNode")
				local farm_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo_item.evo]
				self:setTextByLanKey("hero_skill_txt","new_str_1079", Language:getTextByKey(farm_data.name))
				local hero_data_1 = RewardUtil:getProcessRewardData({101,602,1})
				hero_data_1.quality = evo_item.evo
				CommonUIUtil:updateHeroElementByData(heroNode, hero_data_1)
			end
			self:setObjectVisible("hero_item", true)
			self:setTextByLanKey("hero_des_txt","new_str_1065",evo_item.show_buff)
		else
			self:setObjectVisible("hero_item", false)
		end
	else
		self:setObjectVisible("hero_item", false)
	end
end

function M:getMoodShadowEvoData( day )
	local item = nil
	for i, v in ipairs(self.m_model.cur_verson_mood_shadow) do
		if i >= 1 and day >= i then
			item = v;
		end
	end
	return item;
end

function M:setHeroInfo()
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(602)
	local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({}, hero_cfg)

	local class_str = Language:getTextByKey(hero_cfg.class)
	local name_str = Language:getTextByKey(shin_data_cfg.name)
	self:setTextByLanKey("hero_name", name_str)
	self:setTextByLanKey("hero_name2", class_str)
	local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
	self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
	--local frame_data = GlobalConfig.QUALITY_FRAME[hero_cfg.max_evo]
	self:setImg(GameUtil:get_lineframename(hero_cfg.Ex_hero,hero_cfg.max_evo), "common_ui","hero_evo")

	local spine_name = shin_data_cfg.hero_spine or "hero_0001_SkeletonData"
	local play_img = self:findGameObject("hero_spine")
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
end


return M