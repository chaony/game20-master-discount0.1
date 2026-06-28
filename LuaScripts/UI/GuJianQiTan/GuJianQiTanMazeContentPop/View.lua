local M = class("GuJianQiTanMazeContentPopView", LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanMazeContentPop"
M.m_size_type = 2

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    self:setText("des_text", self.m_model:getConstent())
end

return M
