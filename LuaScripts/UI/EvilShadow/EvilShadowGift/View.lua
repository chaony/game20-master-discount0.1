local M = class("EvilShadowGiftView",LikeOO.OOPopBase)

M.m_uiName = "EvilShadow/EvilShadowGift"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "evil_shadow_str_003")
	self.m_node_cache = {}
	self:refreshUI()
	RedPointUtil:saveLocalRedPointFreshTime("EvilShadowGift")
end

--刷新UI
function M:refreshUI()
	local attr_mode = 1
	if self.m_model.is_tokens == true then
		attr_mode = 20
	end
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
	self:updateBagNode()
	self:setHeroInfo()
end

function M:updateBagNode()
	for index = 1, 4 do
		local data = self.m_model:getShowData(index)
		
		if self.m_node_cache[index] == nil then
			self.m_node_cache[index] = {}
		end
		if self.m_node_cache[index].luaBehaviour == nil then
			local name = "bag_node_" .. index
			local object = self:findGameObject(name)
			local transform = object.transform
			object:SetActive(data ~= nil and next(data) ~= nil)
			self.m_node_cache[index].luaBehaviour = UIUtil.findLuaBehaviour(transform)
		end
		if data == nil or data.times and data.time_limit and data.times >= data.time_limit then --购买次数已满，或者数据非法时，锁住购买按钮
			local bg_img = self.m_node_cache[index].luaBehaviour:FindGameObject("bg_img")
			GameUtil:updateResourcesImg(bg_img, "Texture/evil_shadow/a_mycs_yilinqulibaochendi")
			local btn_buy = self:findButton("buy_btn_" .. index)
			btn_buy.enabled = false
		end
		if data then
			local limit_time = 0
			if data.time_limit and data.times and data.time_limit - data.times > 0 then
				limit_time = data.time_limit - data.times
			end
			LuaBehaviourUtil.setTextByLanKey(self.m_node_cache[index].luaBehaviour, "title_text", "evil_shadow_str_012", limit_time)
			local price_str = "免费"
			if data.price ~= nil and data.price ~= 0 then
				price_str = data.price .. "元"
			end
			LuaBehaviourUtil.setText(self.m_node_cache[index].luaBehaviour, "buy_text", price_str)
			self:updateLoopscroll(index, data.reward)
		end
	end
end

function M:updateLoopscroll(node_index, data)
	if self.m_node_cache[node_index].looscrollview == nil then
		local loopscroll = self.m_node_cache[node_index].luaBehaviour:FindGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 2,
			loop_scroll_object = loopscroll,
			init_cell = function(index, cell_object)
				local cell_data = data[index]
				local itemNode = GameUtil:createPrefab("Common/ItemNode")
				local canvas_group = itemNode:GetComponent("CanvasGroup")
				canvas_group.blocksRaycasts = false
				itemNode.name = "cell_content"
				itemNode.transform:SetParent(cell_object.transform, false)
				if cell_data then
					self:updateLoopscrollCell(index, itemNode, cell_data)
				end
			end,
			update_cell = function(index, cell_object, cell_data)
				local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
				if not IsNull(content_tran) then
					self:updateLoopscrollCell(index, cell_object, cell_data)
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_node_cache[node_index].looscrollview = LoopScrollViewUtil.new(params)
	else
		self.m_node_cache[node_index].looscrollview:reloadData(data)
	end
end

function M:updateLoopscrollCell(index, cell_object, cell_data)
	local item_data = RewardUtil:getProcessRewardData(cell_data)
	GameUtil:updateItemElementByData(cell_object, item_data, true, true)
end

function M:updateActivityTimer()
	local min_unit = 60
	local hour_unit = min_unit * 60
	local time_now = UserDataManager:getServerTime()
	local time_day_end = TimeUtil.getIntTimestamp(time_now) + hour_unit * 24 * 1
	local time_left = time_day_end - time_now
	local hour_left = math.floor(time_left / (hour_unit))
	local min_left = math.floor((time_left - hour_unit * hour_left) / min_unit)
	local sec_left = math.floor(time_left - hour_unit * hour_left - min_unit * min_left)
	local timerFormat = Language:getTextByKey("evil_shadow_str_010", hour_left, min_left, sec_left)
	self:setText("text_timer", timerFormat)
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

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	M.super.destroy(self)
end


return M