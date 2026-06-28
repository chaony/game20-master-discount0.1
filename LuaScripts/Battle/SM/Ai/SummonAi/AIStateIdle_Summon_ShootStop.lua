--召唤物 发射后停留——待机 行为 AI基类
---@class AIStateIdle_Summon_ShootStop : AIState @
---@field super AIState @AIState
local M = class("AIStateIdle_Summon_ShootStop", Battle.AIState)

M.anim_name = "idle"

function M:enter()
    M.super.enter(self)
    --if self.player.tranformHelper ~= nil then
    --    local obj = self.player.tranformHelper:FindObj(self.player.tran, "body")
    --    obj:SetActive(false)
    --end
    self.player:hideBody(false);
    self.player.animator:changeState(self.anim_name)
end

--退出当前状态
function M:exit()
    M.super.exit(self)
end

return M