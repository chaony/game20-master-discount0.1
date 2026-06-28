--战斗开始时，赵云会立刻瞬移至与自己位置相对的敌人身后，对其造成300%攻击力的伤害，并使其眩晕3秒（优先级低于元系刺客）

---@class W_ZhaoY_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhaoY_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    if attackData.skillConfig == self.skill then
        if self.player.skyStar ~= nil then
            self.player.skyStar:triggerStart(victim)
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M