local M = class("TowerStageDetailView",LikeOO.OOPopBase)

M.m_uiName = "TowerStage/TowerStageDetail"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0111")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self:setTextByLanKey("reward_text", "new_str_0110")
    -- 奖励
	local rewards = self.m_model:getStageRewards()
	local reward_node = self:findGameObject("reward_node")
    GameUtil:createRewards(reward_node.transform, rewards, true, true)
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
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "statistics_btn" then
					self:updateMsg("look_statistics_data", {index = index, cell_data = cell_data})
				else
					self:updateMsg("item_click", {index = index, cell_data = cell_data})
				end
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
	local name = data.name
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", "new_str_0075", data.level or 1)
	if name == nil or name == "" then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(data.uid))
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(name))
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", tostring(data.full_combat))
	local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, data,nil,nil,{show_flag = true, scale = 1})
	local relationship = data.relationship or 0
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "relationship_text", relationship ~= 0)
	local relationship_lan = ""
	if relationship == 1 then
		relationship_lan = "new_str_0108"
	elseif relationship == 2 then
		relationship_lan = "new_str_0109"
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "relationship_text", relationship_lan)
end

return M