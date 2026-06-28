--金刚改
--每场战斗一次，当金刚受到致命伤害时，会免疫本次伤害并立即恢复8%乘以骰子点数的最大生命值的伤害
---@class W_JinG_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JinG_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureRate = self:getParam(1) --治疗比例
    self.canRevive = true
end

function M:spawn( ... )
    local skill = self.player.plySkill:getSkillByName("skill1")
    if skill ~= nil then
        self.skill1 = skill.cur_skill_config
    end
    self.isFirst = true
    table.insert(self.player.avoidDeath, self)
end

--角色死亡
---@param player PlayerModel
---@return boolean 角色是否免死
function M:checkSkill(player)
    if self.canRevive == true then
        self.canRevive = false
        self.isFirst = false
        self:triggerAvoidDeath()
        return true
    end
    return false
end

--触发免死回血
function M:triggerAvoidDeath()
    local selfPoint = self:getSelfDicePoint()
    if selfPoint then
        local pointFix = GlobalTools:ToFix(selfPoint)
        local cure = GlobalTools:Mul(self.cureRate,  pointFix)
        self.player.data:set_curHp(GlobalTools.base0)       -- 从0的基础上回血
        self.player:cure("hp", self.player, cure, self.skill)
    end
end

---@return number 获取自己骰子点数
function M:getSelfDicePoint()
    if self.skill1 and self.skill1.feature and self.skill1.feature.selfPoint then
        return self.skill1.feature.selfPoint
    end
    return nil
end

function M:destroy()
    M.super.destroy(self) 
    
end

return M