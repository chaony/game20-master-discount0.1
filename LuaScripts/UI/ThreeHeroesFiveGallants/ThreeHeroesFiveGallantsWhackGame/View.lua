local M = class("ThreeHeroesFiveGallantsWhackGameView",LikeOO.OOPopBase)

M.m_uiName = "ThreeHeroesFiveGallants/ThreeHeroesFiveGallantsWhackGame"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	RedPointUtil:saveLocalRedPointFreshTime("ThreeHeroesFiveGallantsWhackGame")
	self.cat_spine_name = "maoshu_dadishu_ren1_SkeletonData" --猫spine名称
	self.mouse_spine_name = "maoshu_dadishu_ren2_SkeletonData" --老鼠spine名称
	self:setTextByLanKey("nextBtnText", "new_str_0432")
	self:setTextByLanKey("backBtnText", "new_str_0478")
	self:setTextByLanKey("titleFinishScoreText", "three_heroes_five_gallants_text_0023")
	self:setTextByLanKey("close_title_text", "three_heroes_five_gallants_text_0007")
	self:setTextByLanKey("begin_btn_text", "kaishi_tz_text")
	local tips_text = self.m_model.m_join_stage == 1 and "three_heroes_five_gallants_text_0022" or "three_heroes_five_gallants_text_0021"
	self:setTextByLanKey("tips_text", tips_text)

	self:setObjectVisible("begin_sp_cat",self.m_model.m_join_stage ~= 1)
	self:setObjectVisible("begin_sp_mouse",self.m_model.m_join_stage == 1)
	
	self.reward = self.m_model:getreward()
	self.reward_node = self:findGameObject("reward_node")
	self.GameManager = self:findGameObject("GameManager"):GetComponent("Mole_Manager")
	self.GameManager:setScoreCall(function()
		local score = self.GameManager:GetScore()
		self:setTextByLanKey("score_text", "three_heroes_five_gallants_text_0024", score)
		if score > self.m_model.m_active_data.upper_limit then
			score = self.m_model.m_active_data.upper_limit
		end
		--if self.reward ~= nil then
		--	UIUtil.destroyAllChild(self.reward_node.transform)
		--	GameUtil:createRewards(self.reward_node.transform, {self.reward[2]}, true, true)
		--	self:setObjectVisible("reward_node",true)
		--	
		--end
		--score = score + self.reward
		self:setText("finishScoreText", score)
	end)

	self:refreshSpine()
	local game_time, cycle_time = self.m_model:getGameData()
	self.GameManager:SetLimitTime(game_time)
	self.GameManager:SetWaitTimes(cycle_time[1], cycle_time[2])
	self:refreshUI()
end

function M:refreshUI()
	local remain_num = self.m_model.frequency - self.m_model.m_data.daily_times
	self:setTextByLanKey("has_reward_num_text", "wdtower_text_0008",tostring(remain_num))
end

--刷新猫和老鼠地鼠spine
function M:refreshSpine()
	--1:御猫，加入猫打老鼠   2：锦毛鼠，加入老鼠打猫
	local spine_name = self.m_model.m_join_stage == 1 and self.mouse_spine_name or self.cat_spine_name
	local other_spine_name = self.m_model.m_join_stage == 1 and self.cat_spine_name or self.mouse_spine_name
	self.GameManager.moleA = ResourceUtil:GetSk(other_spine_name, "rolespine_"..string.lower(other_spine_name))
	--self.GameManager.moleA = nil
	self.GameManager.moleB = ResourceUtil:GetSk(spine_name, "rolespine_"..string.lower(spine_name))
	for i = 1, 15 do
		local mole_name = "mole"..i
		local mole_object = self:findGameObject(mole_name)
		GameUtil:updateSpineLoadSet(mole_object,"RoleSpine/" .. spine_name,"", 0,true)
	end
end

function M:StartGame()
	self.GameManager:StartGame()
	local score = self.GameManager:GetScore()
	self:setTextByLanKey("score_text", "three_heroes_five_gallants_text_0024", score)
	self:setText("finishScoreText", score)
end

function M:startAnimation()
	self:setObjectVisible("begin_panel", false)
	self:setObjectVisible("game_panel", true)
	self:StartGame()
end

return M