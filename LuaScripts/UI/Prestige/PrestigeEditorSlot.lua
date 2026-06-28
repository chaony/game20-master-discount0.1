---@class PrestigeEditorSlot : OOUIbase
local M = class("PrestigeMainSlot", LikeOO.OOUIbase)

M.m_uiName = "Prestige/PrestigeEditorSlot"

PRESTIGE_EDITOR_SLOT_STATE = {
    UNAVAILABLE = 1,  -- 不能放的
    LOCKED = 2,       -- 锁定的
    UNLOCKED = 3      -- 解锁的
}

function M:onEnter()
    self:setObjectVisible("gray_img", false)
    self:setObjectVisible("lock_img", false)
end

function M:setState(state)
    self.state = state
    if self.state == PRESTIGE_EDITOR_SLOT_STATE.UNAVAILABLE then
        self:setObjectVisible("gray_img", true)
        self:setObjectVisible("lock_img", false)
    elseif self.state == PRESTIGE_EDITOR_SLOT_STATE.LOCKED then
        self:setObjectVisible("gray_img", false)
        self:setObjectVisible("lock_img", true)
    elseif self.state == PRESTIGE_EDITOR_SLOT_STATE.UNLOCKED then
        self:setObjectVisible("gray_img", false)
        self:setObjectVisible("lock_img", false)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
