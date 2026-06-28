local M = class("ItemDetailView",LikeOO.OOPopBase)

M.m_uiName = "Item/ItemDetail"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("cost_title_text", "new_str_0140")
	self:setTextByLanKey("item_info_title_text", "new_str_0046")
	self:setTextByLanKey("use_info_title_text", "new_str_0047")
	self:setTextByLanKey("name_text_1", "new_str_0434")
	self:setTextByLanKey("own_text", "new_str_0045")
	self:setTextByLanKey("max_btn_text", "new_str_0065")
	self.m_gray_image = self:findImage("gray_image")

	self.m_gain_node = self:findGameObject("gain_node")
	self.m_gain_nodes = self:findGameObject("gain_nodes")
	self.m_icon_node = self:findGameObject("icon_node")
	local show_data = self.m_model.m_show_data
	local item_cfg = show_data.item_cfg
	self:setTextByLanKey("common_title_text", "new_str_0041")
	self:setTextByLanKey("item_name_text", show_data.name)
	--self:setTextByLanKey("name_text", "new_str_0429", Language:getTextByKey(item_cfg.type_name or ""))
	self:setText("name_text",  Language:getTextByKey(item_cfg.type_name or "new_str_0589"))
	local strCount = 0--string.utf8len(str)
	if item_cfg.type == 18 then
		local str = self.m_model:getTempStr().."\n\n"..show_data.story
		strCount = string.utf8len(str)
		self:setTextByLanKey("item_des_text", str)
	else
		self:setTextByLanKey("item_des_text", show_data.story)
		strCount = string.utf8len(show_data.story)
	end
	local text_scroll = self:findImage("text_scroll")
	text_scroll.raycastTarget = strCount > 300
	if self.m_model.m_cost then-- 购买
		local use_btn_text = self:setTextByLanKey("use_btn_text", "new_str_0037")
		-- use_btn_text.color = GlobalConfig.COMMON_COLLOR.COMMON_4
		--self:setImg("a_ui_btn_lvanniu_s", "common_ui", "use_btn")
		--UIUtil.setOutlineExEffectColor(use_btn_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_3)
	else
		local use_btn_text = self:setTextByLanKey("use_btn_text", item_cfg.sort == 2 and "new_str_0049" or "new_str_0048")
		-- use_btn_text.color = GlobalConfig.COMMON_COLLOR.COMMON_4
		--self:setImg("a_ui_btn_chenganniu_s", "common_ui", "use_btn")
		--UIUtil.setOutlineExEffectColor(use_btn_text, nil, GlobalConfig.COMMON_COLLOR_OUTLINE.COMMON_5)
	end
	GameUtil:createItemElementByData(show_data, false, false, nil, self.m_icon_node.transform)
	self.m_need_num_slider = self:findSlider("need_num_slider")
	self.m_user_num_slider = self:findSlider("user_num_slider")
	self.today = self.m_model.m_today_btn_value
	self:setTextByLanKey("today_text", self.m_model.m_today_text)
	self:setObjectVisible("today_btn", self.m_model.m_isToday)
	if self.m_model.m_isToday then
		self:todayIsActive()
	end
	self:refreshUI()
end

function M:refreshUI()
	self:updateUseNum()
	self:updateLoopScroll()
end

