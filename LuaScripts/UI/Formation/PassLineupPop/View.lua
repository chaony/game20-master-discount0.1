local M = class("PassLineupPopView",LikeOO.OOPopBase)

M.m_uiName = "Formation/PassLineupPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0541")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
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
	if next(data) == nil then
		self:setObjectVisible("CommonTipsNode", true)
	else
		self:setObjectVisible("CommonTipsNode", false)	
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data) -- 更新方法
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local btn_data = table.copy(cell_data)
				btn_data.click_name = click_name
				self:updateMsg("open", btn_data)
			end,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local LuaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if LuaBehaviour then
		local head_obj = LuaBehaviour:FindGameObject("HeadNode")
		if head_obj then
			GameUtil:setUserAvatar(head_obj, cell_data, nil, nil,{show_flag = true, scale = 1})
		end
		local com = Language:getTextByKey("friend_str_0041")..cell_data.combat
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_combat", com)
		LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_name", cell_data.name)
		for i = 1, 3 do
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"check_btn" .. i, i <= self.m_model.m_team_nums and i > 1)
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"check_btn" .. i, i <= self.m_model.m_team_nums and i > 1)
			LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "check_name" .. i, "num_str_000" .. i)
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"check_name" .. i, false)
			if self.m_model.m_team_nums > 1 then
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"check_name" .. i, i <= self.m_model.m_team_nums)
			end
		end
	end
end


return M