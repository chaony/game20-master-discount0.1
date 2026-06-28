local M = class("FulwinSecondFightLoadView",LikeOO.OOPopBase)

M.m_uiName = "FulwinArena/FulwinSecondFightLoad"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("tips_text", "fylt_str_00100")
end

return M


