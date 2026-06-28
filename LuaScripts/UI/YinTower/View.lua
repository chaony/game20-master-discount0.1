local M = class("YinTowerView",LikeOO.OOPopBase)

M.m_uiName = "YinTower/YinTower"
M.m_iphoneXAdapter = true
M.m_size_type = 1

function M:onEnter()
	local title_str = "yinTower_text_0006" --getDesByVsn
	if self.m_model:getDesByKey("title") then
		title_str = self.m_model:getDesByKey("title")
	end
	local main_bg = self.m_model:getDesByKey("main_bg") or "a_jyzt_bg"
	local main_bg_img = self:findImage("main_bg_img")
	GameUtil:updateResourcesImg( main_bg_img, "Texture/yintower/" .. main_bg)
	local main_arts_name = self.m_model:getDesByKey("main_arts_name") or "a_jyzt_meishuzi"
	local main_des_img = self:findImage("main_des_img")
	GameUtil:updateResourcesImg( main_des_img, "Texture/zh_cn/" .. main_arts_name)
	local top_img_di = self.m_model:getDesByKey("tag_img") or "a_sxz_biaotichendi"
	self:setImg(top_img_di, "maze_stage_ui", "top_img_di" )
	self:setTextByLanKey("close_title_text", title_str)
	self:setTextByLanKey("next_text","four_tower_str_0007")
	self:setTextByLanKey("relic_formation_btn_text","four_tower_str_0014")
	self:setTextByLanKey("rank_btn_text","yinTower_text_0007")
	self:setTextByLanKey("gift_btn_text","yinTower_text_0008")
	self:setTextByLanKey("quick_pass_btn_text","yinTower_text_0017")
	self:setTextByLanKey("hero_lv_des_text","yinTower_text_0016", self.m_model:getAssistHeroLv())
	self:setObjectVisible("yun_left_img",false)
	self:setObjectVisible("yun_right_img",false)
	self.material_hui = self:findImage("reward_open_img").material
	self.left_transform = self:findGameObject("yun_left_img")
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 13})
	self.relic_formation_btn = self:findGameObject("relic_formation_btn");
	self.m_bag_action = false;
	self.m_heirloom_fly_player = self:findGameObject("heirloom_fly_player")
	self.m_scroll_cache = {}
	self:refreshUI()
end


function M:refreshUI()
	if self.m_model:isMaxFloor() then
		self:setTextByLanKey("top_text",Language:getTextByKey("yinTower_text_0011")) 
	elseif self.m_model:getActStatus() == 2 then
		self:setTextByLanKey("top_text",Language:getTextByKey("yinTower_text_0013"))
	else
		self:setTextByLanKey("top_text",Language:getTextByKey("yinTower_text_0001",self.m_model.current_flood))
	end
	self.isNext_flood = self.m_model:IsNextFlood()
	self:setObjectVisible("next_btn",false)
	self:updateLoopScroll()
	self:retreshScroll()
	self:refreshRedPoint()
	--快速导航
	self:setObjectVisible("guide_btn", true)

	local auto_quick_pass = self.m_model:getAutoQuickPass()
	self:setObjectVisible("quick_pass_btn", auto_quick_pass == 1)
	self:setObjectVisible("quick_help_btn", auto_quick_pass == 1)
end

--刷新里程奖励文字
function M:refreshRewardText()
	local reward_week,reward_id = self.m_model:getDisPlayReward()
	local display_floor = reward_week.cfg.num - self.m_model.m_data.win_times
	if reward_week.cfg.num > self.m_model.m_data.win_times then --可领取奖励层数大于当前层
		self:setTextByLanKey("quest_text",Language:getTextByKey("four_tower_str_0018",display_floor))
	else --可领取奖励层数小于等于当前层
		local reward_week_next,reward_id_next = self.m_model:getNextReward()
		local rewardIsReceive = self.m_model:isReceive(reward_week_next.id)
		display_floor = reward_week_next.cfg.num - self.m_model.m_data.win_times
		local reward_text = Language:getTextByKey("four_tower_str_0018",display_floor)
		local rewardIsReceive_text = rewardIsReceive and "four_tower_str_0006" or reward_text
		self:setTextByLanKey("quest_text",rewardIsReceive_text)
	end
	if reward_week.cfg.num >= self.m_model:getMixReward() then
		self:setTextByLanKey("quest_text","four_tower_str_0019")
	end
end

--刷新滑动条位置
function M:retreshScroll()
	if self.m_quset_loop_scroll_view ~= nil then
		self.m_quset_loop_scroll_view:moveToCellIndex(self.light_point_num - 1)
	end
