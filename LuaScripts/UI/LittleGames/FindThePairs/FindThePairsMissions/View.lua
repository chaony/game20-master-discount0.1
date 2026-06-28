local M = class("FindThePairsMissionsView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/FindThePairs/FindThePairsMissions"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("close_title_text", "little_game_text_003")
	local Background_sp = self:findSkeletonGraphic("Background_sp")
	self:addSpineComplete(Background_sp.AnimationState, function()
		if Background_sp.AnimationState:ToString() == "animation1" then
			Background_sp.AnimationState:ClearTracks()
			Background_sp.AnimationState:SetAnimation(0, "animation2", true)
		end
	end)
	self:refreshUI()
end

function M:refreshUI()

end

function M:setViewVisible(visible)
	if self.m_rootView then
		self.m_rootView:SetActive(visible)
	end
end


return M