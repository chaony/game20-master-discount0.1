---@class W_TianXH_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianXH_skill3_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffId = self:getParam(1)
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    if self.skill.level >= 3 then
        self.player:useSkill("skill3_plus", true)
    end
    --BattleTool:safeTriggerActionEventWork(self.player, "skill3_plus", "addBuff", 1)
    --local enemies = SelectTargetUtil:findPlayerByParam(self.player, { camp = "enemy", ignoreSummon = true, pos = "forceMax", count = "one"})
    --enemies:safeWalkInverted(function(player)
    --    player.bufMgr:addBufById(self.buffId, self.player, self.skill)
    --end)
end

function M:destroy()
    M.super.destroy(self)
end

return M