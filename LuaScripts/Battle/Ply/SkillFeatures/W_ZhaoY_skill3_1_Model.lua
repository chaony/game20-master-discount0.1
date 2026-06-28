--赵云召唤枪影笼罩敌人，对其造成共计5次攻击，前四次攻击会造成100%攻击力的伤害，最后一击会额外附加敌人最大生命值8%的伤害
--赵云每拥有10点闪避值，便会使该技能造成的伤害提升2%，最多提升20%
---@class W_ZhaoY_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill0 W_ZhaoY_skill0_1_Model
local M = class("W_ZhaoY_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.unitDodgeValue = self:getParam(1)  --单位闪避值
    self.addDamageRate = self:getParam(2)  -- 提升伤害百分比
    self.maxBuffLevel = self:getParam(3)  --最大层数
    EventDispatcher:registerEvent("injure", {self, self.injureHandler})
end

---@param eventData Battle_HandleData_Injure
function M:injureHandler(eventName, eventData)
    if self.player:equal(eventData.killer) and self.skill == eventData.attackData.skillConfig and self.addDamageRate > 0 then  --攻击者是自己
        local extraDamageCount = self:getExtraDamageCount()
        local baseDamage = eventData.wantdata.damage
        if extraDamageCount > 0 then
            for i = 1, extraDamageCount do
                eventData.wantdata.damage = eventData.wantdata.damage + GlobalTools:Mul(baseDamage, self.addDamageRate)
            end
        end
    end
end

function M:getExtraDamageCount()
    local count = 0
    if self.unitDodgeValue > 0 then
        count = math.floor( GlobalTools:Div(self.player.data.dodge:getValue(), self.unitDodgeValue))
        count = math.min(count, self.maxBuffLevel)
    end
    return count
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandler})
    M.super.destroy(self)
end

return M