local M = class("HeroBossRewardView",LikeOO.OOPopBase)

M.m_uiName = "Activities/HeroBoss/HeroBossReward"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "hero_boss_text_016")
	self:setTextByLanKey("togglebtn_text_1", "hero_boss_text_006")
	self:setTextByLanKey("togglebtn_text_2", "hero_boss_text_005")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	for i = 1, 2 do
		local tog_btn = self:findToggle("togglebtn_" .. i)
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, i) end, nil, self.m_uiName)
	end
	self:refreshUI()
end

function M:refreshUI()
	self:switchTabUpdate(true, 2)
end

function M:switchTabUpdate(is_on, update_key)
	if is_on == false then
		return
	end
	for i = 1, 2 do
		local tab_text = self:findText("togglebtn_text_" .. i)
		tab_text.color = update_key == i and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24
	end
	local cfg = ConfigManager:getCfgByName("hero_boss_rank")
	local rewards = cfg[update_key]
	self:updateLoopScroll(rewards)
end

function M:updateLoopScroll(rewards)
	local data = rewards
	self:setObjectVisible("CommonTipsNode", #data <= 0)
	if self.m_loop_scroll_view == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			--click_func = function(index, cell_object, cell_data, click_object, click_name)
            --    self:updateMsg(click_name, {id = index , cell_data = cell_data})
			--end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, false)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
    local rank = cell_data.rank[1] or 0
	local rank2 = cell_data.rank[2] or 0
	local top_three_flag = rank >= 1 and rank <= 3
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", not top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", not top_three_flag)
	local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[rank]
	if top_three_item then
		LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
	end
	if rank < 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0076")
	else
		if rank == rank2 then
			LuaBehaviourUtil.setText(luaBehaviour, "rank_text", tostring(rank))
		else
			LuaBehaviourUtil.setText(luaBehaviour, "rank_text", rank .. "-" .. rank2)
		end
	end
	local reward = cell_data.reward or {}
	local reward_node = luaBehaviour:FindRectTransform("reward_node")
	GameUtil:createRewards(reward_node, reward, true, true, nil, 1)
end

return M