end

--创建列表
function M:updateLoopScroll()
	local data = self.m_model:getTowerStageData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopscroll,
			pos_center = true,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if  click_name == "guardinfo" then --英雄
					self:updateMsg("guardinfo", {index = index, cell_data = cell_data})
				elseif click_name == "box" then --宝箱
					self:updateMsg("box",{index = index, cell_data = cell_data})
				elseif click_name == "reward_open_btn" then --挑战/碾压/领取
					self:updateMsg("reward_open_btn",{index = index, cell_data = cell_data})
				elseif click_name == "heirloom_di" then
					self:updateMsg("heirloom_di",{index = index,cell_data = cell_data})
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, false, nil, nil, true)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	self.m_scroll_cache[index] = cell_object
	
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local transform = cell_object.transform
	local auto_quick_pass = self.m_model:getAutoQuickPass()

	--初始化
	local reward_open_btn = luaBehaviour:FindImage("reward_open_btn")
	reward_open_btn.material = nil
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_open_di",false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_open_btn",not(self.m_model:isMaxFloor()) and not(auto_quick_pass == 1) )
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"heirloom_tip_text","four_tower_str_0014") --遗物
	
	--显示类型   1四象守卫 2精英守卫 3四象首领 4前人的遗物 5遗失的包裹 6普通的收获 7巨大的收获
	local type = cell_data.type
	if type == 1 or  type == 2 or type == 3 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"power_img_di",type ~= 3)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"boss_power_img_di",type == 3)
		
		--展示英雄
		local hero_bg = luaBehaviour:FindGameObject("hero")
		local hero_data = self.m_model:getHeroInfo(tonumber(cell_data.show_pic))
		local hero_spine_name = hero_data.hero_spine
		GameUtil:updateSpineLoadSet(hero_bg,"RoleSpine/" .. hero_spine_name,"pose", 0,true)
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
		elseif hero_data.race == 5 then --阳
			power_img_di = "a_sxz_sxsw_yuan_yang"
			guard_bg = "a_sxz_sxsw_chendi_yang"
			guard_name_di = "a_sxz_sxsw_wenzichendi_yang"
			if type == 3 then
				guard_name_di = "a_sxz_sxsw_wenzichendi_yang"
			end
		elseif hero_data.race == 6 then --阴
			power_img_di = "a_sxz_sxsw_yuan_yin"
			guard_bg = "a_sxz_sxsw_chendi_yin"
			guard_name_di = "a_sxz_sxsw_wenzichendi_yin"
			if type == 3 then
				guard_name_di = "a_sxz_sxsw_wenzichendi_yin"
			end
		end
		LuaBehaviourUtil.setImg(luaBehaviour,"power_img_di",power_img_di,  "maze_stage_ui")
		LuaBehaviourUtil.setImg(luaBehaviour,"boss_power_img_di",power_img_di,  "maze_stage_ui")
		LuaBehaviourUtil.setImg(luaBehaviour,"guard_name_di",guard_name_di,  "maze_stage_ui")


		local guard_bg_img = luaBehaviour:FindGameObject("guard_bg")
		GameUtil:updateResourcesImg(guard_bg_img,"Texture/"..guard_bg)


		--设置奖励
		--local reward = {}
		local reward = self.m_model:getEventsGifs(index)
		--if #gifts > 0 then
		--	table.insert(reward,gifts[1])
		--end
		local reward_node = luaBehaviour:FindGameObject("reward_Content")
		GameUtil:createRewards(reward_node.transform, reward, true, true, nil, 1)
		--设置遗物
		local heirloom = self.m_model:getHeirloom(index)

		if heirloom then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"heirloom_di",true)
			LuaBehaviourUtil.setImg(luaBehaviour,"heirloom_icon",heirloom.icon,  "item_icon")
			local lib_quality_item = GlobalConfig.HEIRLOOM_LIBRARY_QUALITY[heirloom.quality] or GlobalConfig.HEIRLOOM_LIBRARY_QUALITY[3]
			LuaBehaviourUtil.setImg(luaBehaviour, "heirloom_di", lib_quality_item.bg, "equip_icon")
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"heirloom_di",false)
		end
		
		--设置等级
		local enemy_hero_lv = self.m_model:getHeroLv(index)
		local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
		local show_lv = GameUtil:getDisplayLvByHeroData({ lv = enemy_hero_lv, clv = enemy_hero_lv })
		--local lv_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", show_lv)
		--lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guard_lv_text",Language:getTextByKey("four_tower_str_0001",show_lv))
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"combat_text",Language:getTextByKey("four_tower_str_0013", GameUtil:formatValueToString(self.m_model:getEnemyCombat(index))))  --战力
		
		--设置挑战文字
		--local battle_state = self.m_model:battleOrRolling(index)
		local battle_state = self.m_model:getQuickPass(index)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"reward_open_cost_num_text",battle_state == 1 and "new_str_0811" or "new_str_0386")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_open_cost",false)
	else
		LuaBehaviourUtil.setImg(luaBehaviour,"reward_img",cell_data.show_pic,  "maze_stage_ui")
		local box_status = self.m_model:getIsStatue(index)
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_open_di",box_status == 1)
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_open_btn",box_status == 0)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"reward_open_cost",self.isNext_flood and box_status == 0)
		local cost_num_text = self.isNext_flood and self.m_model:getDiamond() or "Pub_str_0007"
		if box_status == 1 then
			LuaBehaviourUtil.setImg(luaBehaviour,"reward_img","a_sxz_daoju_chuansongmen",  "maze_stage_ui")
			cost_num_text = "four_tower_str_0021"
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"reward_open_cost_num_text",cost_num_text)
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"guardinfo",type == 1 or  type == 2 or type == 3)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"box",type == 4 or  type == 5 or type == 6 or type == 7)
	local guard_name = self.m_model:getDesByKey("name")
	
	--设置位置type名称
	if type == 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guard_name_text",guard_name and guard_name or "tid#NfourtowerName_1")
	elseif type == 2 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guard_name_text",guard_name and guard_name or "tid#NfourtowerName_2")
	elseif type == 3 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"guard_name_text",guard_name and guard_name or "tid#NfourtowerName_3")
	elseif type == 4 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"box_name_text","tid#NfourtowerName_4")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"describe_text","tid#NfourtowerDes_4")
	elseif type == 5 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"box_name_text","tid#NfourtowerName_5")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"describe_text","tid#NfourtowerDes_5")
	elseif type == 6 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"box_name_text","tid#NfourtowerName_6")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"describe_text","tid#NfourtowerDes_6")
	elseif type == 7 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"box_name_text","tid#NfourtowerName_7")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"describe_text","tid#NfourtowerDes_7")
	end
	if self.m_model:getIsStatue(index) == 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"box_name_text","tid#NfourtowerName_8")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"describe_text","tid#NfourtowerDes_9")
	end
	
