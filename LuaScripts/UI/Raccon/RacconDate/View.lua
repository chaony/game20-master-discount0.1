local M = class("RacconDateView",LikeOO.OOPopBase)

--活跃任务
M.m_uiName = "Raccon/RacconDate"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	--if self.m_model.m_active_data ~= nil then
	--	self:setTextByLanKey("close_title_text", self.m_model.m_active_data.cell_data.cfg.name)
	--	local bg_img = self:findGameObject("bg_img")
	--	GameUtil:updateResourcesImg(bg_img,"Texture/ActiveCurrent/"..self.m_model.m_background) --设置背景
	--end
	local score,hero_name = self.m_model:getRewardInfo()
	self:setTextByLanKey("close_title_text", self.m_model.m_act_name)
	self:setTextByLanKey("down_text",Language:getTextByKey("active_current_str_0003",score,hero_name))
	self.m_box_node = self:findGameObject("box_node")
	self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
	self.m_week_box_reward_slider = self:findSlider("week_box_reward_slider")
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	self:setText("zhuanji_detail_name", self.m_model:getZhuanjiDetailName())
	self:setText("zhuanji_detail_title", self.m_model:getZhuanjiDetailTitle())
	self:setText("zhuanji_detail_content", Language:getTextByKey(self.m_model:getZhuanjiDetailContent()))
	self:setHeroInfo()
	self:updateZhuanjiLoopScroll()
	self:updateZhuanjiDetailLoopScroll()
	self:updateRewardBox()
end

--右上，传记详情
function M:updateZhuanjiDetailLoopScroll()
	local data = self.m_model:getZhuanjiDetailData()
	if self.m_loop_scroll_zhuanji_detail == nil then
		local loopscroll = self:findGameObject("zhuanji_detail_loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateZhuanjiDetailLoopScrollCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "goto_btn" then
					local status = cell_data.status
					if status ~= -1 then
						self:updateMsg(status == 1 and "detail_reward_btn" or "detail_goto_btn", cell_data)
					end
				elseif click_name == "jifen_obj" then
					GameUtil:lookInfoTips(self.m_control, {click_transform = click_object.transform, msg = Language:getTextByKey("tid#EventPointDes_1")})
				end
			end
		}
		self.m_loop_scroll_zhuanji_detail = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_zhuanji_detail:reloadData(data)
	end
end

-- 更新
function M:updateZhuanjiDetailLoopScrollCell(index, cell_object, cell_data)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local node = luaBehaviour:FindGameObject("node")

	-- 名字
	UIUtil.setTextByLanKey(node.transform, "name_text", cell_data.name)
	UIUtil.setTextByLanKey(node.transform, "reward_num_text", tostring(cell_data.score))
	
	--进度
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "new_str_0471", math.min(cell_data.value or 0, cell_data.target_value), cell_data.target_value)
	-- LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "progress_text", "new_str_0471", math.min(cell_data.value, cell_data.target_value), cell_data.target_value)
	-- 前往、领取按钮
	local goto_btn = UIUtil.findButton(node.transform, "goto_btn")
	local goto_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0029")
	local receive_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_btn_text", "new_str_0056")
	local incomplete_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "incomplete_btn_text", "new_str_0058")
	local goto_btn_text_show = false
	local receive_btn_text_show = false
	local incomplete_btn_text_show = false
	if cell_data.status == 0 then--前往
		goto_btn.gameObject:SetActive(not cell_data.lock_flag)
		local go_type = {cell_data.go_type}  or {}
		if _G.next(go_type) then
			UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
			goto_btn.enabled = true
			goto_btn_text_show = true
		else
			UIUtil.setImg(node.transform, "a_ui_currency_btn_small_3", "common_ui", "goto_btn")
			goto_btn.enabled = false
			incomplete_btn_text_show = true
		end

	elseif cell_data.status == 1 then--可领取
		goto_btn.gameObject:SetActive(true)
		goto_btn.enabled = true
		receive_btn_text_show = true
		UIUtil.setImg(node.transform, "a_ui_currency_btn_small_2", "common_ui", "goto_btn")
	else-- 已领取
		goto_btn.gameObject:SetActive(false)
		incomplete_btn_text_show = true
	end

	goto_btn_text.gameObject:SetActive(goto_btn_text_show)
	receive_btn_text.gameObject:SetActive(receive_btn_text_show)
	incomplete_btn_text.gameObject:SetActive(incomplete_btn_text_show)

	local btn_spine = UIUtil.findTrans(node.transform, "btn_spine")
	btn_spine.gameObject:SetActive(not cell_data.lock_flag and cell_data.status == 1)

	-- 奖励
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_1", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_2", false)
	if cell_data.reward[1] ~= nil then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_1", true)
		local reward_node_1 = luaBehaviour:FindRectTransform("reward_node_1")
		GameUtil:createRewards(reward_node_1, {cell_data.reward[1]}, true, true, nil, 0.85)
	end
	if cell_data.reward[2] ~= nil then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_node_2", true)
		local reward_node_2 = luaBehaviour:FindRectTransform("reward_node_2")
		GameUtil:createRewards(reward_node_2, {cell_data.reward[2]}, true, true, nil, 0.85)
	end
	
	LuaBehaviourUtil.setText(luaBehaviour, "reward_num_text",tostring(cell_data.score) )
