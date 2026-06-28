local M = class("MazeStageRelicView",LikeOO.OOPopBase)

M.m_uiName = "MazeStage/MazeStageRelic"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0177")
	self:setTextByLanKey("tips_text", "new_str_0162")
	self:setTextByLanKey("title_text", "new_str_0182")
	self:setTextByLanKey("detail_text", "new_str_0183")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getHeirloomData()
	local count = #data
	self:setObjectVisible("info_node", count > 0)
	self:setObjectVisible("none_node", count == 0)
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
				self:updateMsg("cell_click", {data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local cfg = data.cfg
	CommonUIUtil:updateMazeStageRelicElement(cell_object, cfg)
end

return M