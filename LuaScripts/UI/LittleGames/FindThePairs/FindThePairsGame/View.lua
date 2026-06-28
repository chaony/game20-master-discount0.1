local M = class("FindThePairsGameView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/FindThePairs/FindThePairsGame"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()
	local sp_bg = self:findGameObject("Background_sp")
	local Background_sp = self:findSkeletonGraphic("Background_sp")
	if self.m_model.m_open_type == "raccon" then
		GameUtil:updateSpineLoadSet(sp_bg, "RoleSpine/xiaohuanxiong_1_SkeletonData", "", 0, true)
		self:setTextByLanKey("close_title_text", "raccon_text_0008")
	else
		GameUtil:updateSpineLoadSet(sp_bg, "RoleSpine/xiaochu_1_SkeletonData", "", 0, true)
		self:setTextByLanKey("close_title_text", "little_game_text_003")
	end
	self:setTextByLanKey("help_text", "little_game_text_015")
	
	self:addSpineComplete(Background_sp.AnimationState, function()
		if Background_sp.AnimationState:ToString() == "animation1" then
			Background_sp.AnimationState:ClearTracks()
			Background_sp.AnimationState:SetAnimation(0, "animation2", true)
		end
	end)
	self:setObjectVisible("server_log_text", self.m_model.m_open_type == "raccon")
	local GameManager = self.m_ui_obj:GetComponent("PairsGameManager")
	GameManager:setScoreCall(function()
		local score = GameManager:GetScore()
		self:setTextByLanKey("score_text", "little_game_text_002", score)
		self:setTextByLanKey("server_log_text", self.m_model:getServerLogDes(score))
		self:setText("finishScoreText", score)
	end)

	local max_level = self.m_model:getMaxLevel()
	GameManager:SetMaxLevel(max_level)
	for i=1, max_level do
		local level_time = self.m_model:getLevelData(i)
		GameManager:AddLevelData(level_time)
	end

	self:refreshUI()
	self.m_control:setOnceTimer(0.02,function()
		self:resetGame()
	end)
end

function M:resetGame()
	local GameManager = self.m_ui_obj:GetComponent("PairsGameManager")
	GameManager:resetGame()

	local score = GameManager:GetScore()
	self:setTextByLanKey("score_text", "little_game_text_002", score)
	self:setText("finishScoreText", score)
	self:setTextByLanKey("server_log_text", self.m_model:getServerLogDes(score))

	GameManager:StartGame()
end

function M:refreshUI()

end


return M