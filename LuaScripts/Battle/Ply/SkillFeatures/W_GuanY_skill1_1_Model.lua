--关羽攻击当前目标，对其造成200%攻击力并附加敌方最大生命值5%的外功伤害（附加伤害值最大相当于关羽攻击力的500%），
--并使其进入“震慑”状态2秒，震慑状态期间，敌人无法行动，震慑状态无法被免疫，该技能无视敌方免死效果每次击中敌人，
--该技能的伤害便会提升10%，冷却时间减少10%，最多叠加5次
---@class W_GuanY_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuanY_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.deathHpRate = self:getParam(1)--即死百分比
    self.extraHurtLimit = self:getParam(2)--即死百分比
    self.addDamagePer = self:getParam(3)
    self.coldTime = self:getParam(4)
    self.maxTimes = self:getParam(5)
    self.curTimes = 0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if killer ~= nil and self.player:equal(killer) then
        if BattleTool:isMySkillWithPlayer(self.player, data.attackData, "skill1") then
            local wantData = data["wantdata"]
            if self.addDamagePer > 0 then
                local addDamage = 0
                if self.curTimes < self.maxTimes then
                    self.curTimes = self.curTimes + 1
                end
                local coldCD = GlobalTools.base0
                for i = 1, self.curTimes do
                    addDamage = addDamage + GlobalTools:Mul(wantData.damage, self.addDamagePer)
                    coldCD = coldCD + self.coldTime
                end
                coldCD =  GlobalTools:Mul(self.skill.cur_post_cd,coldCD)
                self.skill.cur_post_cd = self.skill.cur_post_cd - coldCD
                wantData.damage = wantData.damage + addDamage
            end
            if victim and victim.data:get_hpRate() <= self.deathHpRate then
                data.attackData.ignoreAvoidDeath = true
            end
        elseif BattleTool:isMySkillBuff(self, data.attackData, "W_GuanY_skill1_bleed") then
            local atk = self.player.data.atk:getValue()
            local damageLimit = GlobalTools:Mul(atk, self.extraHurtLimit)
            if data.wantdata.damage > damageLimit then
                data.wantdata.damage = damageLimit
            end
            if victim and victim.data:get_hpRate() <= self.deathHpRate then
                data.attackData.ignoreAvoidDeath = true
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M