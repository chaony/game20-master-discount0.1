--密宗    梵言释厄
-- lv1 密宗消耗当前生命值的10%，在敌方最密集区域内降下降魔杵，对敌人造成200%攻击力的范围伤害，释放技能时若密宗处于“涅槃”状态，则该技能不会消耗生命值
---@class W_MiZ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MiZ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.costHpBuffId = self:getParam(1)  --[Buff] 消耗生命buffid
end

function M:spawn()
    self.skill1 = self.player.plySkill:getSkillByName("skill1")
    M.super.spawn(self)
end

function M:skillStart(data)
    if not self:isInNirvana() then
        self.player.bufMgr:addBufById(self.costHpBuffId, self.player, self.skill) -- TODO 角色死亡处理
    end
    M.super.skillStart(self, data)
end

function M:isInNirvana()
    if self.skill1 and self.skill1.cur_skill_config then
        ---@type W_MiZ_skill1_1_Model
        local feature = self.skill1.cur_skill_config.feature
        return feature:isInNirvana()
    end
    return false
end

return M