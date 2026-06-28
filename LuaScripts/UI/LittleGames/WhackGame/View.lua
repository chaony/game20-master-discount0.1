local M = class("WhackGameView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/Whack/WhackGame"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("nextBtnText", "little_game_text_012")
	self:setTextByLanKey("backBtnText", "new_str_0478")
	self:setTextByLanKey("titleFinishScoreText", "new_str_0922")
	self:setTextByLanKey("close_title_text", "little_game_text_006")
	self:setTextByLanKey("begin_btn_text", "kaishi_tz_text")
	self:setTextByLanKey("help_text", "little_game_text_013")
	self.GameManager = self:findGameObject("GameManager"):GetComponent("Mole_Manager")
	self.GameManager:setScoreCall(function()
		local score = self.GameManager:GetScore()
		self:setTextByLanKey("score_text", "little_game_text_002", score)
		self:setText("finishScoreText", score)
	end)

	local game_time, cycle_time = self.m_model:getGameData()
	self.GameManager:SetLimitTime(game_time)
	self.GameManager:SetWaitTimes(cycle_time[1], cycle_time[2])
	
	self:refreshUI()
end

function M:refreshUI()
	
end

function M:StartGame()
	self.GameManager:StartGame()
	local score = self.GameManager:GetScore()
	self:setTextByLanKey("score_text", "little_game_text_002", score)
	self:setText("finishScoreText", score)
end

function M:startAnimation()
	self:setObjectVisible("begin_panel", false)
	self:setObjectVisible("game_panel", true)
	self:StartGame()
end

return M