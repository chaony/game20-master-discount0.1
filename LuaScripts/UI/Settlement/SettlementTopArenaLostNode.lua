--- 高阶竞技场结算 失败

local M = class("SettlementArenaHigherLostNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementTopArenaLostNode"

function M:onEnter()
    self:setTextByLanKey("vs_title_text", "new_str_0296")
	self:setTextByLanKey("tips_text", "new_str_0905")
    self:refreshUI()
end

function M:refreshUI()
	local data = self.m_model.m_data
	local cur_rank = data.rank or 0
	local pre_rank = data.pre_rank or 0
	local dif_rank = pre_rank - cur_rank
	self:setTextByLanKey("left_rank_text", tostring(pre_rank))
	local right_rank_text = self:setTextByLanKey("right_rank_text", tostring(cur_rank))
	right_rank_text.color = (pre_rank <= 0 or dif_rank >= 0) and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_11
	local arrow_img = self:setImg((pre_rank <= 0 or dif_rank >= 0) and "a_zdjs_jiantou" or "a_zdjs_jiantou_1", "battle_ui", "arrow_img")
	
	local left_cfg = ConfigManager:getHighArenaCfgByRank(self.m_model.m_data.rank or 0)
	local right_cfg = ConfigManager:getHighArenaCfgByRank(self.m_model.m_data.defender_rank or 0)
	local left_num, right_num = self.m_model:getVSNum()
	self:setTextByLanKey("total_vs_text", "new_str_0904", tostring(left_num), tostring(right_num))
	local cur_score = data.score or 0
	local pre_score = data.pre_score or 0
	self:setTextByLanKey("score_text", tostring(cur_score))
	local dif_score = cur_score - pre_score
	local dif_score_str = dif_score
	if dif_score > 0 then
		dif_score_str = "+" .. tostring(dif_score)
	end

	local player_left_node = self:findGameObject("player_left_node")
	local player_right_node = self:findGameObject("player_right_node")
	local left_user = self.m_model:getUserInfoBySort(1)
	local right_user = self.m_model:getUserInfoBySort(2)
	self:setPlayerInfo(player_left_node, data.score, data.pre_score, left_user, 1)
	self:setPlayerInfo(player_right_node, data.defend_score, data.defend_pre_score, right_user)
	
	local luaBehaviour = self.m_luaBehaviour
	local left_head_node = luaBehaviour:FindGameObject("left_head_node")
	GameUtil:setUserAvatar(left_head_node, left_user, nil, nil, {show_flag = true, scale = 1})
	local right_head_node = luaBehaviour:FindGameObject("right_head_node")
	GameUtil:setUserAvatar(right_head_node, right_user, nil, nil, {show_flag = true, scale = 1})
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name_text", tostring(left_user.name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name_text", tostring(right_user.name))
	
    self:updateLoopScroll()
end

function M:setPlayerInfo(obj, cur_score, pre_score, user, direction)
	if user then
		cur_score = cur_score or 0
		pre_score = pre_score or 0
		local direction_str = direction == 1 and "left_" or "right_"
		self:setTextByLanKey(direction_str .. "name_text", tostring(user.name))
		self:setTextByLanKey(direction_str .. "score_title_text", "new_str_0249")
		self:setTextByLanKey(direction_str .. "score_text", tostring(cur_score))
		local dif_score = cur_score - pre_score
		local dif_score_str = dif_score
		if dif_score > 0 then
			dif_score_str = "+" .. tostring(dif_score)
		end
		local add_score_text = self:setTextByLanKey(direction_str .. "add_score_text", "(" .. dif_score_str .. ")")
		add_score_text.color = dif_score >= 0 and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_11
	end
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getBattleRounds()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end
local team_name = {"arena_str_0012", "arena_str_0013", "arena_str_0027"}
--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
	local round_data = data.round_data or {}
	local result = round_data.result or 0
	local round = round_data.round or 0
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "new_str_0295", index)
	local team_index_str = team_name[index]
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_player_team_num_text", team_index_str)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_player_team_num_text", team_index_str)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_team_text", "new_str_0890")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_team_text", "new_str_0891")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "new_str_0295", round)
	local lan_atlas = ResourceUtil:getLanAtlas()
	LuaBehaviourUtil.setImg(luaBehaviour,"left_result",result == 1 and "a_sjjs_shengli" or "a_sjjs_shibai", lan_atlas)
	LuaBehaviourUtil.setImg(luaBehaviour,"right_result",result == 1 and "a_sjjs_shibai" or "a_sjjs_shengli", lan_atlas)
	local left_result_bg = LuaBehaviourUtil.setImg(luaBehaviour,"left_result_bg",result == 1 and "a_bh_shenglidi" or "a_bh_shibaidi", "arena_ui")
	local right_result_bg = LuaBehaviourUtil.setImg(luaBehaviour,"right_result_bg",result == 1 and "a_bh_shibaidi" or "a_bh_shenglidi", "arena_ui")
	UIUtil.setLocalScale(left_result_bg.transform, result == 1 and 1 or -1)
	UIUtil.setLocalScale(right_result_bg.transform, result == 1 and 1 or -1)

end

return M