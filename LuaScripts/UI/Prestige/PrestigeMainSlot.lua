---@class PrestigeMainSlot : OOUIbase
local M = class("PrestigeMainSlot", LikeOO.OOUIbase)

M.m_uiName = "Prestige/PrestigeMainSlot"

PRESTIGE_MAIN_SLOT_STATE = {
    UNAVAILABLE = 1,  -- 不能放的
    LOCKED = 2,       -- 锁定的
    OCCUPIED = 3,     -- 已放置棋子
    UNOCCUPIED = 4,   -- 未放置棋子
}

function M:onEnter()
    self:setObjectVisible("wood_img", false)
    self:setObjectVisible("lock_img", false)
    self.lock_transform = self:findRectTransform("lock_img")
    local function click_callback()
        self:updateMsg("click_lock_slot", self.unlock_level, "Prestige.PrestigeMain")
    end
    UIUtil.setButtonClick(self.lock_transform, click_callback)
end

function M:setState(state)
    self.state = state
    if self.state == PRESTIGE_MAIN_SLOT_STATE.UNAVAILABLE then
        self:setObjectVisible("wood_img", false)
        self:setObjectVisible("lock_img", false)
    elseif self.state == PRESTIGE_MAIN_SLOT_STATE.LOCKED then
        self:setObjectVisible("wood_img", true)
        self:setObjectVisible("lock_img", true)
    elseif self.state == PRESTIGE_MAIN_SLOT_STATE.OCCUPIED then
        self:setObjectVisible("wood_img", false)
        self:setObjectVisible("lock_img", false)
    elseif self.state == PRESTIGE_MAIN_SLOT_STATE.UNOCCUPIED then
        self:setObjectVisible("wood_img", true)
        self:setObjectVisible("lock_img", false)
    end
end

function M:setUnlockLevel(level)
    self.unlock_level = level
end

function M:animToUnlock()  -- todo: add anim
    self:setState(PRESTIGE_MAIN_SLOT_STATE.OCCUPIED)
end

function M:destroy()
    M.super.destroy(self)
end

return M