end

--设置里程奖励显示（弃用）
function M:setMileageReward()
	local reward_week,reward_id = self.m_model:getDisPlayReward()
	local reward = {}
	table.insert(reward,reward_week.cfg.rewards[#reward_week.cfg.rewards])
	if reward_week.cfg.num > self.m_model.m_data.win_times then --可领取奖励层数大于当前层
		self:setTextByLanKey("need_time_reward_txt",Language:getTextByKey("four_tower_str_0004",reward_week.cfg.num))
	else --可领取奖励层数小于等于当前层
		local rewardIsReceive = self.m_model:isReceive(reward_week.id)
		local rewardIsReceive_text = rewardIsReceive and "four_tower_str_0006" or "new_str_0655"
		self:setTextByLanKey("need_time_reward_txt",rewardIsReceive_text)
	end
end

--设置里程奖励列表
function M:updateQuestLoopScroll()
	local data = self.m_model:getTowerRewardWeek()
	if self.m_quset_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll_quest")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateQuestScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "quest_reward_btn" then
					self:updateMsg("quest_reward",{index = index,cell_data = cell_data})
				end
			end
		}
		self.m_quset_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_quset_loop_scroll_view:reloadData(data, true)
	end
end

function M:updateQuestScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local transform = cell_object.transform
	--设置圆点显示
	local point_img = false
	local point_ok_img = false
	local point_light_img = false
	if cell_data.status == -1  then
		point_img = true
	elseif self.light_point_id == cell_data.id then
		point_light_img = true
	else
		point_ok_img = true
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"point",point_img)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"point_ok",point_ok_img)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"point_light",point_light_img)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"floor_text",not point_light_img)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"floor_light_text",point_light_img)
	--设置层数文本
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"floor_text",Language:getTextByKey("new_str_0568",cell_data.cfg.num))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"floor_light_text",Language:getTextByKey("new_str_0568",cell_data.cfg.num))
	--设置奖励
	local quest_reward_btn_isDisplay = false
	local drop = {}
	table.insert(drop,cell_data.cfg.rewards[#cell_data.cfg.rewards])
	local reward_node = UIUtil.findRectTransform(transform,"reward_node_floor")
	UIUtil.destroyAllChild(reward_node)
	local item, ui_element = GameUtil:createItemElement(drop[1], true, true)
	--GameUtil:createRewards(reward_node.transform, drop, true, false, nil, 0.8)
	ui_element.duigoudi_img:SetActive(cell_data.status == -1)
	item.transform:SetParent(reward_node.transform, false)
	if cell_data.status == 2 then
		GameUtil:creatCommonItemEffect(reward_node, 7, 0.95)
		quest_reward_btn_isDisplay = true
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"quest_reward_btn",quest_reward_btn_isDisplay)
	
	local quest_reward_text = cell_data.status == -1 and "new_str_0058" or "new_str_0655"
	if cell_data.status == 0 then
		quest_reward_text = ""
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"quest_reward_text",quest_reward_text)
end

