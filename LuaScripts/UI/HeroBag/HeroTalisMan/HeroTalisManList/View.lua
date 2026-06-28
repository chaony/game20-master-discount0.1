local M = class("TalisManmentListView",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroTalisMan/TalisManmentList"
M.m_size_type = 2
local __TAB_BTN_NODE = {
	[1] = "talisman_text_001",
	[2] = "talisman_text_002",
	[3] = "talisman_text_003",
	[4] = "talisman_text_004",
}

function M:onEnter()
	self:initText()
	self:refreshUI()
end

function M:initText()
	local text = __TAB_BTN_NODE[self.m_model.pos] or "talisman_text_001"
	self:setTextByLanKey("common_title_text", text)
	self:setTextByLanKey("shiyong_txt", "talisman_text_005")
	self:setTextByLanKey("left_property_title_txt", "talisman_text_006")
end
function M:refreshUI()
	self:updateTeshuView()
	self:updateLoopScroll()
	self:updateLeftInfo()
end

function M:updateLeftInfo()
	local data = self.m_model:getCurrentTalinsDataByPos(self.m_model.pos)
	self.m_model.lock_num  = 0
	if data then
		self:setObjectVisible("left_effect_bg1",true)
		self:setObjectVisible("Image_left",true)
		self:setObjectVisible("Image_left_quality",true)
		--设置符篆图标
		local cfgData = self.m_model:getTalisSuitConfigByCid(data.id or 1)
		self:setImg(cfgData.icon,"maze_stage_ui","Image_left")
		local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[cfgData.quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
		local frame_name = quality_item.hero_item_frame
		self:setImg(frame_name,"hero_head_ui","Image_left_quality")
		--上锁数量
		for i = 1,3 do
			self:setObjectVisible("left_empty_text"..i,false)
		end
		for i = 1,3 do
			local attrsData = data.attrs[tostring(i)]
			if attrsData then
				self:setObjectVisible("left_property_empty_"..i,false)
				self:setObjectVisible("left_property_not_empty_"..i,true)
				local reward_bar = self:findSlider("left_property_slider_"..i)
				local cur_value,max_value = self.m_model:getCurrentLimitbyId(cfgData.quality,self.m_model.pos,attrsData.team_id,attrsData.value[2])
				reward_bar.value = cur_value/max_value
				--设置属性
				local showArr = self.m_model:getCurrentAttrs({attrsData.value})
				local at_name = GameUtil:getAttrsName(showArr[1]).."："
				--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_name_text", at_name)
				-- 四舍五入保留小数点后一位
				local attr_value = showArr[2].cur_num or 0
				attr_value = math.floor(attr_value * 10 + 0.5)/10
				if GameUtil:newattrTransition2(showArr[1]) == true then
					self:setTextByLanKey("left_property_text_"..i, at_name..GameUtil:formatValueToString(attr_value).."%")
				else
					self:setTextByLanKey("left_property_text_"..i, at_name..GameUtil:formatValueToString(attr_value))
				end
				self:setTextColor("left_property_text_"..i,self.m_model:getCurrentPropertyTextColor(attrsData.value[2],self.m_model.pos,attrsData.value[1]))
				--设置锁的状态
				local lockImage = attrsData.locked ==1 and "a_zbxl_jinsuo" or "a_zbxl_suo_open"
				local path = attrsData.locked ==1 and "mystic_ui" or "active_ui"
				self:setImg(lockImage, path, "left_property_lock_"..i)
				--设置特效
				if attrsData.locked == 0 and self.m_model.is_refresh_effet == true then
					local back_effect = self:findGameObject("left_property_not_empty_back_"..i)
					UIUtil.destroyAllChild(back_effect.transform)
					local eqp_effect2 = ResourceUtil:GetUIEffectItem("ItemNode/UI_ItemNode_Talins_001", self:findGameObject("left_property_not_empty_"..i))
					eqp_effect2.transform:SetParent(back_effect.transform, false)
					eqp_effect2.transform.localPosition = Vector3(0,0,0)
				end
				--计算上数量
				self.m_model.lock_num = attrsData.locked ==1 and self.m_model.lock_num +1 or self.m_model.lock_num
			else
				self:setObjectVisible("left_property_empty_"..i,true)
				self:setObjectVisible("left_property_not_empty_"..i,false)
			end
			
		end
		--特殊处理红色
		if cfgData.quality <14 then
			self:setObjectVisible("left_property_empty_"..3,false)
			self:setObjectVisible("left_property_not_empty_"..3,false)
		end
	else
		self:setObjectVisible("left_effect_bg1",false)
		self:setObjectVisible("Image_left",false)
		self:setObjectVisible("Image_left_quality",false)
		for i = 1,3 do 
			self:setObjectVisible("left_property_empty_"..i,true)
			self:setObjectVisible("left_empty_text"..i,true)
			self:setObjectVisible("left_property_not_empty_"..i,false)
		end
	end
	--刷新效果
	self:updateLeftInfoEfeect()
	--刷新元宝数量
	--local diamond_num = UserDataManager.user_data:getUserStatusDataByKey("diamond") or 0
	--self:setTextByLanKey("yuangbao_txt",GameUtil:formatValueToString(diamond_num))
	local commonData = ConfigManager:getCfgByName("common")
	local commonDataIndex = commonData[771]
	if self.m_model.lock_num > 0 then
		self:setObjectVisible("yuanbao_bg",true)
		self:setObjectVisible("yuangbao_txt",true)
		local num = commonDataIndex.value[self.m_model.lock_num][2] or 0
		local diamond_num = UserDataManager.user_data:getUserStatusDataByKey("diamond") or 0
		self:setTextByLanKey("yuangbao_txt",GameUtil:formatValueToString(num))
		if num > diamond_num then
			self:setTextColor("yuangbao_txt",GlobalConfig.FUZHUAN_GRADE_COLOR[10]) --红色
		end
	else
		self:setObjectVisible("yuanbao_bg",false)
		self:setObjectVisible("yuangbao_txt",false)
	end
	--设置特特效默认状态
	self.m_model.is_refresh_effet = false
end

--刷新左侧共鸣效果
function M:updateLeftInfoEfeect()
	local curid = self.m_model:getCurrentTalinsDataByPos(self.m_model.pos) and self.m_model:getCurrentTalinsDataByPos(self.m_model.pos).id or 0
	local curData = self.m_model:getTalisSuitConfigByCid(curid) or nil
	local clickData = self.m_model:getTalisSuitConfigByCid(self.m_model.m_select_cell_data.id) or nil
	if curData  then
		for i= 1,2 do
			local title = i== 1 and "talisman_text_007" or "talisman_text_008"
			local des = i==1 and curData.addition2.tips or curData.addition4.tips
			local efeectNum = self.m_model:getHeroTalinsEfeectNum() --判断是两件事4 件
			local isFalg = efeectNum >= (i*2) and true or false
			local text = isFalg == true and "talisman_text_0023" or "talisman_text_0022"
			efeectNum = efeectNum>= i*2 and i*2 or efeectNum
			local text2 = string.format(Language:getTextByKey("talisman_text_0030"),efeectNum,i*2)
			local text3 = i%2 == 0 and "talisman_text_0033" or "talisman_text_0032"
			self:setTextByLanKey("left_effect_text_"..i,text,curData.resonance_name..Language:getTextByKey(text3)..text2)
			self:setTextByLanKey("left_effect_des_text_"..i,des)
			if isFalg then
				self:setTextColor("left_effect_des_text_"..i,Color( 64/255, 118/255, 17/255))
			else
				self:setTextColor("left_effect_des_text_"..i,Color( 19/255, 27/255, 39/255))
			end
		end
	end
	if clickData then
		for i= 1,2 do
			local title = i== 1 and "talisman_text_007" or "talisman_text_008"
			local des = i==1 and clickData.addition2.tips or clickData.addition4.tips
			local efeectNum = self.m_model:getHeroTalinsEfeectNumFail(self.m_model.m_select_cell_data.id) --判断是两件事4 件
			local isFalg = efeectNum >= (i*2) and true or false
			local text = isFalg == true and "talisman_text_0023" or "talisman_text_0022"
			efeectNum = efeectNum>= i*2 and i*2 or efeectNum
			local text2 = string.format(Language:getTextByKey("talisman_text_0030"),efeectNum,i*2)
			local text3 = i%2 == 0 and "talisman_text_0033" or "talisman_text_0032"
			self:setTextByLanKey("right_effect_text_"..i,text,clickData.resonance_name..Language:getTextByKey(text3)..text2)
			self:setTextByLanKey("right_effect_des_text_"..i,des)
			if isFalg then
				self:setTextColor("right_effect_des_text_"..i,Color( 64/255, 118/255, 17/255))
			else
				self:setTextColor("right_effect_des_text_"..i,Color( 19/255, 27/255, 39/255))
			end
		end
	end
   for i=1,4 do
	   local obj = self:findGameObject("text_scroll_"..i) 
	   local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	   local Content_list = luaBehaviour:FindRectTransform("eqp_content")
	   --设置滑动条位置
	   local vec2 = Content_list.transform.anchoredPosition
	   vec2.y = i%2 == 0 and 29.82187 or 24.76535;
	   Content_list.transform.anchoredPosition = vec2
   end
end
--[[
	创建列表
]]
function M:updateLoopScroll(keep_offset)
	local data = self.m_model:getTalisData()
	--data = {[2]={},[3]={},[4]={},[5]={},[10]={}}
	self:setObjectVisible("CommonTipsNode", #data == 0)
	local new_index = nil
	--if self.m_select_cell_data then -- 用于刷新重新定位
	--	for k,v in pairs(data) do
	--		if v.data_type == self.m_select_cell_data.data_type and v.data_id == self.m_select_cell_data.data_id then
	--			new_index = k
	--			self.m_select_cell_data = v
	--			self.m_select_cell_index = k
	--			break
	--		end
	--	end
	--end
	--if new_index == nil then
	--	self.m_select_cell_index = 1
	--	self.m_select_cell_object = nil
	--end
	--if self.m_first_enter then
	--	self.m_control:setOnceTimer(0.2, function()
	--		self:openItemInfo(data[self.m_select_cell_index])
	--	end)
	--else
	--	self:openItemInfo(data[self.m_select_cell_index])
	--end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = loopscroll,
			init_cell = function(index, cell_object)
				--self.m_control:setOnceTimer(index <= 36 and 0.016*index or 0, function()
				--	local cell_data = self.m_loop_scroll_view.m_show_data[index]
				--	local itemNode = GameUtil:createPrefab("Common/ItemNode")
				--	local canvas_group = itemNode:GetComponent("CanvasGroup")
				--	canvas_group.blocksRaycasts = false
				--	itemNode.name = "cell_content"
				--	itemNode.transform:SetParent(cell_object.transform, false)
				--	if cell_data then
				--		self:updateScrollViewCell(index, itemNode, cell_data)
				--		if self.m_select_cell_index == index then
				--			self.m_select_cell_object = cell_object
				--			self.m_select_cell_data = cell_data
				--		end
				--	end
				--end)
			end,
			update_cell = function(index, cell_object, cell_data)
				--local content_tran = UIUtil.findTrans(cell_object.transform, "cell_content")
				--if not IsNull(content_tran) then
					--self:updateScrollViewCell(index, content_tran.gameObject, cell_data)
					self:updateScrollViewCell(index, cell_object, cell_data)
					if self.m_model.m_select_cell_index == index then
						self.m_model.m_select_cell_object = cell_object
						self.m_model.m_select_cell_data = cell_data
						self:updateLeftInfoEfeect() --刷新左边效果
					end
				--end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
					if self.m_model.m_select_cell_object then
						local luaBehaviour = UIUtil.findLuaBehaviour(self.m_model.m_select_cell_object)
						LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", false)
					end
					local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", true)
					self.m_model.m_select_cell_object = cell_object
					self.m_model.m_select_cell_index = index
					self.m_model.m_select_cell_data = cell_data
					self:updateLeftInfoEfeect() --刷新左边效果
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local item = luaBehaviour:FindGameObject("ItemNode")
	GameUtil:updateItemElement(item, data.reward or {170,1,2}, true, false)
	--local ui_element = GameUtil:updateItemElementByData(item, data, false, false)
	--if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
	--	local red_flag = RedPointUtil:checkItemRedPointById(data.data_id)
	--	ui_element.red_point_img:SetActive(red_flag)
	--end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "select_image", self.m_model.m_select_cell_index == index)
end

function M:openItemInfo(cell_data)
	if self.m_item_detail_node then
		self.m_item_detail_node:destroy()
		self.m_item_detail_node = nil
	end
	if cell_data then
		local tab_cls = nil
		if cell_data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
			if cell_data.item_cfg.type == GlobalConfig.ITEM_TYPE.CONDITION_BOX then --条件礼包
				tab_cls = CustomRequire("UI.Item.ItemBoxNode")
			--elseif cell_data.item_cfg.type == GlobalConfig.ITEM_TYPE.MUL_BOX then --多可选宝箱
			--	tab_cls = CustomRequire("UI.Item.ItemMulBoxNode")
			else
				tab_cls = CustomRequire("UI.Item.ItemDetailNode")
			end
		elseif cell_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
			tab_cls = CustomRequire("UI.Item.ItemEquipNode")
		elseif cell_data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
			tab_cls = CustomRequire("UI.Item.MysticDetailNode")
		end
		if tab_cls then
			self.m_item_detail_node = tab_cls.new(self.m_control, {parent = self.m_detail_node})
			self.m_item_detail_node:updateView(cell_data)
		end
	end
end

function M:updateTeshuView()
	local curid = self.m_model:getCurrentTalinsDataByPos(self.m_model.pos) and self.m_model:getCurrentTalinsDataByPos(self.m_model.pos).id or 0
	local curData = self.m_model:getTalisSuitConfigByCid(curid) or nil
	if not curData then return end
	if curData.quality <=14  then 
		for i=1,3 do
			self:setObjectVisible( "left_property_lock_"..i,false)
		end
	else
		for i=1,3 do
			self:setObjectVisible( "left_property_lock_"..i,true)
		end
	end
	--特殊处理红色
end

function M:destroy()
	if self.m_item_detail_node then
		self.m_item_detail_node:destroy()
		self.m_item_detail_node = nil
	end
	M.super.destroy(self)
end

return M