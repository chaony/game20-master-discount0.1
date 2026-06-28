local M = class("WorldMapAchievementEncounterView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapEvent/WorldMapAchievementEncounter"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0559")
	self:setTextByLanKey("title_reward_progress_text", "new_str_0560")
	self.m_score_box_reward = self:findGameObject("score_box_reward")
	self:refreshUI()
end

function M:refreshUI(keep_offset)
	self:updateEventGroupLoopScroll(keep_offset)
end

--[[
	创建列表
]]
function M:updateEventGroupLoopScroll(keep_offset)
	self.m_model.m_sel_cell_data = nil
	self.m_sel_cell_obj = nil
	self.m_sel_cell_index = nil
	local data = self.m_model:getQuestEncounterData()
	if self.m_model.m_select_group_data then
		for k,v in pairs(data) do
			if v.group_id == self.m_model.m_select_group_data.group_id then
				self.m_sel_cell_index = k
				break
			end
		end
	end
	self.m_model.m_select_group_data = nil
	if #data > 0 then
		self.m_sel_cell_index = self.m_sel_cell_index or 1
	end
	self:setObjectVisible("score_content_node", #data > 0)
	if self.m_sel_cell_index and data[self.m_sel_cell_index] then
		self:setSelectInfo(data[self.m_sel_cell_index], keep_offset)
	else
		self:updateEventLoopScroll({})
	end
	self:setObjectVisible("CommonTipsNode", #data == 0)
	self:setObjectVisible("event_info_panel", self.m_sel_cell_index ~= nil)
	if self.m_event_group_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("event_group_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateEventGroupScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if index ~= self.m_sel_cell_index then
					if self.m_sel_cell_obj then
						local luaBehaviour = UIUtil.findLuaBehaviour(self.m_sel_cell_obj)
						LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_group_select_img", false)
					end
					self.m_sel_cell_index = index
					self.m_sel_cell_obj = cell_object
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_sel_cell_obj)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_group_select_img", true)
					self:setSelectInfo(cell_data)
				end	
			end,
			ui_name = self.m_uiName,
		}
		self.m_event_group_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_event_group_loop_scroll_view:reloadData(data, keep_offset)
	end
end

--Scroll内cell的回调
function M:updateEventGroupScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if index == self.m_sel_cell_index then
		self.m_sel_cell_obj = cell_object
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_group_select_img", true)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"sell_group_select_img", false)
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "event_group_name_text", tostring(cell_data.group_cfg.name))
end

function M:setSelectInfo(data, keep_offset)
	self.m_model.m_select_group_data = data
	local cur_progress = data.cur_progress or 0
	local target_value = data.target_value or 100
	target_value = target_value <= 0 and 100 or target_value
	local reward_slider = self:findSlider("reward_slider")
	reward_slider.value = cur_progress/target_value
	self:setTextByLanKey("reward_progress_text", "new_str_0050", cur_progress, target_value)

	local status = data.status or 0
	LuaBehaviourUtil.setImg(self.m_luaBehaviour, "score_box_reward_img", status == 2 and "a_rw_xiangzi_kai" or "a_rw_xiangzi_weikai", "main_ui")
	local box_anim_obj = LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, "score_box_reward_anim", status == 1)
	if status == 1 then
		local luaBehaviour = UIUtil.findLuaBehaviour(box_anim_obj)
		luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
		luaBehaviour:SetParticleSystemRendererOrder(box_anim_obj, self.m_sortOrder + 1)
	end
	
	self:updateEventLoopScroll(data.items_data, keep_offset)
end

--[[
	创建列表
]]
function M:updateEventLoopScroll(data, keep_offset)
	local data = data or {}
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("event_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				local box_reward_img = luaBehaviour:FindGameObject("box_reward_img")
				self:updateMsg(click_name, {index = index , cell_data = cell_data, click_transform = box_reward_img.transform})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, keep_offset)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "event_name_text", tostring(cell_data.cfg.name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "event_des_text", tostring(cell_data.cfg.des))
	local status = cell_data.status or 0 -- 0：未完成，1：可领取，2：已领取

	local cur_progress = cell_data.cur_progress or 0
	local target_value = cell_data.target_value or 100
	target_value = target_value <= 0 and 100 or target_value
	LuaBehaviourUtil.setSliderValue(luaBehaviour, "progress_slider", cur_progress/target_value)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "event_progress_num_text", "new_str_0053", cur_progress, target_value)
	
	local event_cell_img = luaBehaviour:FindImage("event_cell_img")
	GameUtil:updateResourcesImg(event_cell_img, "Texture/world_map/" .. tostring(cell_data.cfg.pic))
	local box_reward_img = LuaBehaviourUtil.setImg(luaBehaviour, "box_reward_img", status == 2 and "a_rw_xiangzi_kai" or "a_rw_xiangzi_weikai", "main_ui")
	box_reward_img.gameObject:SetActive(status ~= 1)
	local box_anim_obj = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "BoxAnim", status == 1)
	if status == 1 then
		local luaBehaviour = UIUtil.findLuaBehaviour(box_anim_obj)
		luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
		luaBehaviour:SetParticleSystemRendererOrder(box_anim_obj, self.m_sortOrder + 1)
	end
end

return M