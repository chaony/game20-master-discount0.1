--每当沈嫣造成的治疗效果溢出时，便会触发一道弑魔之雷，对随机一名敌方角色造成伤害，造成相当于溢出治疗效果的60%伤害

---@class W_ShenY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShenY_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.damagePercent = self:getParam(1)    -- Fix[] 治疗量转伤害
    self.addBuff1 = self:getParam(2)    -- Buff[] 护盾buff
    self.cureRate = self:getParam(3)    --治疗效果提升
    EventDispatcher:registerEvent("cureOverflow", {self,self.cureOverflowHandler})
end

function M:spawn()
    M.super.spawn(self)
    self.player.data.cureRate:addToMulList(self.cureRate)
end

---@param eventData Battle_HandleData_CureOverFlow
function M:cureOverflowHandler(eventName, eventData)
    if self.player:equal(eventData.source) then -- 是本角色造成的治疗
        local skill_name = eventData.sourceSkill and eventData.sourceSkill.anim_name or ""
        if skill_name == "skill1" or skill_name == "skill2" or skill_name == "skill3" then
            local buffData = table.copy(self.player.bufMgr.bufData[self.addBuff1])
            if buffData then
                local damage = GlobalTools:Mul(eventData.overflow, self.damagePercent)
                local target = SelectTargetUtil:findOneEnemy(self.player)
                if target then
                    BattleTool:addFixedBleed(self.player, target, buffData, damage, self.skill, self.addBuff1)
                end
            end
        end
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("cureOverflow", {self,self.cureOverflowHandler})
    M.super.destroy(self)
end

return M