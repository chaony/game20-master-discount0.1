local M = class("MeridianView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_iphoneXAdapter = true
M.m_uiName = "HeroInfo/MeridianPop"

function M:onEnter()
    self:setTextByLanKey("close_text","new_str_0419")
end

return M