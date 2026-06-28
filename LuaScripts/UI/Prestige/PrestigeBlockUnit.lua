---@class PrestigeBlockUnit : OOUIbase
local M = class("PrestigeBlockUnit", LikeOO.OOUIbase)

M.m_uiName = "Prestige/PrestigeBlockUnit"

function M:onEnter()

end

function M:destroy()
    M.super.destroy(self)
end

return M
