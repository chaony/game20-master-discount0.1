local M = class("MazeStageEnemyTipsView",LikeOO.OOPopBase)

M.m_uiName = "MazeStage/MazeStageEnemyTips"
M.m_size_type = 2

function M:onEnter()
	
end

function M:destroy()
	for i=1, 3 do
		local camera_obj = self:findGameObject("Camera" .. i)
		CommonUIUtil:setCameraTargetNull(camera_obj)
	end
	M.super.destroy(self)
end

return M