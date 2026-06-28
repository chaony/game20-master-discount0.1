local M = class("QiMenDunJiaBattleDetailView",LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaBattleDetail"
M.m_size_type = 2

function M:onEnter()
	self.m_star_cell_cache = {}
	self:setTextByLanKey("normal_battle_times_left_title", Language:getTextByKey("normal_battle_text")..":")
	self:setTextByLanKey("normal_battle_times_left_title1", Language:getTextByKey("normal_battle_text")..":")
	self:setTextByLanKey("normal_race_title", Language:getTextByKey("normal_race_text")..":")
	self:setTextByLanKey("normal_race_title1", Language:getTextByKey("normal_race_text")..":")
	self:setTextByLanKey("normal_progress_title1", Language:getTextByKey("ts_jf_txt")..":")
	self:setTextByLanKey("normal_progress_title", Language:getTextByKey("ts_jf_txt")..":")
	self:setTextByLanKey("normal_enermy_hp_title", Language:getTextByKey("qi_men_dun_jia_str_042"))
	self:setTextByLanKey("normal_enermy_hp_title1", Language:getTextByKey("qi_men_dun_jia_str_042"))
	self:setTextByLanKey("enemy_text1", "biography_str_006")
	self:setTextByLanKey("enemy_text", "biography_str_006")
	self:setTextByLanKey("reward_text1", "biography_str_007")
	self:setTextByLanKey("reward_text", "qi_men_dun_jia_str_008")
	self:setTextByLanKey("star_battle_times_left_title", Language:getTextByKey("normal_battle_text")..":")

	self:setTextByLanKey("normal_battle_btn_text1", "new_str_0386")
	self:setTextByLanKey("normal_battle_btn_text", "new_str_0386")
	self:setTextByLanKey("star_default_text1", "qi_men_dun_jia_str_046")
	self:setTextByLanKey("star_default_text", "qi_men_dun_jia_str_046")
	self:setTextByLanKey("boss_battle_btn_text", "new_str_0386")
	self:refreshUI()
end

function M:refreshUI()
	self:setObjectVisible("normal_node", false)
	self:setObjectVisible("boss_node", false)
	self:setObjectVisible("star_node", false)
	if self.m_model:isStartConfirmed() == true then --确定挑战后，再选择难度
		self:setObjectVisible("star_node", true)
		self:updateStarNode()
	else
		local cur_node
		if self.m_model.m_mode == 1 then
			cur_node = self:findGameObject("normal_node")
		elseif self.m_model.m_mode == 2 then
			cur_node = self:findGameObject("boss_node")
		end
		if cur_node then
			cur_node:SetActive(true)
		end
		local cur_data = self.m_model:getCurrentData()
		if cur_node and cur_data then
			local curLuaBehaviour = UIUtil.findLuaBehaviour(cur_node)
			local top_info_node = curLuaBehaviour:FindGameObject("top_info_node")
			local hero_info_node = curLuaBehaviour:FindGameObject("hero_info_node")
			local scroll_object_enemy = curLuaBehaviour:FindGameObject("loopscroll_enemy")
			local scroll_object_reward = curLuaBehaviour:FindGameObject("loopscroll_reward")
			local btn_object = curLuaBehaviour:FindGameObject("btns")
			if top_info_node then
				self:updateTopInfo(top_info_node, cur_data.top_info_data)
			end
			if hero_info_node then
				self:updateHeroInfo(hero_info_node, cur_data.hero_info_data)
			end
			if scroll_object_enemy then
				self:updateHeroLoopScroll(scroll_object_enemy, cur_data.enemy_data)
			end
			if scroll_object_reward then
				self:updateRewardLoopScroll(scroll_object_reward, cur_data.reward_data)
			end
			if btn_object then
				self:updateBtns(btn_object, cur_data.btn_data)
			end
		end
	end
	self:updateStarChooseFlag()
end

--顶端的战斗信息
function M:updateTopInfo(top_info_node, top_info_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(top_info_node)
	local massif_cfg = top_info_data.massif_cfg
	local cell_data = top_info_data.cell_data
	
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "normal_common_title_text", massif_cfg.massif_name or "qi_men_dun_jia_str_020")
	LuaBehaviourUtil.setText(luaBehaviour, "normal_battle_times_left_text", massif_cfg.massif_hp - cell_data.cur_num)
	local race_limit = massif_cfg.race or {}
	if #race_limit >= 6 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "normal_race_title", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "normal_race_text", false)
	else
		for k, v in pairs(race_limit) do
			local race = GlobalConfig.TYPE_HERO_RACE[v].big_race_icon
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "normal_race_img_" .. k, true)
			LuaBehaviourUtil.setImg(luaBehaviour, "normal_race_img_" .. k, race, ResourceUtil:getLanAtlas())
		end
	end
	LuaBehaviourUtil.setText(luaBehaviour,"normal_progress_text", massif_cfg.explore_add)

	local hp_total, hp_cur = self.m_model:getEnermyHp()
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "normal_enermy_hp_title_text", "qi_men_dun_jia_str_042")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "normal_enermy_hp_text", hp_cur .. " / " .. hp_total)
end


