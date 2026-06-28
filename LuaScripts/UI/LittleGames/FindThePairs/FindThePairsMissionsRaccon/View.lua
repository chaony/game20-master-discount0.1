local M = class("FindThePairsMissionsRacconView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/FindThePairs/FindThePairsMissionsRaccon"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("close_title_text", "raccon_text_0008")
	local Background_sp = self:findSkeletonGraphic("Background_sp")
	local sp_bg = self:findGameObject("Background_sp")
	GameUtil:updateSpineLoadSet(sp_bg, "RoleSpine/xiaohuanxiong_2_SkeletonData", "", 0, true)

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