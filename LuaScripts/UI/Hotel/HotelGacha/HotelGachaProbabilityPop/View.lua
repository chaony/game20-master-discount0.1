local M = class("HotelGachaProbabilityPopView",LikeOO.OOPopBase)

M.m_uiName = "Hotel/HotelGachaProbabilityPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "predestined_str_010")
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
	local data, allWeight = self.m_model:getListData()
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 7,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				self:updateData(cell_object, cell_data, allWeight)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("select_hero", cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, true)
	end
end

function M:updateData(obj, data, allWeight)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local item = luaBehaviour:FindGameObject("ItemNode")
	if #data.reward > 0 then
		local reward = RewardUtil:getProcessRewardData(data.reward[1])
		GameUtil:updateItemElementByData(item,reward, true, true)
		local l = UIUtil.findLuaBehaviour(item)
		LuaBehaviourUtil.setObjectVisible(l, "count_text_bg_img",reward.data_num > 1)
		LuaBehaviourUtil.setObjectVisible(l, "count_text",reward.data_num > 1)
	else
		--GameUtil:updateItemElement(item,{RewardUtil.REWARD_TYPE_KEYS.HEROS, self.m_model.m_arm_hero, 1}, false, true)
	end
	local level = data.room_level
	if level > self.m_model.m_room_lv then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock",true)
		local lock_text = self.m_model.m_cfg.name .. "\n" .. Language:getTextByKey("hotel_text_043", level)
		LuaBehaviourUtil.setText(luaBehaviour,"lock_text", lock_text)
		LuaBehaviourUtil.setText(luaBehaviour,"probability_text", "")
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock",false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Predestined_Glow_001", data.show_effect == 1)
		local percent = self.m_model:getPercent(data, allWeight)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"probability_text", string.format("%.2f", percent * 100) .. "%")
	end
end

return M