function M:updateUseNum()
	self:setObjectVisible("red_point_img", false)
	self:setObjectVisible("user_num_slider", false)
	if self.m_model.m_cost then-- 购买
		self:setObjectVisible("need_num_node", false)
		self:setObjectVisible("use_node", false)
		self:setObjectVisible("cost_node", self.m_model.m_show_buy_btn == true)
		self:setObjectVisible("use_btn", self.m_model.m_show_buy_btn == true)
		local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
		local cost_num = GameUtil:formatValueToString(data.data_num)
		local user_num = GameUtil:formatValueToString(data.user_num)
		local cost_num_text = self:setTextByLanKey("cost_num_text",  cost_num)
		-- local cost_num_text = self:setTextByLanKey("cost_num_text", data.data_num > data.user_num and "new_str_0412" or "new_str_0410", cost_num, user_num)
		cost_num_text.color = GlobalConfig.COMMON_COLLOR.COMMON_10
		self:setImg(data.icon_name, "item_icon", "cost_icon")
		local show_data = self.m_model.m_show_data
		--self:setTextByLanKey("own_num_text", "new_str_0430", tostring(show_data.user_num))
		self:setText("own_num_text", tostring(show_data.user_num))
	else -- 查看、使用
		self:setObjectVisible("cost_node", false)
		local use_max = self.m_model:getMaxNum()
		local use_num = self.m_model:getUseNum()
		local show_data = self.m_model.m_show_data
		local item_cfg = show_data.item_cfg
		local cfg_use_num = item_cfg.use_num
		--self:setTextByLanKey("own_num_text", "new_str_0430", tostring(show_data.user_num))
		self:setText("own_num_text", tostring(show_data.user_num))
		local use_num_text = self:setTextByLanKey("use_num_text", "new_str_0050", use_num, use_max)
		self:setObjectVisible("use_node", item_cfg.can_use == 1)
		if item_cfg.can_use == 1 then
			self:setObjectVisible("use_node", item_cfg.use_multi == 0)
		end
		self:setObjectVisible("use_btn", item_cfg.can_use == 1)
		--self:setObjectVisible("need_num_node", item_cfg.can_use == 1 and cfg_use_num > 1)
		if cfg_use_num > 0 then
			self:setTextByLanKey("need_num_text", "new_str_0053", show_data.user_num, cfg_use_num)
			self.m_need_num_slider.value = show_data.user_num/cfg_use_num
		end
		if item_cfg.sort == 2 then --碎片
			self:setObjectVisible("red_point_img", show_data.user_num >= cfg_use_num)
			use_num_text.color = use_num > 0 and GlobalConfig.COMMON_COLLOR.COMMON_2 or GlobalConfig.COMMON_COLLOR.COMMON_9
		end
		if item_cfg.type == 12 then --双倍充值券
			self:setObjectVisible("user_num_slider", true)
			local item_data = UserDataManager.item_data:getItemDataById(show_data.data_id)
			self:setTextByLanKey("user_num_text", "new_str_0053", item_data.value, item_cfg.effect)
			self.m_user_num_slider.value = item_data.value/item_cfg.effect
		end
		local item_type = item_cfg.type
		if item_type == 4 or item_type == 5 or item_type == 6 or item_type == 7 then
			local reward = GameUtil:getHangUpReward(item_cfg, use_num)
			if #reward > 0 then
				self.m_gain_nodes:SetActive(true)
				UIUtil.destroyAllChild(self.m_gain_nodes.transform)
				for i,v in ipairs(reward) do
					local obj = GameUtil:instanceObject(self.m_gain_node, self.m_gain_nodes.transform)
					obj:SetActive(true)
					local data = RewardUtil:getProcessRewardData(v)
					local text,unit  = GameUtil:formatValueToString(data.data_num)
					local gain_num_text = UIUtil.setTextByLanKey(obj.transform, "gain_num_text", text)
					UIUtil.setImg(obj.transform, data.icon_name, "item_icon" ,"gain_img") --装备Icon
				end
			else
				self.m_gain_nodes:SetActive(false)
			end
		else
			self.m_gain_nodes:SetActive(false)
		end
		local level = UserDataManager.user_data:getUserStatusDataByKey("level") or 1
		local player_lv = item_cfg.player_lv or 1
		local use_btn_img = self:findImage("use_btn")
		local use_btn = self:findButton("use_btn")
		if level < player_lv then -- 未解锁
			self:setTextByLanKey("unlock_text", "new_str_0350", player_lv)
			use_btn_img.material = self.m_gray_image.material
			use_btn.enabled = false
		else
			use_btn_img.material = nil
			use_btn.enabled = true
		end
		self:setObjectVisible("unlock_text", level < player_lv)
		if self.m_model.m_display then
			self:setObjectVisible("use_node", false)
			self:setObjectVisible("use_btn", false)
		end
	end
end


--[[
	创建列表
]]
function M:updateLoopScroll()
	local show_data = self.m_model.m_show_data
	local item_cfg = show_data.item_cfg
	local data = item_cfg.content_show or {}
	if item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_BOX then
		GameUtil:updateItemEffect(show_data)
		data = show_data.item_content_show or {}
	end
	self:setObjectVisible("loopscroll", #data > 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local data = cell_data
				GameUtil:updateItemElement(cell_object, data, true, true)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:todayIsActive(...)
	if self.today then
		self:setObjectVisible("yes", true)
		self.today_callback = true
		self.cur_server_ts = UserDataManager:getServerTime()
	else
		self:setObjectVisible("yes", false)
		self.today_callback = false
		self.cur_server_ts = nil
	end
end

return M