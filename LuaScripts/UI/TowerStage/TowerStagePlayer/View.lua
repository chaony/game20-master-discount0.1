local M = class("TowerStagePlayerView",LikeOO.OOPopBase)

M.m_uiName = "TowerStage/TowerStagePlayer"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("title_text", "new_str_0112")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getPlayerData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("item_click", {index = index})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local data = cell_data
	local name = data.name
	if name == nil or name == "" then
		UIUtil.setText(transform, tostring(data.uid), "name_text")
	else
		UIUtil.setText(transform, tostring(name), "name_text")
	end
	UIUtil.setTextByLanKey(transform, "level_text", "new_str_0075", data.level or 1)
	local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, data, nil, nil, {show_flag = true, scale = 1})
end

return M