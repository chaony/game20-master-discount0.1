local M = class("GuJianQiTanMazeHeroSelectView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanMazeHeroSelect"
M.m_size_type = 2

function M:onEnter()
	local cell_type = self.m_model.m_cell_data.type
	local maze_cell_type = ConfigManager:getCfgByName("maze_cell_type")
	local maze_cell_type_item = maze_cell_type[cell_type] or {}
	local explain = maze_cell_type_item.explain or "???"
	self:setTextByLanKey("tips_text", explain)
	self:setTextByLanKey("common_title_text", maze_cell_type_item.name or "???")
	self:setTextByLanKey("ok_btn_text", "new_str_0163")
	self:setObjectVisible("ok_btn", self.m_model.m_open_flag == true)
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_select_cell = nil
	self.m_model.m_select_index = -1
	local data = self.m_model:getShowHeroData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				local item_node = luaBehaviour:FindGameObject("HeroNode")
				local ui_element = CommonUIUtil:updateHeroElementByData(item_node, cell_data)
				CommonUIUtil:updateHeroLvByData(item_node, data.hero_data)
				local hero_data = self.m_model:getHeroDataByid(data.hero_id)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", tostring(hero_data.combat))
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", self.m_model.m_select_index == index)
				if self.m_model.m_select_index == index then
					self.m_select_cell = cell_object
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "click_btn" then
					--if self.m_model.m_cell_data.status == 0 then
					--	return
					--end
					if self.m_select_cell then
						local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_cell)
						local duigou_img = luaBehaviour:FindGameObject("light_img")
						duigou_img:SetActive(false)
						self.m_select_cell = nil
					end
					if self.m_model.m_select_index ~= index then
						local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
						local duigou_img = luaBehaviour:FindGameObject("light_img")
						self.m_model.m_select_index = index
						duigou_img:SetActive(true)
						self.m_select_cell = cell_object
					else
						self.m_model.m_select_index = -1
					end
				else
					self:updateMsg(click_name, {index = index, cell_data = cell_data})
				end
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

return M