end

--右下，传记
function M:updateZhuanjiLoopScroll()
	local data = self.m_model:getZhuanjiData()
	if self.m_loop_scroll_zhuanji == nil then
		local loopscroll = self:findGameObject("zhuanji_loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateZhuanjiLoopScrollCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("zhuanji_item", cell_data)
			end
		}
		self.m_loop_scroll_zhuanji = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_zhuanji:reloadData(data)
	end
end

function M:updateZhuanjiLoopScrollCell(index, cell_object, cell_data)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local bg_img = luaBehaviour:FindGameObject("bg_img")
	
	UIUtil.setLocalPosition(transform, nil, 0, nil)
	local bg_img_name = "a_xhx_zhiyue_zhuanji01"
	LuaBehaviourUtil.setText(luaBehaviour, "name_text", cell_data.name_day)
	LuaBehaviourUtil.setTextColor(luaBehaviour, "name_text", Color(213/255, 200/255, 174/255))
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "complete_flag_img", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", false)
	if cell_data.status == 1 then	--已领取
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "complete_flag_img", true)
	elseif cell_data.status == 2 then	--当前关
		bg_img_name = "a_tbh_zhiyue_xuanzhongzhuanji"
		LuaBehaviourUtil.setTextColor(luaBehaviour, "name_text", Color(247/255, 243/255, 230/255))
		UIUtil.setLocalPosition(transform, nil, 20, nil)
	elseif cell_data.status == 3 then	--待进行
	elseif cell_data.status == 0 then	--未开启
		bg_img_name = "a_xhx_zhiyue_zhuanji02"
		LuaBehaviourUtil.setTextColor(luaBehaviour, "name_text", Color(147/255, 144/255, 135/255))
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", true)
	end
	LuaBehaviourUtil.setImg(luaBehaviour, "bg_img", bg_img_name, "mystic_ui")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point_img", cell_data.red_point == true)
	luaBehaviour:FindImage("bg_img"):SetNativeSize()
end

--左下，宝箱
function M:updateRewardBox()
	local box_trans = self.m_box_node.transform
	UIUtil.destroyAllChild(box_trans)
	local show_data, cur_num = self.m_model:getRewardBoxData()
	local width = self.m_box_node_rt.rect.width
	local max_num = 0
	local box_num = #show_data
	if show_data[box_num] then
		max_num = show_data[box_num].cfg.score
	end
	max_num = max_num > 0 and max_num or 100
	self.m_week_box_reward_slider.value = cur_num/max_num
	for i=1,box_num do
		local data = show_data[i]
		local cfg = data.cfg
		local task_box = GameUtil:createPrefab("EvilShadow/EvilShadowRewardBox", box_trans)
		local transform = task_box.transform
		UIUtil.setLocalScale(transform, 0.7, 0.7, 1.0)
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		UIUtil.setLocalPosition(task_box, width*cfg.score/max_num - width*0.5, 0)
		local function btns(trans,params)
			if data.status == 2 then -- 可领取
				self:updateMsg("box_reward", {click_transform = trans, data = data})
			else
				self:updateMsg("box_click", {click_transform = trans, data = data})
			end
		end
		UIUtil.setButtonClick(transform, btns, i)
		local score_text = UIUtil.setText(transform, tostring(cfg.score), "score_text")
		local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
		score_text.color = data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 255/255, 235/255, 68/255)
		local box_effect = UIUtil.findRectTransform(transform, "UI_Arena_BX_01")
		local box_effect2 = UIUtil.findRectTransform(transform, "UI_Arena_BX_02")
		local box_img = luaBehaviour:FindImage("box_img")
		if data.status == 0 then --未开启
			GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_weijiesuobaoxiang")
		elseif data.status == 2 then --可领取
			GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_kelingqubaoxiang")
		elseif data.status == -1 then --已领取
			GameUtil:updateResourcesImg(box_img, "Texture/moon_shadow/a_yycs_yilingqubaoxiang")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"got_flag_img",true)
		end
		box_img:SetNativeSize()
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", i ~= box_num)
		if box_effect ~= nil then
			box_effect.gameObject:SetActive(false)
		end
		if box_effect2 ~= nil then
			box_effect2.gameObject:SetActive(false)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_01", data.status == 2)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", data.status == 2)
		if data.status == 2 then
			--self.m_control:setOnceTimer(0.1, function()
			--	if not IsNull(task_box) then
			--		luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
			--	end
			--end)
			if box_effect ~= nil then
				box_effect.gameObject:SetActive(true)
			end
			if box_effect2 ~= nil then
				box_effect2.gameObject:SetActive(true)
			end
		end
	end
end

--英雄spine
function M:setHeroInfo()
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_model.m_hero_id)
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