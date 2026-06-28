local M = class("VoyageView",LikeOO.OOPopBase)

M.m_uiName = "Activities/Voyage/Voyage"
M.m_iphoneXAdapter = true

function M:onEnter()
	--self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1, item_id = 1104})
	self:setTextByLanKey("close_title_text", "new_str_0723")
	self:setTextByLanKey("gift_bag_btn_text", "new_str_0732")
	self:setTextByLanKey("shop_btn_text", "union_str_0054")
	self:setTextByLanKey("reward_preview_btn_text", "new_str_0724")
	self:setTextByLanKey("challenge_btn_text", "new_str_0725")
	self:setTextByLanKey("skip_anim_select_text", "new_str_0936")
	self.m_box_reward_slider = self:findSlider("box_reward_slider")
	self.m_box_node = self:findGameObject("box_node")
	self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
	self.m_new_box_reward_slider = self:findSlider("new_box_reward_slider")
	self.m_one_box_node = self:findGameObject("one_box_node")
	self.m_one_box_node:SetActive(false)
	self.m_gray_img = self:findImage("gray_img")
	self.m_reset_time_text = self:findText("reset_time_text")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	
	self:updateSelectTenStatus()
	self:updateSkipAnimStatus()
	--local cur_times, max_times = self.m_model:getBoxRewardsProgress()
	--self:setTextByLanKey("box_reward_slider_text", "new_str_0053",cur_times, max_times)
	--self.m_box_reward_slider.value = cur_times/max_times
	local today_times = self.m_model.m_data.today_times or 0
	today_times = math.min(today_times, self.m_model:getMaxTimes())
	self:setTextByLanKey("max_times_text",  Language:getTextByKey("tid#limit_2") .. today_times .. "/" .. self.m_model:getMaxTimes())
	self:refreshRedPoint()
	self:updateArenaRewardWeek()
	local cd_time = self.m_model.m_data.voyage_etime or 0
	if cd_time > 0 then
		GameUtil:remainingTimeUpdate(self.m_control, "voyage_reset_time_update", self.m_reset_time_text, cd_time, "refresh_ui", 1, "new_str_0948")
	else
		self:setTextByLanKey("reset_time_text", "new_str_0558")
	end
end

function M:refreshRedPoint()
	self:setObjectVisible("shop_red_point", RedPointUtil:hasRedPointById(11301))
end

