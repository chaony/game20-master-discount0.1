local M = class("TopPlayerListView",LikeOO.OOPopBase)

M.m_uiName = "Rank/TopPlayerList"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0082")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getRankData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local top_three_flag = index < 4
	UIUtil.setObjectVisible(transform, top_three_flag, "top_three_rank_img")
	UIUtil.setObjectVisible(transform, not top_three_flag, "rank_text")
	local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[index]
	if top_three_item then
		LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank2, top_three_item.atlas)
	end
	local user = data.user or {}
	local rank = data.rank or 0
	local name = user.name
	UIUtil.setText(transform, tostring(rank), "rank_text")
	UIUtil.setTextByLanKey(transform, "level_text", "new_str_0075", user.level or 1)
	if name == nil or name == "" then
		UIUtil.setText(transform, tostring(user.uid), "name_text")
	else
		UIUtil.setText(transform, tostring(name), "name_text")
	end
	local time = data.time or 0
	local tm = TimeUtil.gmTime(time)
	local time_str = string.format("%d-%02d-%02d %02d:%02d:%02d", tm.year, tm.month, tm.day, tm.hour, tm.min, tm.sec)
	UIUtil.setText(transform, time_str, "time_text")
	local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
end

return M