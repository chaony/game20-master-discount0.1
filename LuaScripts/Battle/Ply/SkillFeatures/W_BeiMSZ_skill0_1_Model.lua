--悲魔山庄 镇狱破天劲
--悲魔山庄原地消失，随后在敌人身后出现并对其造成200%攻击力的伤害和持续2秒的眩晕效果，
--	若悲魔山庄身上存在“破天劲”，则该技能还会随机对另一名敌方侠客造成一次攻击，但造成的伤害和眩晕效果会减半

---@class W_BeiMSZ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BeiMSZ_skill0_1_Model", SkillFeatures_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawnFinish()
    self.mySkill1 = self.player.plySkill:getSkillByName("skill1")
    M.super.spawnFinish(self)
end

---@return W_BeiMSZ_skill1_1_Model
function M:getSelfSkill1()
    if self.mySkill1 then
        return self.mySkill1.cur_skill_config and self.mySkill1.cur_skill_config.feature
    end
end

function M:skillDispatch(data)
    if data.eventName == "ExtraAttack" then
        self.player.evtMgr:commonEventWork( "Hit", 1)
    end
end

return M