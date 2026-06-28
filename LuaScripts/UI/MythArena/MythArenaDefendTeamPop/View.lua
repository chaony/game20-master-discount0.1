local M = class("MythArenaDefendTeamPopView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaDefendTeamPop"
M.m_size_type = 2

function M:onEnter()
	if self.m_model.m_battle_array == true then
		self:setTextByLanKey("common_title_text", "peak_str_0047")
	else
		self:setTextByLanKey("common_title_text", "new_str_0275")
	end

	self:setTextByLanKey("order_btn_text", "new_str_0266")
	self:setTextByLanKey("cancle_btn_text", "new_str_0007")
	self:setTextByLanKey("ok_btn_text", "new_str_0267")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	local edit_status = self.m_model.m_edit_status
	self:setObjectVisible("order_btn", edit_status == 1 and self.m_model.m_show_order_btn_flag ~= false)
	self:setObjectVisible("edit_btn_node", edit_status ~= 1 and self.m_model.m_show_order_btn_flag ~= false)
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_sel_cell_index = nil
	local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			ui_name = self.m_uiName,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index = index , cell_data = cell_data})
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
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "upper_num_str_000" .. index)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_edit_btn_text", "new_str_0289")

	local edit_status = self.m_model.m_edit_status
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_edit_btn", edit_status == 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "exchange_btn", edit_status ~= 1 and self.m_model.m_select_cell_index ~= index)
	--LuaBehaviourUtil.setImg(luaBehaviour, "exchange_btn", self.m_model.m_edit_status == 2 and "a_jjc_tiaozheng" or "a_jjc_tiaozheng_1", "arena_ui")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "exchange_btn_text",  self.m_model.m_edit_status == 2 and "new_str_0884" or "new_str_0885")
	local team_node = luaBehaviour:FindGameObject("team_node")
	local team_heros_data = data.team_heros_data or {}
	for i = 1, 5 do
		local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. i)
		local item_data = team_heros_data[i]
		if item_data and _G.next(item_data) then
			GameUtil:updateItemElementByData(hero_node.gameObject,item_data,false,false)
		else
			local ui_element = GameUtil:updateItemElementNoData(hero_node)
			ui_element.add_img.gameObject:SetActive(false)
		end
	end
end

return M