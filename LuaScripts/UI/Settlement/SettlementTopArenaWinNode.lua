---@class SettlementArenaHigherWinNode:OOUIbase
---@field m_model SettlementModel
--- 高阶竞技场结算 成功
local M = class("SettlementArenaHigherWinNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementTopArenaWinNode"

function M:onEnter()
	self:setTextByLanKey("vs_title_text", "new_str_0296")
	self:setTextByLanKey("tips_text", "new_str_0905")
    -- self.win_spine = self:findGameObject("win_sp")
    -- self.animation = self.win_spine:GetComponent("SkeletonGraphic")
    -- self:addSpineComplete(self.animation.AnimationState,handler(self,self.setAnimation))
	local show_coin_tab = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HIGH_ARENA_COIN, 0, 0})
	self:setImg(show_coin_tab.icon_name, show_coin_tab.atlas_name, "high_arena_coin_img")
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
	if self.m_model.m_quick_pass then
		left_num = left_num
		right_num = 0
	end
	self:setTextByLanKey("total_vs_text", "new_str_0904", tostring(left_num), tostring(right_num))
    self:setTextByLanKey("arena_score_text_label", "new_str_0441")
    self:setTextByLanKey("arena_coin_text", "new_str_0300", left_cfg.high_coin or 0)
	self:setTextByLanKey("arena_score_text", "new_str_0301", left_cfg.high_point or 0)
	--local left_segment_node = self:findGameObject("left_segment_node")
	--local right_segment_node = self:findGameObject("right_segment_node")
	--CommonUIUtil:setSegmentInfo(left_segment_node, left_cfg, true)
	--CommonUIUtil:setSegmentInfo(right_segment_node, right_cfg, true)

	local luaBehaviour = self.m_luaBehaviour
	local left_user = self.m_model:getUserInfoBySort(1)
	local left_head_node = luaBehaviour:FindGameObject("left_head_node")
	GameUtil:setUserAvatar(left_head_node, left_user, nil, nil, {show_flag = true, scale = 1})
	local right_user = self.m_model:getUserInfoBySort(2)
	local right_head_node = luaBehaviour:FindGameObject("right_head_node")
	GameUtil:setUserAvatar(right_head_node, right_user, nil, nil, {show_flag = true, scale = 1})
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name_text", tostring(left_user.name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name_text", tostring(right_user.name))
	local player_left_node = self:findGameObject("player_left_node")
	local player_right_node = self:findGameObject("player_right_node")
	self:setPlayerInfo(player_left_node, data.score, data.pre_score, left_user, 1)
	self:setPlayerInfo(player_right_node, data.defend_score, data.defend_pre_score, right_user)
    self:updateLoopScroll()
	self:updateTaskLoopScroll()
end

function M:setAnimation()
	if self.animation.AnimationState:ToString() == "animation_1" then
		self.animation.AnimationState:SetAnimation(0, "animation_2", true)
	end
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
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_log_btn", self.m_model.m_quick_pass ~= true)

end

--[[
    任务列表
]]
function M:updateTaskLoopScroll()
	--竞技场胜场任务
	local data = UserDataManager:getBattleOverQuestsByTargetType({[7] = 1, [8] = 1, [18] = 1})
	if self.m_model.m_data.week_win_times and self.m_model:weekWinNum() <= self.m_model:weekWinMaxNum() then
		local param_data = {
			id = 0,
			str = "settlement_str_0003",
			num = self.m_model:weekWinNum(),
			max_num = self.m_model:weekWinMaxNum(),
		}
		table.insert( data, param_data)
	end

	if self.m_task_scroll_view == nil then
		local loopscroll = self:findGameObject("task_loopscroll")
		local params ={
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self:updateTaskCell(cell_obj, cell_data)
			end,
		}
		self.m_task_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_task_scroll_view:reloadData(data)
	end
end

function M:updateTaskCell(obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if data.id > 0 then
		local cfg = data.cfg
		local cur_progress = data.cur_progress
		local target_value = data.target_value
		local status = data.status
		local finish_flag = data.status == 2
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", finish_flag)
		local num_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num_text", tostring(cur_progress) .. "/" .. tostring(target_value))
		local des_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", Language:getTextByKey(cfg.name) .. "(" .. tostring(cur_progress) .. "/" .. tostring(target_value) .. ")")
		num_text.color = finish_flag and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_2
		des_text.color = finish_flag and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_2
		LuaBehaviourUtil.setImg(luaBehaviour, "finish_img", finish_flag and "a_zdjs_wanchengbiaoji" or "a_zdjs_weiwancheng", "battle_ui")
	else
		if data.num > data.max_num then
			data.num = data.max_num
		end
		local des_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", Language:getTextByKey(data.str, data.num, data.max_num))
		des_text.color = data.num>= data.max_num and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_2
	end
end

return M