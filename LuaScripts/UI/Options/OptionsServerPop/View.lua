local M = class("OptionsHeadPopView",LikeOO.OOPopBase)

M.m_uiName = "Options/OptionsServerPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {"recommend_toggle","all_toggle",}
function M:onEnter()	
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v)
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("tab_btn",data) 
			end 
		end, i, self.m_uiName)
	end

	self:refreshUI()
end

function M:refreshUI()
	self:findGameObject("recommend_scroll"):SetActive(self.m_model.m_tab == 1)
	self:findGameObject("server_team_scroll"):SetActive(self.m_model.m_tab == 2)
	self:findGameObject("server_scroll"):SetActive(self.m_model.m_tab == 2)	
	if self.m_model.m_tab == 1 then
		self:updateRecommendList()
	else
		self:updateTeamList()
		self:updateServerList()
	end
end

function M:updateRecommendList()
	local data = self.m_model.m_recommend
	if self.m_recommend_scroll == nil then
		local list_scroll = self:findGameObject("recommend_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:serverHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("click_head", cell_data)
			end
		}
		self.m_recommend_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_recommend_scroll:reloadData(data,true)
	end
end

function M:updateTeamList()
	local data = self.m_model.m_team
	if self.m_team_scroll == nil then
		local list_scroll = self:findGameObject("server_team_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:teamHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("click_border", cell_data)
			end
		}
		self.m_team_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_team_scroll:reloadData(data,true)
	end
end

function M:updateServerList()
	local data = self.m_model.m_server
	if self.m_server_scroll == nil then
		local list_scroll = self:findGameObject("server_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:serverHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("click_border", cell_data)
			end
		}
		self.m_server_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_server_scroll:reloadData(data,true)
	end
end

function M:teamHandle(obj, id)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")

end

function M:serverHandle(obj, id)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")

end

return M