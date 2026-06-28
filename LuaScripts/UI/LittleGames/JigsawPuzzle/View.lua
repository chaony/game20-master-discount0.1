local M = class("JigsawPuzzleView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/JigsawPuzzle/JigsawPuzzle"
M.m_size_type = 2

local level_map = {"a_pintu_1","a_pintu_2","a_pintu_3","a_pintu_4","a_pintu_5","a_pintu_6"}

function M:onEnter()
	self:setTextByLanKey("nextBtnText", "little_game_text_012")
	self:setTextByLanKey("backBtnText", "new_str_0478")
	self:setTextByLanKey("titleFinishScoreText", "new_str_0922")
	self:setTextByLanKey("close_title_text", "little_game_text_007")
	
	for i=1,5 do
		local a = math.random(1,6)
		local b = math.random(1,6)
		if a ~= b then
			local c = level_map[a]
			level_map[a] = level_map[b]
			level_map[b] = c
		end
	end
	local MainCtrl = self.m_ui_obj:GetComponent("MainCtrl")
	local max_level = self.m_model:getMaxLevel()
	MainCtrl:SetMaxLevel(max_level)
	for i=1, max_level do
		MainCtrl:AddPictureName(level_map[i])
	end
	MainCtrl:setPassFunction(function()
		self.m_model:addScore()
		self:setText("finishScoreText", self.m_model.m_score)
		self:setTextByLanKey("score_text", "little_game_text_002", self.m_model.m_score)
		if self.m_model.m_is_mult == true then
			self.m_control:gameMultStreetSettlement()
		else
			self.m_control:gameStreetSettlement()
		end
	end)
	
	local GameView = self:findGameObject("GameView"):GetComponent("GameView")
	GameView:setTimeFunction(function(time)
		self.m_model.m_time = time
		local score = self.m_model:getScoreByTime()
		self:setTextByLanKey("Time","little_game_text_004", time, score)
	end)
	
	local game_sp = self:findSkeletonGraphic("game_sp")
	self:addSpineComplete(game_sp.AnimationState, function()
		if game_sp.AnimationState:ToString() == "animation1" then
			game_sp.AnimationState:ClearTracks()
			game_sp.AnimationState:SetAnimation(0, "animation2", true)
		end
	end)

	local home_sp = self:findSkeletonGraphic("home_sp")
	self:addSpineComplete(home_sp.AnimationState, function()
		if home_sp.AnimationState:ToString() == "animation1" then
			home_sp.AnimationState:ClearTracks()
			home_sp.AnimationState:SetAnimation(0, "animation2", true)
		end
	end)
	
	self:setTextByLanKey("score_text", "little_game_text_002", self.m_model.m_score)
	self:refreshUI()
end

function M:startGame()
	local home_sp = self:findSkeletonGraphic("home_sp")
	home_sp.AnimationState:ClearTracks()
	home_sp.AnimationState:SetAnimation(0, "animation3", false)
	self.m_control:setOnceTimer(0.3, function()
		local MainCtrl = self.m_ui_obj:GetComponent("MainCtrl")
		MainCtrl:StartGame()
	end)
end

function M:resetGame()
	self.m_model:resetData()
	local MainCtrl = self.m_ui_obj:GetComponent("MainCtrl")
	MainCtrl:resetData()
	MainCtrl:StartGame()
end

function M:refreshUI()

end

return M