--该技能会附加敌方最大生命值5%的伤害,最多不会超过桃花500%攻击力的伤害
---@class W_TaoH_skill1_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaoH_skill1_2_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.hpRate = self:getParam(1)
    self.maxDamage = self:getParam(2)
    self.wuseShield = self:getParam(3);

    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    local skillConfig = attackData.skillConfig
    if skillConfig ~= nil and skillConfig.anim_name == "skill1" then
        attackData.ignoreGuard = (self.wuseShield == 1)
    end
end

---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if killer ~= nil and killer:equal(self.player) then
        if skillConfig ~= nil and skillConfig.anim_name == "skill1" then
            local my_damage = GlobalTools:Mul(victim.data:get_hp(), self.hpRate)
            local maxDmg = GlobalTools:Mul(self.player.data.atk:getValue(), self.maxDamage)
            if my_damage > maxDmg then
                my_damage = maxDmg
            end

            local attackData = table.shallow_copy(data["attackData"])
            attackData.prefabName = ""
            TimeTools:delayTime(GlobalTools.base0_1,function()
                victim:beHitDirect(self.player, attackData, {damage = my_damage}, false, false)
            end)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end
return M