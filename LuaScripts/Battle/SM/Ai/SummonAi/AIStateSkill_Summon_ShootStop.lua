--召唤物 发射后停留——待机 行为 AI基类
---@class AIStateSkill_Summon_ShootStop : AIState @
---@field super AIState @AIState
local M = class("AIStateSkill_Summon_ShootStop", Battle.AIState)

M.anim_name = "skill1"

function M:enter(data)
    M.super.enter(self)
    --if self.player.tranformHelper ~= nil then
    --    local obj = self.player.tranformHelper:FindObj(self.player.tran, "body")
    --    obj:SetActive(true)
    --end
    self.player:hideBody(true);
    if data.skillName ~= nil then
        self.player.animator:changeState(data.skillName)
    else
        self.player.animator:changeState(self.anim_name)
    end
    self.waitTime = data.waitTime
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)

    if self.player.animator.curState.canChangeAnim == true then
        self.player.aiEngine:changeState("stay", {waitTime = self.waitTime})
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M