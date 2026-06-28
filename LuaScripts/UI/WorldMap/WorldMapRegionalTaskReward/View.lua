local M = class("WorldMapRegionalTaskRewardView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapRegionalTaskReward"
M.m_size_type = 2

function M:onEnter()
	if self.m_model.m_bg_image_name and self.m_model.m_bg_image_name ~= "" then
		local bg_image = self:findGameObject("bg_image")
		GameUtil:updateResourcesImg(bg_image, "Texture/map_plot/" .. tostring(self.m_model.m_bg_image_name))
	end
	local title_text_name = self.m_model:getTitleTextName()
	self:setTextByLanKey("close_title_text", Language:getTextByKey(title_text_name) .. Language:getTextByKey("new_str_0525"))
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
	LuaBehaviourUtil.setSliderValue(luaBehaviour, "progress_slider", cpd/100)
	local status = cell_data.data.status or 0 -- 0：未完成，1：可领取，2：已领取
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock_text", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", status == 2)
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