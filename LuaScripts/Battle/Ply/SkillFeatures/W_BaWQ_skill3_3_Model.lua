-- 释放时若自身没有枪头，则该技能会获得强化，造成的伤害会提升100%，若强化后的技能成功击杀了敌人，则会立即恢复5根枪头

local W_BaWQ_skill3_2_Model = require("Battle.Ply.SkillFeatures.W_BaWQ_skill3_2_Model")
---@class W_BaWQ_skill3_3_Model : W_BaWQ_skill3_2_Model @
---@field super W_BaWQ_skill3_2_Model @W_BaWQ_skill3_2_Model
local M = class("W_BaWQ_skill3_3_Model", W_BaWQ_skill3_2_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    -- 技能是否被强化
    self.isUpSkill = false
end

function M:skillStart(data)
    local skill1 = self:getSkill1()
    if (skill1 and skill1.curResLv <= self.upSkillCnt) then -- 小于指定枪头数，强化技能
        self:upgradeCurrentSkill()
    else
        self.isUpSkill = false
    end
    M.super.skillStart(self, data)
end

-- 升级本次技能
function M:upgradeCurrentSkill()
    self.isUpSkill = true
end

---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    if attackData.skillConfig == self.skill then
        if self.isUpSkill then
            attackData["damageLast"] = attackData["damageLast"] + self.afterDamageAddValue
        end
    end
end

---@param data Battle_EventData_KillPlayer
function M:killPlayer(data)
    M.super.killPlayer(self, data)
    if self.isUpSkill and data.attackData.skillConfig == self.skill then
        local skill1 = self:getSkill1()
        if skill1 then
            skill1:willAddResLv(self.addResLvUp)
        end
    end
end

return M