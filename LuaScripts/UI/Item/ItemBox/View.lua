local M = class("ItemBoxView",LikeOO.OOPopBase)

M.m_uiName = "Item/ItemBox"
M.m_size_type = 1

local ItemBgType = {
	Blue = "a_xn_daojudi_lanse",
	Green = "a_xn_daojudi_lvse",
	Purple = "a_xn_daojudi_zise",
}

function M:onEnter()
	self:setTextByLanKey("box_title_text", "new_str_0054")
	self:setTextByLanKey("title_text", "select_rew_tex")
	-- self:setTextByLanKey("own_text", "new_str_0045")
	self:setTextByLanKey("choice_btn_text", "new_str_0771")
	local show_data = self.m_model.m_show_data
	local item_cfg = show_data.item_cfg
	self:setTextByLanKey("common_title_text", show_data.name)
	self:setTextByLanKey("name_text", Language:getTextByKey(item_cfg.type_name))
	self:setTextByLanKey("item_des_text", show_data.story)
	self.m_icon_node = self:findGameObject("icon_node")
	GameUtil:createItemElementByData(show_data, false, false, nil, self.m_icon_node.transform)
	self:setTextByLanKey("hint_text", "new_str_0905")
	self:refreshUI()
end

function M:refreshUI()
	local show_data = self.m_model.m_show_data
	self:setTextByLanKey("own_num_text", "new_str_0430", tostring(show_data.user_num))
	if self.m_model:isHeroReward() then
		self:setObjectVisible("box_loopscroll", false)
		self:updateHeroLoopScroll()
	else
		self:setObjectVisible("hero_loopscroll", false)
		self:updateBoxLoopScroll()
	end
end

--[[
	创建列表
]]
function M:updateBoxLoopScroll()
	local data = self.m_model:getShowData()
	self.m_select_cell = nil
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("box_loopscroll")
		loopscroll:SetActive(true)
		local params = {
			show_data = data,
			pos_center = true,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "select_btn" then
					--self:updateMsg("choice_item", {index = index})
					if not IsNull(self.m_select_cell) then
						local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_cell)
						LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_selectFrame", false)
					end
					self.m_select_cell = cell_object
					self.m_model.m_cur_select_index = index
					self.m_model.m_cur_select_id = cell_data.id
					local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_selectFrame", true)
				elseif click_name == "btn_lookBtn" then
					-- 查看
					
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_selectFrame", index == self.m_model.m_cur_select_index)
	if index == self.m_model.m_cur_select_index then
		self.m_select_cell = cell_object
	end
	local transform = cell_object.transform
	UIUtil.setTextByLanKey(transform, "choice_btn/choice_btn_text", "new_str_0056")
	local data = cell_data
	local item_node = UIUtil.findRectTransform(transform,"item_node")
	UIUtil.destroyAllChild(item_node)
	local item, ui_element = GameUtil:createItemElement(data, true, true)
	item.transform:SetParent(item_node.transform, false)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"martial_text", ui_element.process_data.name)
	local own_flag_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"own_flag_text", "new_str_0841")
	if ui_element.process_data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
		local mystic_data = UserDataManager.mystic_data:getMysticDataById(ui_element.process_data.data_id)
		own_flag_text.gameObject:SetActive(mystic_data ~= nil)
	else
		own_flag_text.gameObject:SetActive(false)
	end
	local curQuality = ui_element.process_data.quality
	local itemBgName = nil
	if curQuality == 2 then
		itemBgName = ItemBgType.Green
	elseif curQuality == 3 then
		itemBgName = ItemBgType.Blue
	elseif curQuality >= 5 then
		itemBgName = ItemBgType.Purple
	end
	if itemBgName then
		local itemBgObj = luaBehaviour:FindImage("select_btn")
		GameUtil:updateResourcesImg(itemBgObj, "Texture/pub_tex/"..itemBgName)
	end
end

--[[
	创建列表
]]
function M:updateHeroLoopScroll()
	local data = self.m_model:getShowData()
	if self.m_hero_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("hero_loopscroll")
		loopscroll:SetActive(true)
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateHeroScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "choice_btn" then
					self:updateMsg("choice_item", {index = index}) 
				end
			end
		}
		self.m_hero_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_hero_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateHeroScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local hero_node_item = luaBehaviour:FindGameObject("hero_node_item")
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cell_data[2])
	CommonUIUtil:updateBigHeroElement(hero_node_item, nil, hero_cfg, false, true)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "choice_btn_text", "new_str_0056")
end

return M