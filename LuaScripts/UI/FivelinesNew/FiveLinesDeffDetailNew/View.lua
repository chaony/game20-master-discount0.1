local M = class("FiveLinesDeffDetailNewView",LikeOO.OOPopBase)

M.m_uiName = "FiveLinesNew/FiveLinesDeffDetailNew"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
	audio:SendEvtUI("Play_UI_Enemy")
	self:setTextByLanKey("title_text","four_tower_str_0017")
	self:setTextByLanKey("common_title_text","fiveline_new_sxsw")
	self:setTextByLanKey("enemy_text","fiveline_new_enemy_text")
	self:setTextByLanKey("reward_text","fiveline_new_sxsw")
end

function M:refreshUI()

	--left hero info
	self:updateHeroInfo()

	--middle content 
	local cell_type = self.m_model:getType()
	local tip_lan = "tid#FourTowerDes_0"..cell_type;
	self:setTextByLanKey("description_text", tip_lan)
	
	local word_key = "new_str_0386"
	if self.m_model.m_params.m_battle == 1 then
		word_key = "new_str_0811"
	end
	self:setTextByLanKey("ok_btn_text", word_key)

	self:updateHeroLoopScroll()
	self:updateRewardLoopScroll()
	
	--right legacy
	self:updateLegacyInfo()
end

function M:updateHeroInfo()
	local cell_object = self:findGameObject("guardinfo")
	local cell_data = self.m_model:getHeroData()
	
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	
	--显示类型   1四象守卫 2精英守卫 3四象首领 
	local type = cell_data.type
	if type == 1 or  type == 2 or type == 3 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"power_img_di",type ~= 3)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"boss_power_img_di",type == 3)

		--展示英雄
		local hero_bg = luaBehaviour:FindGameObject("hero")
		local hero_data = self.m_model:getHeroInfo(tonumber(cell_data.show_pic))
		local hero_spine_name = hero_data.hero_spine
		GameUtil:updateSpineLoadSet(hero_bg,"RoleSpine/" .. hero_spine_name,"idle", 0,true)
		local race = GlobalConfig.TYPE_HERO_RACE[hero_data.race].big_race_icon
		LuaBehaviourUtil.setImg(luaBehaviour,"power_img",race,  ResourceUtil:getLanAtlas())
		LuaBehaviourUtil.setImg(luaBehaviour,"boss_power_img",race,  ResourceUtil:getLanAtlas())
		local power_img_di = "a_sxz_sxsw_yuan_jin"
		local guard_bg = "a_sxz_sxsw_chendi_jin"
		local guard_name_di = "a_sxz_sxsl_wenzichendi_jin"
		if hero_data.race == 1 then --金
			power_img_di = "a_sxz_sxsw_yuan_jin"
			guard_bg = "a_sxz_sxsw_chendi_jin"
			guard_name_di = "a_sxz_sxsw_wenzichendi_jin"
			if type == 3 then
				guard_name_di = "a_sxz_sxsl_wenzichendi_jin"
			end
		elseif hero_data.race == 2 then --火
			power_img_di = "a_sxz_sxsw_yuan_huo"
			guard_bg = "a_sxz_sxsw_chendi_huo"
			guard_name_di = "a_sxz_sxsw_wenzichendi_huo"
			if type == 3 then
				guard_name_di = "a_sxz_sxsl_wenzichendi_huo"
			end
		elseif hero_data.race == 3 then --木
			power_img_di = "a_sxz_sxsw_yuan_mu"
			guard_bg = "a_sxz_sxsw_chendi_mu"
			guard_name_di = "a_sxz_sxsw_wenzichendi_mu"
			if type == 3 then
				guard_name_di = "a_sxz_sxsl_wenzichendi_mu"
			end
		elseif hero_data.race == 4 then --水
			power_img_di = "a_sxz_sxsw_yuan_shui"
			guard_bg = "a_sxz_sxsw_chendi_shui"
			guard_name_di = "a_sxz_sxsw_wenzichendi_shui"
			if type == 3 then
				guard_name_di = "a_sxz_sxsl_wenzichendi_shui"
			end
		end
		LuaBehaviourUtil.setImg(luaBehaviour,"power_img_di",power_img_di,  "maze_stage_ui")
		LuaBehaviourUtil.setImg(luaBehaviour,"boss_power_img_di",power_img_di,  "maze_stage_ui")
		LuaBehaviourUtil.setImg(luaBehaviour,"guard_name_di",guard_name_di,  "maze_stage_ui")
		
		local guard_bg_img = luaBehaviour:FindGameObject("guard_bg")
		GameUtil:updateResourcesImg(guard_bg_img,"Texture/"..guard_bg)
	end

	--设置等级
	local enemy_hero_lv = self.m_model:getHeroLv()
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guard_lv_text",Language:getTextByKey("four_tower_str_0001",enemy_hero_lv))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"combat_text",Language:getTextByKey("four_tower_str_0013",GameUtil:formatValueToString(self.m_model.m_params.enemyCombat)))  --战力
	
	--设置名称
	if type == 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guard_name_text","tid#NfourtowerName_1")
	elseif type == 2 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guard_name_text","tid#NfourtowerName_2")
	elseif type == 3 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guard_name_text","tid#NfourtowerName_3")
	end
end

function M:updateHeroLoopScroll()
	local data = self.m_model:getEnemyData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("enemy_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				local item_node = luaBehaviour:FindGameObject("item_node")
				local ui_element = CommonUIUtil:updateHeroElementByData(item_node, cell_data, nil , true)
				CommonUIUtil:updateHeroLvByData(item_node, data.hero_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateRewardLoopScroll()
	local data = self.m_model:getGiftData()
	if self.m_reward_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("reward_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local item_data = RewardUtil:getProcessRewardData(cell_data)
				GameUtil:updateItemElementByData(cell_object, item_data, true, false)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end
		}
		self.m_reward_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_reward_loop_scroll_view:reloadData(data)
	end
	
end

function M:updateLegacyInfo()
	local legacy_node = self:findGameObject("legacy_node")
	local luaBehaviour = UIUtil.findLuaBehaviour(legacy_node)

	local heirloom = self.m_model:getHeirloom()
	LuaBehaviourUtil.setImg(luaBehaviour,"heirloom_icon", heirloom.icon,  "item_icon")
	LuaBehaviourUtil.setImg(luaBehaviour,"property_img", heirloom.type_icon,  "language_zh_cn")
	local lib_quality_item = GlobalConfig.HEIRLOOM_LIBRARY_QUALITY[heirloom.quality] or GlobalConfig.HEIRLOOM_LIBRARY_QUALITY[3]
	LuaBehaviourUtil.setImg(luaBehaviour, "heirloom_di", lib_quality_item.bg, "equip_icon")

	self:setTextByLanKey("legacy_name_text", heirloom.name)
	self:setTextByLanKey("legacy_story_text", heirloom.des)
	
end

return M