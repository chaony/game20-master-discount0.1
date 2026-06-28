-- lv2 释放时，若自身存在5层以上的“邪灵”效果，则该技能会拥有20%的吸血效果

---@class W_XieJ_skill3_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field mySkill1 W_XieJ_skill1_1_Model
local M = class("W_XieJ_skill3_2_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.addSuckLevel = self:getParam(1)       -- int[0-20] 触发吸血的最大层数
    self.suckPercent = self:getParam(2)       -- Fix[0-100] 吸血百分比
end

---@return number
function M:getResLevel()
    if not self.mySkill1 then
        local  skill1 = self.player.plySkill:getSkillByName("skill1")
        if skill1 and skill1.cur_skill_config then
            self.mySkill1 = skill1.cur_skill_config.feature
        end
    end
    
    if self.mySkill1 then
        return self.mySkill1.curResLevel
    end
    
    return 0
end

---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
    if self.player:equal(data.killer) and data.attackData.skillConfig == self.skill then
        if self:getResLevel() >= self.addSuckLevel then  -- 邪灵层数达标
            local cure_value = GlobalTools:Mul(data.damage, self.suckPercent)
            self.player:cure("fix", self.player, cure_value, self.skill)
        end
    end
end

return M