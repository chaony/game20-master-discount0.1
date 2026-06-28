local M = class("CompareSwordDefendPopView", LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/GameOfHeavenAndEarth/CompareSwordDefendPop"
M.m_iphoneXAdapter = true
M.m_size_type = 1

function M:onEnter()


end


function M:destroy()

	M.super.destroy(self)
end


return M