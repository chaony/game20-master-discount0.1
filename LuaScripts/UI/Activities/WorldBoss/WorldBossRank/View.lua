local M = class("WorldBossRankView",LikeOO.OOPopBase)

M.m_uiName = "Activities/WorldBoss/WorldBossRankPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "world_boss_str_0024")
	self:setTextByLanKey("rank_label_text", "new_str_0374")
	self:setTextByLanKey("player_label_text", "new_str_0372")
	self:setTextByLanKey("score_label_text", "world_boss_str_0026")
	self:setTextByLanKey("own_rank_title_text", "new_str_0077")
	self:setTextByLanKey("self_rank_node", "world_boss_str_0028")
	self.self_rank_node = self:findGameObject("self_rank_node")
	self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_day == 1 then
		self:setTextByLanKey("change_btn_text", "world_boss_str_0014")
	else
		self:setTextByLanKey("change_btn_text", "world_boss_str_0013")
	end
	local self_rank_node = self:findGameObject("self_rank_node")
	local self_data = self.m_model:getSelfRankData()
	self:updateScrollViewCell(-1, self_rank_node, self_data)
	self:updateLoopScroll()
end

function M:updateLoopScroll()
	local data = self.m_model:getRankData()
	self:setObjectVisible("CommonTipsNode", #data <= 0)
	if self.m_loop_scroll_view == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
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

function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local user = data.user or {}
    local rank = data.rank or 0
    local name = user.name
	local top_three_flag = rank > 0 and rank < 4
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
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", tostring(rank))
	end
	if name == nil or name == "" then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", "new_str_0141")
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(name))
	end
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
	GameUtil:setUserAvatar(HeadNode, user, nil, nil,{show_flag = true, scale = 1})
	local score = GameUtil:formatValueToString(cell_data.score or 0)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text",  score)
	local battle_id = cell_data.battle_id or 0
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "log_btn", battle_id > 0)
end
return M