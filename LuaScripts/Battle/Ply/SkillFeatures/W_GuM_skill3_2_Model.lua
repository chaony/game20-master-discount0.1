--战斗开始时，古墓会立刻召唤一个幽魂魅影
local W_GuM_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_GuM_skill3_1_Model")
---@class W_GuM_skill3_2_Model : W_GuM_skill3_1_Model @
---@field super W_GuM_skill3_1_Model @W_GuM_skill3_1_Model
local M = class("W_GuM_skill3_2_Model", W_GuM_skill3_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
    self.player.evtMgr:commonEventWork("Hit", 1)
    self.player.evtMgr:commonEventWork("Sendfor", 2)
end

function M:destroy()
    M.super.destroy(self)
end

   

return M