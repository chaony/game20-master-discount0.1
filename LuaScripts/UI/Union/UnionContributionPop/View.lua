local M = class("UnionContributionPopView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionContributionPop"
M.m_size_type = 2

function M:onEnter()
	self:setText("common_title_text", Language:getTextByKey("union_str_0011"))
	--self:setText("cost_text", Language:getTextByKey("union_str_0012"))
	self:setText("get_text", Language:getTextByKey("union_str_0013"))
	self:setTextByLanKey("tips_text", "union_str_1066")
	self:refreshUI()
end

function M:refreshUI()
	--local have_times = self.m_model.m_max_times - self.m_model.m_guild_donate_times
	--self:setText("have_times_text", Language:getTextByKey("union_str_0014") .. have_times)
	--self:setText("times_text", tostring(self.m_model.m_times))
	--local cost, rewards = self.m_model:getCost()
	--self:setText("cost_value_text", tostring(cost))
	self:updateListScroll()
	--self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll(data)
	local contribution_cfg = ConfigManager:getCfgByName("guild_contribution")
	local data = contribution_cfg[self.m_model.m_select_id].reward
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("gain_panel_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local reward_data = RewardUtil:getProcessRewardData(data)
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"gain_value_text",reward_data.data_num)
				LuaBehaviourUtil.setImg(luaBehaviour,"gain_icon", reward_data.icon_name, reward_data.atlas_name or "item_icon")
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				--self:updateMsg(click_name, cell_data)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				local gain_icon = luaBehaviour:FindGameObject("gain_icon")
				GameUtil:lookInfoTips(self.m_control, {click_transform = gain_icon.transform, data = cell_data, top = true})
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateListScroll()
	local contribution_cfg = ConfigManager:getCfgByName("guild_contribution")
	if self.m_list_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")
		local params = {
			show_data = contribution_cfg,
			one_line_count = 3,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local reward_data = RewardUtil:getProcessRewardData(data.cost[1])
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"cell_btn_text",reward_data.data_num)
				LuaBehaviourUtil.setImg(luaBehaviour,"cost_icon", reward_data.icon_name, reward_data.atlas_name or "item_icon")
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"select_img",self.m_model.m_select_id == index)
				
				local rewards = cell_data.reward
				for i,v in ipairs(rewards or {}) do
					local reward_data = RewardUtil:getProcessRewardData(v)
					local rewards_node = luaBehaviour:FindGameObject("reward_" .. i)
					if rewards_node then
						local reward_luaBehaviour = UIUtil.findLuaBehaviour(rewards_node.transform)
						LuaBehaviourUtil.setTextByLanKey(reward_luaBehaviour,"gain_value_text",reward_data.data_num)
						LuaBehaviourUtil.setImg(reward_luaBehaviour,"gain_icon", reward_data.icon_name, reward_data.atlas_name or "item_icon")
					end
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, index)
			end,
			ui_name = self.m_uiName
		}
		self.m_list_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll_view:reloadData(contribution_cfg)
	end
end

return M