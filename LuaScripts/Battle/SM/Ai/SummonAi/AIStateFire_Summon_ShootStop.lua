--召唤物 发射后停留——待机 行为 AI基类
---@class AIStateFire_Summon_ShootStop : AIState @
---@field super AIState @AIState
local M = class("AIStateFire_Summon_ShootStop", Battle.AIState)

M.anim_name = "skill"

function M:enter(data)
    M.super.enter(self, data)
    --if self.player.tranformHelper ~= nil then
    --    local obj = self.player.tranformHelper:FindObj(self.player.tran, "body")
    --    obj:SetActive(true)
    --end
    self.player:hideBody(true);
    self.player.animator:changeState(self.anim_name)
    self.data = data
end

--更新移动状态
function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)

    if self.player.animator.curState.canChangeAnim == true then
        if self.data.toSkill == true then
            self.player.aiEngine:changeState("skill", self.data)
        else
            self.player.aiEngine:changeState("stay", self.data)
        end
    end
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M