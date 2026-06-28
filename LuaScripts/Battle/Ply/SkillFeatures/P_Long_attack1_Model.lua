-- 普攻攻击带火种的单位，额外追加一次50%攻击力的伤害
---@class P_Long_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Long_attack1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.skill1Prob = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawn()
    M.super.spawn(self)
    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil then
        self.skill2 = skill2.cur_skill_config.feature
        self.skill2_cur_skill_config = skill2.cur_skill_config.feature.skill
    end
end

function M:skillStart(data)
    self.skill1Prob = false
    M.super.skillStart(self, data)
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    local killer = eventData["killer"]
    local skill = eventData.attackData["skillConfig"]
    local victim = eventData["victim"]
    if self.skill2 and self.player:equal(killer) and skill ~= nil and skill.anim_name == "attack1" and victim and victim.bufMgr and
            victim.bufMgr:hasBufByTag("P_Long_skill3") and not self.skill1Prob then
        self.skill1Prob = true
        victim.bufMgr:addBufById(self.skill2.buffData1, self.player)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M