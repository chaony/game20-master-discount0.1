local M = class("PirateCaskView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/PirateCask/PirateCask"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0912")
	self:setTextByLanKey("titleScoreText", "new_str_0566")
	self:setTextByLanKey("titleFinishScoreText", "new_str_0922")
	self:setTextByLanKey("titleArrCount", "new_str_0923")
	self:setTextByLanKey("nextBtnText", "little_game_text_012")
	self:setTextByLanKey("restartBtnText", "little_game_text_012")
	self:setTextByLanKey("backBtnText", "new_str_0478")
	local panelGame = self:findGameObject("PanelGame")
	local uiGame = panelGame:GetComponent("UIGame")
	uiGame:ClearLevelData()
	local max_level = self.m_model:getMaxLevel()
	for i = 1, max_level do
		local level_id, bullet, dir = self.m_model:getLevelDataByIndex(i)
		uiGame:AddLevelData(level_id, bullet, dir)
	end
	local challenge = self.m_model:getChallenge()
	self:setObjectVisible("score_node", challenge == 1)
	self:setObjectVisible("finish_score_node", challenge == 1)
	self:refreshUI()
end

function M:refreshUI()

end

return M