local M = class("QiMenDunJiaContentPopView", LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaContentPop"
M.m_size_type = 2

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    self:setTextByLanKey("levelup_text", self.m_model:getConstent())
end

return M
