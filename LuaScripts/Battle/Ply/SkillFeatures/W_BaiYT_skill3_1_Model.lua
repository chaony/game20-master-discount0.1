--白玉堂对当前敌人造成350%攻击力的伤害，释放时若敌人当前血量低于50%，则本次伤害必定暴击
--lv2 若击杀敌人后伤害溢出，则本次伤害的80%会对所有敌方侠客造成伤害
--lv3 释放是若自身处于“xx”状态，则该技能会无视敌方50%防御力
---@class W_BaiYT_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiYT_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.critHpRate =  self:getParam(1) --必暴击血量
    self.buffId = self:getParam(2) -- 杀敌buff
    self.wuShiDefRate =  self:getParam(3) --无视防御比例
    self.useFlag = false
end

function M:skillStart(data)
    M.super.skillStart(self,data)
    self.useFlag = false
end

--攻击者的攻击开始处理
---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
    if victim and self.player:equal(attackData.player) then
        local skillConfig = attackData.skillConfig
        if skillConfig == self.skill then
            if(victim.data:get_hpRate() < self.critHpRate) then -- 血量低于50%，则本次伤害必定暴击
                attackData["mustCrit"] = true
            end
        end
    end
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim, skill)
    M.super.killerDataChangeTemp(self,victim)
    if victim ~= nil and skill ~= nil and skill.anim_name == "skill3" then
        if(self.player.bufMgr:hasBufByTag("W_BaiYT_skill2")) then -- 该技能会无视敌方50%防御力
            victim.data.def:addToAddListTemp(-GlobalTools:Mul(victim.data.def:getValue(),self.wuShiDefRate))
        end
    end
end

---@param data Battle_EventData_KillPlayer
function M:killPlayer(data)
    M.super.killPlayer(self, data)
    if data.attackData.skillConfig == self.skill and not self.useFlag then -- 该技能杀敌
        self.useFlag = true
        local enemies = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", ignoreSummon = true})
        enemies:safeWalkInverted(function(enemy)
            if enemy and enemy.bufMgr then
                enemy.bufMgr:addBufById(self.buffId, self.player, self.skill) -- 杀敌buff
            end
        end)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M