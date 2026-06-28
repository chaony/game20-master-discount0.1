local M = class("ArenaHigherScoreExplainView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaHigher/ArenaHigherScoreExplain"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("title_text", "new_str_0272")
	self:setTextByLanKey("tips_text", "new_str_0285")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local cfg = data.cfg
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	-- LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "new_str_0273", index)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", cfg.division_name)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_add_text" ,"new_str_0293", cfg.high_point)
	local segment_node = luaBehaviour:FindGameObject("segment_node")
	CommonUIUtil:setSegmentInfo(segment_node, cfg)
end

return M