function M:updateHeroInfo(hero_info_object, hero_info_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(hero_info_object)
	
	--技能，只有boss时使用
	local skill_data = hero_info_data.boss_skill
	local skill_panel = luaBehaviour:FindGameObject("skill_panel")
	if skill_panel and skill_data then
		local num = skill_panel.transform.childCount
		for i = 1, num do
			local skill_bg = skill_panel.transform:GetChild(i-1)
			skill_bg.gameObject:SetActive(false)
			if i <= #skill_data then
				skill_bg.gameObject:SetActive(true)
				local skill_img = luaBehaviour:FindGameObject(string.format("skill_%d_img", i))
				UIUtil.setImg(skill_img, skill_data[i].icon, "skill_icon")
			end
		end
	end
end

function M:updateHeroLoopScroll(scroll_object_enemy, enemy_data)
	if enemy_data == nil or next(enemy_data) == nil then
		return 
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = scroll_object_enemy
		local params = {
			show_data = enemy_data,
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
		self.m_loop_scroll_view:reloadData(enemy_data)
	end
end

function M:updateRewardLoopScroll(scroll_object_reward, reward_data)
	if reward_data == nil or next(reward_data) == nil then
		return
	end
	
	if self.m_reward_loop_scroll_view == nil then
		local params = {
			show_data = reward_data,
			one_line_count = 1,
			loop_scroll_object = scroll_object_reward,
			update_cell = function(index, cell_object, cell_data)
				local item_data = RewardUtil:getProcessRewardData(cell_data)
				GameUtil:updateItemElementByData(cell_object, item_data, true, true)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end
		}
		self.m_reward_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_reward_loop_scroll_view:reloadData(data)
	end
	
end

function M:updateBtns(btn_object, btn_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(btn_object)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "action_left_text", "qi_men_dun_jia_str_005")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "star_default_text", "qi_men_dun_jia_str_046")
end

--星级难度界面单独处理
function M:updateStarNode()
	local star_node = self:findGameObject("star_node")
	local luaBehaviour = UIUtil.findLuaBehaviour(star_node)

	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "star_common_title_text", "qi_men_dun_jia_str_037")
	
	LuaBehaviourUtil.setText(luaBehaviour, "star_battle_times_left_text", self.m_model:getEnemyLeft())

	local hp_total, hp_cur = self.m_model:getEnermyHp()
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "star_enermy_hp_title_text", "qi_men_dun_jia_str_038")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "star_enermy_hp_text", hp_cur .. " / " .. hp_total)
	LuaBehaviourUtil.setSliderValue(luaBehaviour, "star_enermy_hp_progress_slider", hp_cur / hp_total)
	
	self:updateStarLoopScroll()
end

function M:updateStarLoopScroll()
	local hero_data = self.m_model:getStarData()
	if #hero_data <= 0 then
		return
	end
	if self.m_star_loopscroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll_star")
		local params = {
			show_data = hero_data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)

				local title_key_num = 42 + cell_data.star
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", "qi_men_dun_jia_str_0" .. title_key_num)
				
				for i = 1, 3 do 
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_" .. i, cell_data.star >= i)
				end
				
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "enermy_hp_title_text", "qi_men_dun_jia_str_039")
				LuaBehaviourUtil.setText(luaBehaviour, "enermy_hp_text", cell_data.enermy_hp .. "%")
				
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "damage_title_text", "qi_men_dun_jia_str_040")
				LuaBehaviourUtil.setText(luaBehaviour, "damage_text", cell_data.damage)

				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "explore_title_text", "qi_men_dun_jia_str_041")
				LuaBehaviourUtil.setText(luaBehaviour, "explore_text", cell_data.explore)
			
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigou_img", cell_data.lock_flag_custom == true)
				if self.m_star_cell_cache[tostring(cell_object)] == nil then
					self.m_star_cell_cache[tostring(cell_object)] = cell_object
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				for k, v in pairs(self.m_star_cell_cache) do
					UIUtil.setObjectVisible(v.transform, false, "duigou_img")
				end
				for k, v in pairs(hero_data) do
					v.lock_flag_custom = false
				end
				
				UIUtil.setObjectVisible(cell_object.transform,true, "duigou_img")
				cell_data.lock_flag_custom = true
				
				self.m_model:setChooseStar(cell_data.star)
			end
		}
		self.m_star_loopscroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_star_loopscroll_view:reloadData(hero_data)
	end
end

function M:updateStarChooseFlag()
	local star_flag = self.m_model:getStarChooseFlag()
	local cur_node
	if self.m_model.m_mode == 1 then
		cur_node = self:findGameObject("normal_node")
	elseif self.m_model.m_mode == 2 then
		cur_node = self:findGameObject("boss_node")
	end
	if cur_node then
		local curLuaBehaviour = UIUtil.findLuaBehaviour(cur_node)
		LuaBehaviourUtil.setObjectVisible(curLuaBehaviour, "star_default_img", star_flag)
	end
end


return M