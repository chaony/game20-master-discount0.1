
-- 金刚重击前方敌人，对范围内的敌人造成200%攻击力的外功伤害，若本场战斗中投掷的骰子点数大于3，则该技能还会使命中的敌人眩晕2秒

---@class W_JinG_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JinG_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.point = self:getParam(1)
    self.buff = self:getParam(2)
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawn()
    local skill = self.player.plySkill:getSkillByName("skill1")
    if skill ~= nil then
        self.skill1 = skill.cur_skill_config
    end
end

function M:injureHandler(eventName, data)
    local ply = data["killer"]
    if self.player:equal(ply) then
        if self.skill1 ~= nil and self.skill1.feature.selfPoint ~= nil and self.skill1.feature.selfPoint > self.point then
            local victim = data["victim"]
            local skillConfig = data["attackData"]["skillConfig"]
            if victim ~= nil then
                if skillConfig ~= nil and skillConfig.anim_name == "skill2" then
                    victim.bufMgr:addBufById(self.buff, self.player)
                end
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M