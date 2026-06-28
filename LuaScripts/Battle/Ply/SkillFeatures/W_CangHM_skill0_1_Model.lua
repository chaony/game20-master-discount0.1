--当苍火门死亡时，会在自身周围产生爆炸，对范围内的敌人造成300%攻击力的伤害并为其施加一个苍火印

---@class W_CangHM_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill3 W_CangHM_skill3_1_Model
local M = class("W_CangHM_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.isTrigger = false  -- 只触发一次死亡爆炸效果
end

function M:dead(data)
    if self.isTrigger == false and self.player:isLive() then
        self.isTrigger = true
        local last = self.player.forceSkillConfig
        self.player.forceSkillConfig = self.skill
        self.player.evtMgr:triggerActionEventWork("skill0", "Hit", 1)
        self.player.forceSkillConfig = last 
    end
    return M.super.dead(self, data)
end

return M