--[[
	奖励显示
]]
function M:updateLoopScroll()
	self.m_click_cell_object = nil
	local data = self.m_model:getGachaShipRewards(1)
	self:setObjectVisible("CommonTipsNode", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("reward_preview_loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopscroll,
			one_line_count = 2, -- 行或列的数量
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local status = cell_data.status
				if status ~= -1 then
					self:updateMsg(status == 2 and "main_reward" or "goto_btn", cell_data)
					self.m_click_cell_object = cell_object
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
	if cell_data.hero == 1 then
		--大奖
		local lua_behaviour = cell_object:GetComponent("LuaBehaviour")
		if lua_behaviour ~= nil then
			LuaBehaviourUtil.setObjectVisible(lua_behaviour,"UI_Reward_LingQu_003",true)
		end
	end
	GameUtil:updateItemElement(cell_object, cell_data.reward[1], true, true)
end

function M:updateSelectTenStatus()
	local chase_count = self.m_model:getChaseCount()
	self:setTextByLanKey("select_ten_count_text", "new_str_0726", self.m_model:getShowTenCount())
	self:setObjectVisible("select_ten_open_img", self.m_model.m_chase_count_flag == true)
	self:setObjectVisible("select_ten_close_img", self.m_model.m_chase_count_flag == false)
	local cost = self.m_model:getChaseCostByTimes(chase_count)
	if #cost > 0 then
		local data = RewardUtil:getProcessRewardData(cost[1])
		self:setTextByLanKey("cost_item_num_text", data.user_num)
		self:setObjectVisible("select_ten_btn", data.user_num > 1)
		self:setImg(data.icon_name, data.atlas_name, "cost_item_icon")
	else
		self:setTextByLanKey("cost_item_num_text", "---")
		self:setObjectVisible("select_ten_btn", true)
	end
end

function M:updateSkipAnimStatus()
	self:setObjectVisible("skip_anim_open_img", self.m_model.m_skip_anim_flag == true)
	self:setObjectVisible("skip_anim_close_img", self.m_model.m_skip_anim_flag == false)
end

function M:updateArenaRewardWeek()
	local box_trans = self.m_box_node.transform
	UIUtil.destroyAllChild(box_trans)
	local show_data, cur_num = self.m_model:getBoxRewardData()
	local width = self.m_box_node_rt.rect.width
	local max_index = 0
	local max_num = 0
	local box_num = #show_data
	for i, v in ipairs(show_data) do
		max_num = v.cfg.point
		max_index = i
		if max_num >= cur_num then
			break
		end
	end
	max_num = max_num > 0 and max_num or 99999
	local start_mun_data = show_data[max_index - 1]
	local start_mun = start_mun_data and start_mun_data.cfg.point or 0
	self.m_new_box_reward_slider.value = math.max(0, (max_index - 1))/box_num + (cur_num - start_mun)/(max_num - start_mun)/box_num
	self:setTextByLanKey("cur_score_text", tostring(cur_num))
	for i=1,box_num do
		local data = show_data[i]
		local num = data.cfg.point
		local task_box = GameUtil:instanceObject(self.m_one_box_node, box_trans)
		task_box:SetActive(true)
		local transform = task_box.transform
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		UIUtil.setLocalPosition(task_box, width*i/box_num - width*0.5, 0)
		local function btns(trans,params)
			if data.status == 2 then -- 可领取
				self:updateMsg("box_reward", {click_transform = trans, data = data})
			else
				self:updateMsg("box_click", {click_transform = trans, data = data})
			end
		end
		UIUtil.setButtonClick(transform, btns, i)
		local score_text = UIUtil.setText(transform, tostring(num), "score_text")
		local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
		score_text.color = data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 255/255, 235/255, 68/255)
		local box_effect = UIUtil.findRectTransform(transform, "UI_Arena_BX_01")
		local box_effect2 = UIUtil.findRectTransform(transform, "UI_Arena_BX_02")
		if data.status == 0 then
			UIUtil.setImg(transform, "a_rw_xiangzi_weikai", "main_ui", "box_img")
		elseif data.status == 2 then
			UIUtil.setImg(transform, "a_rw_xiangzi_weikai", "main_ui", "box_img")
		elseif data.status == -1 then
			UIUtil.setImg(transform, "a_rw_xiangzi_kai", "main_ui", "box_img")
		end
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", i ~= box_num)
		if i < max_index then
			LuaBehaviourUtil.setImg(luaBehaviour, "line_img", "a_dsmz_jingdutiao_yidadao", "active_ui")
		elseif i == max_index then
			LuaBehaviourUtil.setImg(luaBehaviour, "line_img", "a_dsmz_jingdutiao_zhengzaidadao", "active_ui")
		else
			LuaBehaviourUtil.setImg(luaBehaviour, "line_img", "a_dsmz_jingdutiao_weidadao", "active_ui")
		end
		if box_effect ~= nil then
			box_effect.gameObject:SetActive(false)
		end
		if box_effect2 ~= nil then
			box_effect2.gameObject:SetActive(false)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_01", data.status == 2)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", data.status == 2)
		if data.status == 2 then
			if box_effect ~= nil then
				box_effect.gameObject:SetActive(true)
			end
			if box_effect2 ~= nil then
				box_effect2.gameObject:SetActive(true)
			end
		end
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("voyage_reset_time_update")
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	UserDataManager:removeRedDotByKey("daoshuai_once")
	M.super.destroy(self)
end

return M