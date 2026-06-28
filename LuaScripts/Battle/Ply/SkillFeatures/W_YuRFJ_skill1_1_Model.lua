--羽人非獍發出音刃攻擊血量百分比最低的敵人，對其造成240%攻擊力的傷害，該若該技能成功擊殺了敵人，則會額外釋放一次，且額外釋放時會攻擊所有敵人
--（霹雳效果：每上阵一个霹雳联动角色，該技能造成伤害提升10%）
---@class W_YuRFJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YuRFJ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hurtUpRate1 = self:getParam(1) --联动伤害提升比例
    self.hpRate = self:getParam(2) -- 命中敵人的血量低于50%，
    self.hurtUpRate2 = self:getParam(3) -- 造成伤害提升50% 
    self.beHitHpRate = self:getParam(4) -- 必命中血量百分比
    
    self.skillChange = false -- 改变技能形态
    self.seriesHurtUpRate = 0
    self.mustHit = true

    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.seriesHurtUpRate = GlobalTools:Mul(self:checkSeriesHeroCount(), self.hurtUpRate1)
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.skillChange then
        self.skill.extra_anim_name = "skill1_1"
    else
        self.skill.extra_anim_name = "skill1"
    end
    self.skillChange = false
end
-- 技能必命中
function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    local skill  = attackData.skillConfig
    if skill ~= nil and (skill.anim_name == "skill1" or skill.anim_name == "skill1_1") then
        if victim.data:get_hpRate() <= self.beHitHpRate  then
            attackData.mustHit = self.mustHit
        end
    end
end

---@param data Battle_EventData_KillPlayer 本技能杀死敌人
function M:killPlayer(data)
    if data.attackData.skillConfig and data.attackData.skillConfig.anim_name == "skill1" then
        self.skillChange = true
        self.player:useSkill("skill1",true) -- 强制用一次skill1
    end
end

--- 我方系列英雄个数
function M:checkSeriesHeroCount()
    local count = 0 -- 联动角色个数
    local heroes = self.player.plyMgr:getPlayers(self.player.camp)
    for i = heroes.Count, 1, -1 do
        local hero = heroes:get(i-1)
        if hero.plyData.id ~= self.player.plyData.id and
                table.indexof(Battle.EnumData.BATTLE_PLBDX_HERO_ID, tonumber(hero.plyData.id))  then
            count = count + 1
        end
    end
    return GlobalTools:ToFix(count)
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    if self.player:equal(data.killer) and self.skill == data.attackData.skillConfig then  --攻击者是自己
        if(data.victim.data:get_hpRate() <= self.hpRate)then
            data.wantdata.damage = data.wantdata.damage + GlobalTools:Mul(data.wantdata.damage, self.seriesHurtUpRate + self.hurtUpRate2) -- 命中敵人的血量低于50%，造成伤害提升50% 
        else
            data.wantdata.damage = data.wantdata.damage + GlobalTools:Mul(data.wantdata.damage, self.seriesHurtUpRate) -- 霹雳效果：每上阵一个霹雳联动角色，該技能造成伤害提升10%
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M