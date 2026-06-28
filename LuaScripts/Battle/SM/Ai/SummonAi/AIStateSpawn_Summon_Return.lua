local spawnState = require("Battle.SM.Ai.SummonAi.AIStateSpawn_Summon")

--召唤物 控制后回收——出生 行为 AI基类
---@class AIStateSpawn_Summon_Return : spawnState @
---@field super spawnState @spawnState
local M = class("AIStateSpawn_Summon_Return", spawnState)

M.anim_name = "jumpin1"


function M:toNextState()
    self.player.aiEngine:changeState("return")
end

return M