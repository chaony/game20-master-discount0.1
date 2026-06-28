local M = class("QiMenDunJiaContentPopTwoView", LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaContentPopTwo"
M.m_size_type = 2

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    self:setText("levelup_text", self.m_model:getConstent())
end

return M
