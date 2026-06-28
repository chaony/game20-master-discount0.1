local M = class("GuJianQiTanMazeRelicSelectView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanMazeRelicSelect"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("title_top_text", "new_str_0633")
	self:setTextByLanKey("title_text", "new_str_0632")
	self:setTextByLanKey("title_bottom_text", "new_str_0631")
	--self:setObjectVisible("tips_text", self.m_model.m_show_tips)
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
	self.m_guide_nodes = {}
	local data = self.m_model:getHeirloomData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 3,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
				self.m_guide_nodes[index] = cell_object
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if self.m_select_cell then
					 self.m_select_cell.transform.localScale = Vector3(1,1,1)
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_cell)
					local select_btn = luaBehaviour:FindGameObject("select_btn")
					select_btn:SetActive(false)
					local light_img = luaBehaviour:FindGameObject("light_img")
					light_img:SetActive(false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MazeStage_yiwu_01", false)
					self.m_select_cell = nil
				end
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				local select_btn = luaBehaviour:FindGameObject("select_btn")
				select_btn:SetActive(true)
				local light_img = luaBehaviour:FindGameObject("light_img")
				light_img:SetActive(true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MazeStage_yiwu_01", true)
				 --cell_object.transform.localScale = Vector3(1.1,1.1,1)
				cell_object.transform:SetSiblingIndex(cell_object.transform.parent.childCount - 1) -- 修改层级关系
				self.m_select_cell = cell_object
				if self.m_model then
					self.m_model.m_select_index = index
				end
				self:updateMsg(click_name)
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if self.m_model.m_select_index == index then
		self.m_select_cell = cell_object
		 --cell_object.transform.localScale = Vector3(1.1,1.1,1)
		cell_object.transform:SetSiblingIndex(cell_object.transform.parent.childCount - 1)
	end
	local select_btn = luaBehaviour:FindGameObject("select_btn")
	select_btn:SetActive(self.m_model.m_select_index == index)
	local light_img = luaBehaviour:FindGameObject("light_img")
	light_img:SetActive(self.m_model.m_select_index == index)
	local cfg = data.cfg
	local attr_icon = luaBehaviour:FindGameObject("attr_icon")
	attr_icon:SetActive(true)
	-- local attr_icon_bg = luaBehaviour:FindGameObject("attr_icon_bg")
	-- attr_icon_bg:SetActive(true)
	CommonUIUtil:updateMazeStageRelicElement(cell_object, cfg)
end

return M