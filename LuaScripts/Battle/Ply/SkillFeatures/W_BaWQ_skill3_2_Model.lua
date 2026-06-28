-- lv2 被回马枪命中的敌人内力回复降低80%,持续1秒,释放时每多消耗一个枪头,持续时长增加1秒

local W_BaWQ_skill3_1_Model = require("Battle.Ply.SkillFeatures.W_BaWQ_skill3_1_Model")

---@class W_BaWQ_skill3_2_Model : W_BaWQ_skill3_1_Model @
---@field super W_BaWQ_skill3_1_Model @W_BaWQ_skill3_1_Model
local M = class("W_BaWQ_skill3_2_Model", W_BaWQ_skill3_1_Model)

function M:killerAfterAttack(data)
    if self.player:equal(data.killer) and (data.attackData and data.attackData.skillConfig == self.skill) then

        local costLv = 0
        -- 攻击目标后，消耗所有枪头（本技能只有一段伤害，如果多段伤害，第二段可能会消耗掉恢复的枪头）
        local skill1 = self:getSkill1()
        if skill1 then
            costLv = skill1:willCostResLv(self.maxCostLv)
            self:onSkillCostResLv(costLv)
        end

        -- 计算debuff时间
        local debuffTime = GlobalTools.base1
        for i = 1, costLv do
            debuffTime = debuffTime + self.debuffAddTime
        end
        
        local buff = data.victim.bufMgr:addBufById(self.angerDeBuff, self.player, self.skill)
        if buff then
            buff:setCurLastTime(debuffTime)
        else
            Logger.logError("BaWQ加减少能量恢复buff失败")
        end
    end
end

return M
