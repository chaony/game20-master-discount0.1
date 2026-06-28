local M = class("WorldMapAreaRewardView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapAreaReward"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("close_title_text", "new_str_0524")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getRegionalTaskDoneShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			one_line_count = 3,
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				local box_img = luaBehaviour:FindGameObject("box_img")
				self:updateMsg(click_name, {index = index , cell_data = cell_data, click_transform = box_img.transform})
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
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.cfg.name)
	local cpd = cell_data.data.cpd or 0
	local progress_slider = LuaBehaviourUtil.setSliderValue(luaBehaviour, "progress_slider", cpd/100)
	local status = cell_data.data.status or 0 -- 0：未完成，1：可领取，2：已领取
	progress_slider.gameObject:SetActive(cell_data.open_flag == true)
	local unlock_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "unlock_text", cell_data.tips_str)
	unlock_text.gameObject:SetActive(cell_data.open_flag ~= true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", cell_data.open_flag ~= true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", status == 2)
	LuaBehaviourUtil.setImg(luaBehaviour, "cell_btn", cell_data.open_flag and "a_map_jq_xiaobg_s" or "a_map_jq_xiaobg_n", "main_ui")
	local btn = luaBehaviour:FindButton("cell_btn")
	btn.interactable = cell_data.open_flag == true
	local reward_box_img = LuaBehaviourUtil.setImg(luaBehaviour, "reward_box_img", status == 2 and "a_rw_xiangzi_kai" or "a_rw_xiangzi_weikai", "main_ui")
	reward_box_img.gameObject:SetActive(status ~= 1)
	local box_anim_obj = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "BoxAnim", status == 1)
	if status == 1 then
		local luaBehaviour = UIUtil.findLuaBehaviour(box_anim_obj)
		luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
		luaBehaviour:SetParticleSystemRendererOrder(box_anim_obj, self.m_sortOrder + 1)
	end
end

return M