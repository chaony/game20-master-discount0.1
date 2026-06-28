--等级1:桃花每进行四次普通攻击，下一次攻击便会附加敌方
--     最大生命值5%的伤害且无视敌方防御，最多不会超过桃花500%攻击力的伤害

--等级2:附加的伤害无视敌方护盾

--等级3等级3:桃花每进行三次普通攻击,就会有一次附加伤害
---@class W_TaoH_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaoH_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --攻击次数
    self.atkCount = self:getParam(1)
    --血量百分比
    self.hpRate = self:getParam(2)
    --最大伤害量
    self.maxDamage = self:getParam(3)
    --0 不无视护盾 1 无视护盾
    self.wuseShield = self:getParam(4);
    --当前攻击次数
    self.curAtkCount = 0
    self.isWork = false
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    if self.player:equal(ply) and config.anim_name == "attack1" then
        if self.curAtkCount >= self.atkCount then
            self.curAtkCount = 0
            self.isWork = true;
            self.player:set_curSkillConfig(self.skill)
        else
            self.curAtkCount = self.curAtkCount + 1
        end
    end
end

--攻击之前
function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    local skillConfig = attackData.skillConfig
    --攻击类型是普通攻击
    if skillConfig ~= nil and skillConfig.anim_name == "skill0" then
        if self.isWork == true then
            attackData.ignoreGuard = (self.wuseShield == 1)
        end
    end
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim, skill)
    M.super.killerDataChangeTemp(self, victim, skill)
    if skill ~= nil and skill.anim_name == "skill0" then
        if self.isWork == true then
            victim.data.def:addToMulListTemp(-GlobalTools.base1)
            self.isWork = false;
        end
    end
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local isCrit = data["isCrit"]
    local skillConfig = data["attackData"]["skillConfig"]
    if killer ~= nil and killer:equal(self.player) then
        if skillConfig ~= nil and skillConfig.anim_name == "skill0" then
            local my_damage = data.damage;
            local damage = my_damage + GlobalTools:Mul(victim.data:get_hp(), self.hpRate)
            --local maxDmg = victim.data:damageCal(nil, self.player, self.player.data.atk:getValue(), self.maxDamage, GlobalTools.base1, GlobalTools.base0, isCrit)
            local maxDmg = GlobalTools:Mul(self.player.data.atk:getValue(), self.maxDamage)
            if damage > maxDmg then
                my_damage = maxDmg
            else
                my_damage = damage
            end
            TimeTools:delayTime(GlobalTools.base0_1,function()
                victim.data:set_curHp(victim.data:get_curHp() - my_damage);
                victim:showLabel(my_damage,"-", 0);
            end)
        end
    end
end



function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    M.super.destroy(self)
end
return M