--刷新时间
function M:updateTime()
	local remain_tim = self.m_model:getEndTs() --剩余时间
	if self.m_model:getActStatus() == 1 then
		local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(remain_tim) --换算剩余时间
		if remain_day > 0  then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0002",remain_day)) --重置剩余天
		elseif remain_day <= 0 and remain_hour > 0 then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0003",remain_hour)) --重置剩余小时
		elseif remain_day <= 0 and remain_hour <= 0 and remain_min > 0 then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0004",remain_min)) --重置剩余分钟
		elseif remain_day <= 0 and remain_hour <= 0 and remain_min <= 0 and remain_sec > 0 then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0005",remain_sec)) --重置剩余秒
		else
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0005",remain_sec)) --重置剩余秒
			self:updateMsg("battle_end_refresh_ui") --重置数据
		end
		if self.remain_day == nil or self.remain_day > remain_day then
			self.remain_day = remain_day
		end
	elseif self.m_model:getActStatus() == 2 and remain_tim <= 0 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		self:updateMsg(99999)
	else
		self:setTextByLanKey("top_text",Language:getTextByKey("yinTower_text_0013"))
		self:setTextByLanKey("reset_time_text", "") --重置剩余秒
	end
	
end

function M:refreshRedPoint()
	local is_red = RedPointUtil:hasRedPointById(24401)
	local is_red2 = RedPointUtil:hasRedPointById(24402)
	self:setObjectVisible("gift_red_point", is_red or is_red2)
end


function M:showEffectTX()
	self:setObjectVisible("UI_Fivelines_ShangGuang_01", true)
	self.m_control:setOnceTimer(1.5, function ()
		self:setObjectVisible("UI_Fivelines_ShangGuang_01", false)
	end)
end

function M:showCloud()
	local fivelinesOpenAnim = ResourceUtil:LoadUIGameObject("FivelinesNew/FivelinesOpenAnim", Vector3.zero, nil)
	fivelinesOpenAnim.transform:SetParent(self.m_rootView.transform, false)
	self.m_control:setOnceTimer(1.5, function() UIUtil.destroyObject(fivelinesOpenAnim) end)
end

function M:tantanBag()
	if self.m_bag_action ~= true then
		self.m_bag_action = true
		local bag_togglebtn = self.relic_formation_btn
		local sequence = Tweening.DOTween.Sequence()
		sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
		sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
		sequence:OnComplete(function ()
			self.m_bag_action = false
		end)
		sequence:SetAutoKill(true)
	end
end

function M:flyHeirloom(index)
	local cell_object = self.m_scroll_cache[index]
	if cell_object then
		local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
		local cell_heirloom_di = luaBehaviour:FindGameObject("heirloom_di")
		local cell_heirloom_loc = cell_heirloom_di.transform.position
		local target_loc = self.relic_formation_btn.transform.position
		local heirloom_data = self.m_model:getHeirloom(index)
		if heirloom_data then
			self:setImg(heirloom_data.icon, "item_icon", "heirloom_fly_player")
			self:setObjectVisible("heirloom_fly_player", true);
			self.m_heirloom_fly_player.transform.position = cell_heirloom_loc
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(self.m_heirloom_fly_player.transform:DOLocalMove(Vector3(target_loc.x, target_loc.y, 0), 1.0))
			sequence:OnComplete(function()
				self:setObjectVisible("heirloom_fly_player", false);
				self:tantanBag()
			end)
			sequence:SetAutoKill(true)
		end
	end
end

function M:maskOn(last_time)
	self:setObjectVisible("Mask_img", true)
	self.m_control:setOnceTimer(last_time, function ()
		self:setObjectVisible("Mask_img", false)
	end)
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	M.super.destroy(self)
end

return M