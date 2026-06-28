local M = class("ShiguangDetailView",LikeOO.OOPopBase)

M.m_uiName = "Shiguang/ShiguangDetail"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("maze_stage_detail_title_text", self.m_model.m_cell_data.text1 or "???")
	self:setTextByLanKey("tips_text", self.m_model.m_cell_data.text2 or "???")
	self:setTextByLanKey("reward_title_text", "new_str_0110")
	self:setTextByLanKey("ok_btn_text", "new_str_0166")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
    -- 奖励
	-- local drop = self.m_model:getShowRewardData()
	-- local reward_node = self:findGameObject("reward_node")
	-- GameUtil:createRewards(reward_node.transform, drop, true, true, nil, 0.65)
	self:setTextByLanKey("combat_num_text", tostring(self.m_model.m_total_combat))
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowHeroData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				local item_node = luaBehaviour:FindGameObject("item_node")
				local ui_element = CommonUIUtil:updateHeroElementByData(item_node, cell_data, nil , true)
				CommonUIUtil:updateHeroLvByData(item_node, data.hero_data, true)
				-- local blood_slider = luaBehaviour:FindSlider("blood_slider")
				-- local anger_slider = luaBehaviour:FindSlider("anger_slider")
				local dyns = data.dyns or {}
				local hp_pct = dyns.hp_pct or 10000 -- 血量万分比
				local mp_pct = dyns.mp_pct or 0 -- 怒气万分比
				-- blood_slider.value = hp_pct/10000
				-- anger_slider.value = mp_pct/10000
				CommonUIUtil:updateHeroHpSlider(item_node, hp_pct/10000, mp_pct/10000)
				local gray_img = luaBehaviour:FindImage("gray_img")
				if hp_pct <= 0 then
					ui_element.item_img.material = gray_img.material
					ui_element.quality_img.material = gray_img.material
				else
					ui_element.item_img.material = nil
					ui_element.quality_img.material = nil
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index = index, cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

return M