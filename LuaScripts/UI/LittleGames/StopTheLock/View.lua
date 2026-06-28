local M = class("StopTheLockView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/StopTheLock/StopTheLock"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("nextBtnText", "little_game_text_012")
	self:setTextByLanKey("backBtnText", "new_str_0478")
	self:setTextByLanKey("titleFinishScoreText", "new_str_0922")
	self:setTextByLanKey("close_title_text", "little_game_text_005")
	self:setTextByLanKey("start_btn_text", "new_str_0917")
	self:setTextByLanKey("help_text", "little_game_text_014")
	local GameManager = self.m_ui_obj:GetComponent("GameManager")
	local Dot = self:findGameObject("Dot")

	local DotPosition = Dot:GetComponent("DotPosition")
	local dot_sp = self:findSkeletonGraphic("dot_sp")
	self:addSpineComplete(dot_sp.AnimationState, function()
		if dot_sp.AnimationState:ToString() ~= "animation3" then
			dot_sp.AnimationState:ClearTracks()
			dot_sp.AnimationState:SetAnimation(0, "animation3", true)
		end
	end)
	DotPosition:setDoPositionCall(function()
		dot_sp.AnimationState:ClearTracks()
		dot_sp.AnimationState:SetAnimation(0, "animation4", false)
	end)
	--local Player_obj = self:findGameObject("Player")
	--local Player = Player_obj:GetComponent("Player")

	local max_level = self.m_model:getMaxLevel()
	GameManager:SetMaxLevel(max_level)
	for i = 1, max_level do
		local dot_num, speed = self.m_model:getLevelData(i)
		GameManager:AddLevelData(dot_num, speed)
	end

	self:setObjectVisible("MenuTOP", false)
	self:setObjectVisible("score_bg", false)
	self:setObjectVisible("start_panel", true)
	self:setObjectVisible("Dot", false)
	self:setObjectVisible("Player", false)
	--菜
	local index = Mathf.Random(1,3)
	for i = 1, 3 do
		self:setObjectVisible("cai" .. i, i == index)
	end
	--火
	local parent = self:findGameObject("fire")
	self.m_fire_effect = self:createEffect("Hotel/UI_Hotel_Fire_003", parent)
	self:setParticleRenderOrder(self.m_fire_effect)

	--[[
	local clock_sp = self:findSkeletonGraphic("clock_sp")
	self:addSpineComplete(clock_sp.AnimationState, function()
		if clock_sp.AnimationState:ToString() == "animation2" then
			clock_sp.AnimationState:ClearTracks()
			clock_sp.AnimationState:SetAnimation(0, "animation3", true)
			self.m_control:setOnceTimer(0.5, function()
				local GameManager = self.m_ui_obj:GetComponent("GameManager")
				GameManager:FirstStartGame()
			end)
		elseif clock_sp.AnimationState:ToString() == "animation4" or clock_sp.AnimationState:ToString() == "animation5" then
			clock_sp.AnimationState:ClearTracks()
			clock_sp.AnimationState:SetAnimation(0, "animation3", true)
		end
	end)
	]]--

	GameManager:setOpenCall(function()
	--clock_sp.AnimationState:ClearTracks()
	--clock_sp.AnimationState:SetAnimation(0, "animation4", true)
		local score = GameManager:GetScore()
		self:setTextByLanKey("score_text", "little_game_text_002", score)
		self:setText("finishScoreText", score)
		local lock_num = GameManager:GetLockNum()
		self:setLockNum(lock_num)
	end)

	GameManager:setPassCall(function()
	--clock_sp.AnimationState:ClearTracks()
	--clock_sp.AnimationState:SetAnimation(0, "animation4", true)
		self:setObjectVisible("pass_sp", true)
		local pass_sp = self:findSkeletonGraphic("pass_sp")
		pass_sp.AnimationState:SetAnimation(0, "animation1", false)

		local current_level = GameManager:GetCurrentLevel()
		self:setTextByLanKey("LevelTopScreen", "little_game_text_001", current_level)

		local score = GameManager:GetScore()
		self:setTextByLanKey("score_text", "little_game_text_002", score)
		self:setText("finishScoreText", score)
	end)

	GameManager:setFailCall(function()
		--clock_sp.AnimationState:ClearTracks()
		--clock_sp.AnimationState:SetAnimation(0, "animation5", true)
	end)

	GameManager:setLockNumCall(function()
		local lock_num = GameManager:GetLockNum()
		self:setLockNum(lock_num)
	end)

	--local top_sp = self:findGameObject("top_sp")
	--top_sp.transform.localScale = Vector3(self.m_bg_scale, self.m_bg_scale, 1)

	-- 游戏初始动画状态
	--local background_sp = self:findSkeletonGraphic("background_sp")
	--background_sp.AnimationState:SetAnimation(0, "animation1", true)

	--local store_sp = self:findSkeletonGraphic("store_sp")
	--store_sp.AnimationState:SetAnimation(0, "animation1", true)

	--local clock_sp = self:findSkeletonGraphic("clock_sp")
	--clock_sp.AnimationState:SetAnimation(0, "animation1", true)

	local score = GameManager:GetScore()
	self:setTextByLanKey("score_text", "little_game_text_002", score)
	self:setText("finishScoreText", score)
	local current_level = GameManager:GetCurrentLevel()
	self:setTextByLanKey("LevelTopScreen", "little_game_text_001", current_level)
	local lock_num = GameManager:GetLockNum()
	self:setLockNum(lock_num)
	self:refreshUI()
end

function M:startAnimation()
	--[[
	local background_sp = self:findSkeletonGraphic("background_sp")
	background_sp.AnimationState:ClearTracks()
	background_sp.AnimationState:SetAnimation(0, "animation2", false)
	self:addSpineComplete(background_sp.AnimationState, function()
		if background_sp.AnimationState:ToString() == "animation2" then
			background_sp.AnimationState:ClearTracks()
			background_sp.AnimationState:SetAnimation(0, "animation3", true)
		end
	end)
	
	local store_sp = self:findSkeletonGraphic("store_sp")
	store_sp.AnimationState:ClearTracks()
	store_sp.AnimationState:SetAnimation(0, "animation2", false)
	self:addSpineComplete(store_sp.AnimationState, function()
		if store_sp.AnimationState:ToString() == "animation2" then
			store_sp.AnimationState:ClearTracks()
			store_sp.AnimationState:SetAnimation(0, "animation3", true)
		end
	end)
	]]--

	--self:setObjectVisible("Dot", false)
	--self:setObjectVisible("Player", false)

	self:setObjectVisible("Game", true)
	self:setObjectVisible("start_panel", false)

	self:setObjectVisible("lock_middle_panel", true)
	self:setObjectVisible("Dot", true)
	self:setObjectVisible("Player", true)
	self:setObjectVisible("MenuTOP", true)
	self:setObjectVisible("score_bg", true)
	local dot_sp = self:findSkeletonGraphic("dot_sp")
	dot_sp.AnimationState:ClearTracks()
	dot_sp.AnimationState:SetAnimation(0, "animation2", false)

	self.m_control:setOnceTimer(1.5, function()
		local GameManager = self.m_ui_obj:GetComponent("GameManager")
		GameManager:FirstStartGame()
	end)


	
	--local clock_sp = self:findSkeletonGraphic("clock_sp")
	--clock_sp.AnimationState:ClearTracks()
	--clock_sp.AnimationState:SetAnimation(0, "animation2", false)

	
	--local little_kaisuo_2 = self:findAnimation("start_panel")
	--little_kaisuo_2:Play()
	--self:findButton("start_btn").interactable = false
	--self.m_control:setOnceTimer(0.3, function()
	--	self:setObjectVisible("start_panel", false)
	--end)
end

function M:resetGame()
	local GameManager = self.m_ui_obj:GetComponent("GameManager")
	GameManager:resetGame()
	local score = GameManager:GetScore()
	self:setTextByLanKey("score_text", "little_game_text_002", score)
	self:setText("finishScoreText", score)
	local current_level = GameManager:GetCurrentLevel()
	self:setTextByLanKey("LevelTopScreen", "little_game_text_001", current_level)
	local lock_num = GameManager:GetLockNum()
	self:setLockNum(lock_num)
	GameManager:FirstStartGame()
end

function M:setLockNum(num)
	local num_str = tostring(num)
	for i= 1, 2 do
		local c = string.sub(num_str,i,i)
		if c and c ~= "" then
			self:setObjectVisible("num_" .. i, true)
			self:setImg("kaisuo_num_" .. c, "active_ui", "num_" .. i)
		else
			self:setObjectVisible("num_" .. i, false)
		end
	end
	--fire
	local effect_name = ""
	if num == 1 then
		effect_name = "Hotel/UI_Hotel_Fire_001"
	elseif num == 2 then
		effect_name = "Hotel/UI_Hotel_Fire_002"
	else
		effect_name = "Hotel/UI_Hotel_Fire_003"
	end
	local parent = self:findGameObject("fire")
	if self.m_fire_effect then
		U3DUtil:Destroy(self.m_fire_effect)
	end
	self.m_fire_effect = self:createEffect(effect_name, parent)
	self:setParticleRenderOrder(self.m_fire_effect)
end

function M:createEffect(tx_name, prent)
	local item = ResourceUtil:GetUIEffectItem(tx_name, prent)
	return item
end

function M:refreshUI()
	
end

function M:destroy()
	M.super.destroy(self)
	if self.m_fire_effect then
		U3DUtil:Destroy(self.m_fire_effect)
	end
end

return M