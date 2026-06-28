local M = class("BattleLoadingView",LikeOO.OOPopBase)

M.m_uiName = "Loading/BattleLoading"
M.m_normal = false
M.m_sortOrder = 10011
M.m_size_type = 2
M.m_sortOrderChange = false

function M:onEnter()
	self.m_slider = self:findSlider("battle_loading_slider")
	--self.tongjiling_spine = self:findGameObject("tongjiling_spine")
	--local animation = self.tongjiling_spine:GetComponent("SkeletonGraphic")
	--animation.Skeleton:SetToSetupPose()
	--animation.AnimationState:ClearTracks()
	--animation.AnimationState:SetAnimation(0,"animation", false)
end



function M:updateSlider(progress)
	self.m_slider.value = progress
end


return M