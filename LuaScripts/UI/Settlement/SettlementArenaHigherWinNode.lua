--- 高阶竞技场结算 成功
local M = class("SettlementArenaHigherWinNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementArenaHigherWinNode"

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
	
	local left_cfg ={} 
	local right_cfg ={}
	local left_segment_node = self:findGameObject("left_segment_node")
	local right_segment_node = self:findGameObject("right_segment_node")
	
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD then
		left_cfg = ConfigManager:getHuaShanCfgByRankAndVsn(self.m_model.m_data.rank or 0, self.m_model.version)
		right_cfg = ConfigManager:getHuaShanCfgByRankAndVsn(self.m_model.m_data.defender_rank or 0, self.m_model.version)
		CommonUIUtil:setSegmentInfo(left_segment_node, left_cfg, true, "pub_ui")
		CommonUIUtil:setSegmentInfo(right_segment_node, right_cfg, true, "pub_ui")
		local luaBehaviour1 = UIUtil.findLuaBehaviour(left_segment_node)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour1, "segment_rank_text", false)
		local luaBehaviour2 = UIUtil.findLuaBehaviour(right_segment_node)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour2, "segment_rank_text", false)
	else
		left_cfg =ConfigManager:getHighArenaCfgByRank(self.m_model.m_data.rank or 0)
		right_cfg =ConfigManager:getHighArenaCfgByRank(self.m_model.m_data.defender_rank or 0)
		CommonUIUtil:setSegmentInfo(left_segment_node, left_cfg, true)
		CommonUIUtil:setSegmentInfo(right_segment_node, right_cfg, true)
	end 
	local left_num, right_num = self.m_model:getVSNum()
	self:setTextByLanKey("total_vs_text", "new_str_0904", tostring(left_num), tostring(right_num))
    self:setTextByLanKey("arena_score_text_label", "new_str_0441")
    self:setTextByLanKey("arena_coin_text", "new_str_0300", left_cfg.high_coin or 0)
	self:setTextByLanKey("arena_score_text", "new_str_0301", left_cfg.high_point or 0)

	local luaBehaviour = self.m_luaBehaviour
	local left_user = self.m_model:getUserInfoBySort(1)
	local left_head_node = luaBehaviour:FindGameObject("left_head_node")
	GameUtil:setUserAvatar(left_head_node, left_user, nil, nil, {show_flag = true, scale = 1})
	local right_user = self.m_model:getUserInfoBySort(2)
	local right_head_node = luaBehaviour:FindGameObject("right_head_node")
	GameUtil:setUserAvatar(right_head_node, right_user, nil, nil, {show_flag = true, scale = 1})
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name_text", tostring(left_user.name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name_text", tostring(right_user.name))
	
    self:updateLoopScroll()
end

function M:setAnimation()
	if self.animation.AnimationState:ToString() == "animation_1" then
		self.animation.AnimationState:SetAnimation(0, "animation_2", true)
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

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
	local round_data = data.round_data or {}
	local result = round_data.result or 0
	local round = round_data.round or 0
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "new_str_0295", index)
	
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_player_team_num_text", "upper_num_str_000" .. round)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_player_team_num_text", "upper_num_str_000" .. round)
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
	
	--local left_team_node = luaBehaviour:FindGameObject("left_team_node")
	--local left_team_data = data.left_team_data or {}
	--CommonUIUtil:createTeamHerosNode(left_team_node.transform, left_team_data, 0.35, false)
	--local right_team_node = luaBehaviour:FindGameObject("right_team_node")
	--local right_team_data = data.right_team_data or {}
	--CommonUIUtil:createTeamHerosNode(right_team_node.transform, right_team_data, 0.35, false)
end

return M