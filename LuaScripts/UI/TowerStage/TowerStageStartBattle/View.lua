local M = class("TowerStageStartBattleView",LikeOO.OOPopBase)

M.m_uiName = "TowerStage/TowerStageStartBattle"
-- M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0396")
	self:setTextByLanKey("detail_btn_text", "new_str_0208")
	self:setTextByLanKey("rank_btn_text", "new_str_0209")
	self:refreshUI()
end

function M:refreshUI()
	local floor_id = UserDataManager:getRaceFloorByRace(self.m_model.m_race)
	if self.m_model:isMaxStage() then
		self:setTextByLanKey("map_name_text", "new_str_0083", floor_id)
		self:setTextByLanKey("cur_tower_stage_text", "new_str_0211", floor_id)
		self:setTextByLanKey("reward_text", "new_str_0151", floor_id)
	else
		self:setTextByLanKey("map_name_text", "new_str_0083", floor_id + 1)
		self:setTextByLanKey("cur_tower_stage_text", "new_str_0211", floor_id + 2)
		self:setTextByLanKey("reward_text", "new_str_0151", floor_id + 1)
	end
    -- 奖励
	local rewards = self.m_model:getStageRewards()
	local reward_node = self:findGameObject("reward_node")
    GameUtil:createRewards(reward_node.transform, rewards, true, true, nil, 1)
end

function M:setVisibleBattleNode(visible)
	local start_node = self:setObjectVisible("start_node", visible)
	if start_node then
		start_node.transform.localScale = Vector3(1,0,1)
		start_node.transform:DOScaleY(1,0.5):SetEase(Tweening.Ease.InOutBack)
	end
end

function M:setVisibleTipsStartNode(visible)
	local tips_start_node = self:setObjectVisible("tips_start_node", visible)
	if tips_start_node then
		tips_start_node.transform.localScale = Vector3(1,0,1)
		tips_start_node.transform:DOScaleY(1,0.5):SetEase(Tweening.Ease.InOutBack)
	end
end

function M:doEnterAnim(backfunc)
	self:runAnim("TowerStageStartBattleEnter", backfunc or function()
	end)
end

function M:doExitAnim(backfunc)
	self:runAnim("TowerStageStartBattleExit", backfunc or function()
	end)
end

return M