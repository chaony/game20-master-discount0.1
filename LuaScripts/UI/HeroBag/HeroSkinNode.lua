
local M = class("HeroSkinNode",LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroSkinNode"


function M:onEnter()
	self:setTextByLanKey("in_crystal_text", "new_str_0207")
	self:setTextByLanKey("exchange_skin_list_btn_text", "new_str_0931")
	self:setTextByLanKey("get_skin_btn_text", "buy_growup_get")
	self:setTextByLanKey("get_skin_btn_text", "buy_growup_get")
	self.m_gray = self:findImage("gray")
	self.m_use_skin_btn_img = self:findImage("use_skin_btn")
	self.m_use_skin_btn = self:findButton("use_skin_btn")
	self:refreshUI()
	local skip_redPoint = RedPointUtil:checkHeroSkipRedPointById(self.m_model.m_selected_id)
	if skip_redPoint == true then
		RedPointUtil:clearHeroSkipRedPointById(self.m_model.m_selected_id)
		self.m_control.m_view:refreshRedPoint()
	end
end

function M:onButtonClick(obj, name)
	if name == "use_skin_btn" then
		audio:SendEvtUI("UI_Skin_On")
		if self.m_select_shin_data then
			if self.m_select_shin_data.own_flag == true then
				self:updateMsg("use_skin_btn", {skin_id = self.m_select_shin_data.id})
			else
				self:updateMsg("exchange_skin_btn", {skin_id = self.m_select_shin_data.id})
			end
		end
	elseif name == "cons_img" then
		if self.m_select_shin_data then
			local m_data = {top = true}
			local cur_obj = self:findGameObject("cons_img")
			m_data.click_transform = cur_obj.transform
			m_data.data = self.m_select_shin_data.cfg.convert[1]
			GameUtil:lookInfoTips(self.m_control, m_data)
		end
	elseif name == "get_skin_btn" then
		if self.m_select_shin_data then
			local skin_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN, self.m_select_shin_data.id, 1})
			local attrs = UserDataManager:appendAttrs(self.m_select_shin_data.cfg.attr)
			local story_str = ""
			for k, v in pairs(attrs) do
				local cp = GameUtil:getAttrsName(k)
				-- 四舍五入保留小数点后一位
				local attr_value = v or 0
				attr_value = math.floor(attr_value)
				story_str = story_str .. cp .. "  +"
				if GameUtil:attrTransition(k) == true then
					story_str = story_str .. GameUtil:formatNum(attr_value).."%  "
				else
					story_str = story_str .. GameUtil:formatNum(attr_value) .. "  "
				end
			end
			
			skin_data.name = self.m_select_shin_data.cfg.skin_name
			skin_data.story = story_str
			QuickOpenFuncUtil:costsTips(skin_data)
		end
	else
		M.super.onButtonClick(self, obj, name)
	end
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.before_pos = Vector2.zero
	local data, select_index = self.m_model:getHeroSkinData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("skin_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:moveToIndex(index-1)
				self:updateMsg("click_skin_item", {id = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
		self.m_loop_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
		self.offset_pos = self.m_loop_scroll_view:getContentOffset()
		GameMain.addUpdate("HeroSkinNode_update" , handler(self, self.posUpdate))
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
	if #data > 0 then
		self:moveToIndex(select_index - 1)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local hero_img_bg = luaBehaviour:FindImage("hero_img_bg")
	local hero_img = luaBehaviour:FindImage("hero_img")
	if cell_data.own_flag then
		hero_img_bg.material = nil
		hero_img.material = nil
	else
		hero_img_bg.material = self.m_gray.material
		hero_img.material = self.m_gray.material
	end
	local icon_name = cell_data.cfg.skin_icon
	GameUtil:updateResourcesImg(hero_img, "Texture/HeroIcon/" .. icon_name)
	if cell_data.cfg.skin_quality ~= 0 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skin_quality", true)
		LuaBehaviourUtil.setImg(luaBehaviour, "skin_quality", "a_hero_skin_"..GameUtil:fillNumWithZero(cell_data.cfg.skin_quality, 2), ResourceUtil:getLanAtlas())
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skin_quality", false)
	end
end

function M:onValueChanged(pos)
	if math.floor(self.before_pos.x*100) ~= math.floor(pos.x*100) then
		self.move_flag = true
		self.before_pos.x = pos.x
		self.before_pos.y = pos.y
		self:updateCells()
	end
end

function M:updateCells()
	local rect = self.m_loop_scroll_view.m_scroll_rect.viewport.rect
	local cellSize = self.m_loop_scroll_view.m_loop_scroll_view.cellSize
	local offset_pos = self.m_loop_scroll_view:getContentOffset()
	local center_pos_x = - offset_pos.x +  rect.width*0.5
	local init_cells = self.m_loop_scroll_view:getInitCells()
	for i, v in pairs(init_cells) do
		local view_cell = v:GetComponent("ScrollViewCell")
		local luaBehaviour = v:GetComponent("LuaBehaviour")
		local hero_img_bg = luaBehaviour:FindGameObject("hero_img_bg")
		local localPosition = view_cell.transform.localPosition
		local diff_x = center_pos_x - (localPosition.x + cellSize.x*0.5)
		diff_x = math.abs(diff_x)
		local scale = 1 - math.min(1, diff_x/rect.width*0.75)
		UIUtil.setScale(hero_img_bg.transform, scale, scale)
		if scale > 0.9 then
			luaBehaviour.transform:SetAsLastSibling()
		else
			luaBehaviour.transform:SetAsFirstSibling()
		end
	end
end

function M:posUpdate()
	if self.m_loop_scroll_view.m_loop_scroll_view.dragFlag == false then
		if self.move_flag then
			local offset_pos = self.m_loop_scroll_view:getContentOffset()
			if math.abs(self.offset_pos.x - offset_pos.x) < 0.1 then
				local rect = self.m_loop_scroll_view.m_scroll_rect.viewport.rect
				local cellSize = self.m_loop_scroll_view.m_loop_scroll_view.cellSize
				local offset_pos = self.m_loop_scroll_view:getContentOffset()
				local center_pos_x = - offset_pos.x + rect.width*0.5
				local center_index = math.floor((center_pos_x - rect.width*0.5)/cellSize.x + 0.5)
				self:moveToIndex(center_index)
				self.move_flag = false
			else
				self.offset_pos = offset_pos
			end
		end
	end
end

function M:moveToIndex(move_index)
	local show_data = self.m_loop_scroll_view.m_show_data or {}
	local max_index = #show_data
	local center_index = math.min(math.max(move_index, 0), max_index - 1)
	local rect = self.m_loop_scroll_view.m_scroll_rect.viewport.rect
	local c_rect = self.m_loop_scroll_view.m_scroll_rect.content.rect
	local cellSize = self.m_loop_scroll_view.m_loop_scroll_view.cellSize
	local max_offset_x = c_rect.width - rect.width
	local padding = self.m_loop_scroll_view.m_loop_scroll_view.padding
	local move_pos_x = padding.left + (center_index + 1)*cellSize.x - rect.width*0.5 - cellSize.x*0.5
	self.m_loop_scroll_view:setHorizontalNormalizedPosition(move_pos_x/max_offset_x)
	local show_data = show_data[center_index+1]
	self.m_select_shin_data = show_data
	
	local skin_cfg = ConfigManager:getHeroSkinCfg(show_data.id)
	self:setTextByLanKey("skin_name", skin_cfg.skin_name)
	local attrs = UserDataManager:appendAttrs(skin_cfg.attr)
	local attr_data = {}
	for i, v in pairs(attrs) do
		table.insert(attr_data, {i, v})
	end
	if table.nums(attr_data) > 0 then
		self:setObjectVisible("loopscroll", true)
		self:setObjectVisible("default_attr_text", false)
		self:setAttr(attr_data)
	else
		self:setObjectVisible("loopscroll", false)
		self:setObjectVisible("default_attr_text", true)
		self:setTextByLanKey("default_attr_text", "new_str_0825")
	end
	
	self:updateMsg("refreshSkinSpine", {id = show_data.id , skin_cfg = skin_cfg})
	self:setObjectVisible("get_skin_btn", false)
	if show_data.own_flag then
		self:setTextByLanKey("unlock_text", "")
		self:setObjectVisible("use_skin_btn", true)
		self:setObjectVisible("cons_bg", false)

		local btn_color = self.m_use_skin_btn_img.color
		if show_data.select_flag then
			self:setTextByLanKey("use_skin_btn_text", "new_str_0714")
			self.m_use_skin_btn.enabled = false
			btn_color.r = 0.7
			btn_color.g = 0.7
			btn_color.b = 0.7
		else
			self.m_use_skin_btn.enabled = true
			self:setTextByLanKey("use_skin_btn_text", "new_str_0715")
			btn_color.r = 1
			btn_color.g = 1
			btn_color.b = 1
		end
		self.m_use_skin_btn_img.color = btn_color
	else
		self:setTextByLanKey("unlock_text", show_data.cfg.type)
		--if #show_data.cfg.convert > 0 then
		--	self.m_use_skin_btn.enabled = true
		--	self:setTextByLanKey("use_skin_btn_text", "new_str_0907")
		--	self:setObjectVisible("cons_bg", true)
		--	self:setObjectVisible("use_skin_btn", true)
		--	local consItem = RewardUtil:getProcessRewardData(show_data.cfg.convert[1])
		--	self:setImg(consItem.icon_name, consItem.atlas_name, "cons_img")
		--	self:setText("cons_num", consItem.user_num.."/"..consItem.data_num)
		--else
			self:setObjectVisible("cons_bg", false)
			self:setObjectVisible("use_skin_btn", false)
			self:setObjectVisible("get_skin_btn", true)
		--end
	end
	self:updateCells()
end

function M:setAttr(attr_data)
	local data = attr_data or {}
	if self.m_attrs_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local cp = GameUtil:getAttrsName(cell_data[1])
				-- 四舍五入保留小数点后一位
				local attr_value = cell_data[2] or 0
				attr_value = math.floor(attr_value)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_name_text", cp)
				if GameUtil:attrTransition(cell_data[1]) == true then
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_value_text", "+" .. GameUtil:formatNum(attr_value).."%")
				else
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_value_text", "+" .. GameUtil:formatNum(attr_value))
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_attrs_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_attrs_loop_scroll_view:reloadData(data)
	end
end

function M:destroy()
	self:updateMsg("refreshSkinSpine", {id = 0 , skin_cfg = nil})
	GameMain.removeUpdate("HeroSkinNode_update")
	M.super.destroy(self)
end

return M