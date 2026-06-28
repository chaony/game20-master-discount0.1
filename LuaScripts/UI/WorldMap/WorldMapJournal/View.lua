local M = class("WorldMapJournalView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapJournal"
M.m_size_type = 2

function M:onEnter()
	self.task_table = ConfigManager:getCfgByName("regional_task")
	self.npc_table = ConfigManager:getCfgByName("regional_npc")
	self.map_table = ConfigManager:getCfgByName("regional_map")

	self:refreshUI()
	if self.m_model.show_gift == true then
		self:showGift()
	end
end

function M:refreshUI()
	self:updateEventLoopScroll()

end

function M:updateEventLoopScroll()
	local data = self.m_model:getTravelLog()

	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local map_id = self.task_table[cell_data.task_id].chapter
				local motherMapId = self.m_model:getMotherMapId(map_id)
				self.m_control:closeView()
				LikeOO.Map2DControl:openMap2D(motherMapId)
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)

	if cell_data.type == 1 then
		local map_data = self.map_table[cell_data.scene_id]
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "event_text", map_data.text)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "click_btn", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "done_img", true)
		LuaBehaviourUtil.setImg(luaBehaviour, "item_img", map_data.icon, "item_icon")
		GameUtil:setLanImgText(luaBehaviour:FindRectTransform("done_img"), "a_jh_chuanshuo_rizhi_lingqu")
	elseif cell_data.type == 2 then
		local task_data = self.task_table[cell_data.task_id]
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "event_text", task_data.event_guide)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "click_btn", true)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "new_str_0970")
		LuaBehaviourUtil.setImg(luaBehaviour, "item_img", "a_jh_chuanshuo_rizhi_wenhao", "hero_head_ui")
		local done = self.m_model:checkTaskDone(cell_data.task_id)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "done_img", done)
		GameUtil:setLanImgText(luaBehaviour:FindRectTransform("done_img"), "a_jh_chuanshuo_rizhi_wancheng")
	end
end

function M:showGift()
	local data = self.m_model:getTravelLog()
	local gifts = {}
	for k,v in pairs(data) do
		if v.type == 1 then
			for k2,v2 in pairs(v.gifts) do
				table.insert(gifts, v2)
			end
		end
	end
	if #gifts > 0 then
		RewardUtil:rewardTipsByRewards( gifts, nil)
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M