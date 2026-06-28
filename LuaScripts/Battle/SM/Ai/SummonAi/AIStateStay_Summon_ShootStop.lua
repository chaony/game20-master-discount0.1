--召唤物 发射后停留——待机 行为 AI基类
---@class AIStateStay_Summon_ShootStop : AIState @
---@field super AIState @AIState
local M = class("AIStateStay_Summon_ShootStop", Battle.AIState)

M.anim_name = "idle"

function M:enter(data)
    M.super.enter(self)
    if self.player.tranformHelper ~= nil then
        local obj = self.player.tranformHelper:FindObj(self.player.tran, "body")
        obj:SetActive(true)
    end
    self.player.animator:changeState(self.anim_name)
    self.waitTime = data.waitTime
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)

    self.waitTime = self.waitTime - dt
    if self.waitTime <= 0 then
        self.player.aiEngine:changeState("return", self.data)
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M