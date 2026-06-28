--战斗开始时，逍遥会立刻获得200点内力，“逍遥游”状态持续期间，逍遥会保留最少1点血量，且不会死亡
---@class W_XiaoY_skill2_1_Model : SkillFeatures_Model
local M = class("W_XiaoY_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.inState = false
    self.anger_add = self:getParam(1)
end

function M:spawnFinish()
    self.player.data:addAnger(self.anger_add, true)
    M.super.spawnFinish(self)
end

function M:stateStart()
    self.inState = true
end

function M:stateEnd()
    self.inState = false
end

--死亡
function M:dead(data)
    M.super.dead(self)
    if self.inState == true then
        self.player.data:set_curHp(GlobalTools.base1)
        return false
    end
    return true
end

function M:destroy()
    M.super.destroy(self)
end

return M