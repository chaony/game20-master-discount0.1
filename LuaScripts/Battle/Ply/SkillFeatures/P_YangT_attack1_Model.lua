-- 阿驼的普攻会附带20%概率的晕眩，持续2秒。在斗气阶段胜利后，晕眩概率额外提升10%
---@class P_YangT_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_YangT_attack1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.battleWin = false -- 比斗气是否胜出
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawn()
    M.super.spawn(self)
    local skill4 = self.player.plySkill:getSkillByName("skill4")
    if skill4 ~= nil and skill4.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill4 = skill4.cur_skill_config.feature
    end
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    local killer = eventData["killer"]
    local skill = eventData.attackData["skillConfig"]
    local victim = eventData["victim"]
    if self.player:equal(killer) and skill ~= nil and skill.anim_name == "attack1" and victim and victim.bufMgr and self:canAddBuff() then
        victim.bufMgr:addBufById(self.skill4.bufId, self.player)
    end
end

function M:canAddBuff()
    local flag = false
    if self.skill4 and self.skill4.bufId and self.skill4.imprisonConditionExtra and self.skill4.imprisonCondition then
        local random = WRandom:randomNum(0, 100, true)
        local condition = self.battleWin and self.skill4.imprisonConditionExtra or self.skill4.imprisonCondition
        --Logger.logError(" 随机 ~~~~~~~~~~ "..tostring(random).." self.angerCondition "..tostring(self.angerCondition) )
        if random < condition then
            flag = true
        end
    end
    return flag
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M