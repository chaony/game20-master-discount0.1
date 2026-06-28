--启灵派骑上猎豹，带领豹群横穿战场，对敌人造成300%攻击力的伤害，若命中的敌人身上有流血效果，则该技能对其造成的伤害提升50%
-- 释放该技能后，若自身已经处于骑射状态，则会恢复20%最大生命值的血量
---@class W_QiLP_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_QiLP_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.hurtRate = self:getParam(1) -- 伤害提升百分比
    self.buffData = self:getParam(2) -- 回血buff
    self.mianYiBuff = self:getParam(3) -- 免疫buff （不被锁定，无敌，免死buf，免疫控制buf，免疫伤害控制buf，不能普攻）
    self.attrRate = self:getParam(4) -- 豹子继承属性百分比
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

--角色出生
function M:spawn()
    M.super.spawn(self)
    local attack1 = self.player.plySkill:getSkillByName("attack1")
    if attack1 ~= nil and attack1.cur_skill_config then
        ---@type SkillFeatures_Model
        self.attack1 = attack1.cur_skill_config.feature
    end
    
    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil and skill2.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill2 = skill2.cur_skill_config.feature
    end
end
-- 技能开始
function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.attack1 then
        if self.player.summonList.Count == 0 then
            self.attack1:changePlayerState(true)
        end
    end
end

-- 技能结束
function M:skillEnd(data)
    M.super.skillEnd(self, data)
    if self.attack1 and self.attack1:getPlayerState() then
        self.player.bufMgr:addBufById(self.buffData, self.player) -- 释放该技能后，若自身已经处于骑射状态，则会恢复20%最大生命值的血量
    end

    TimeTools:delayTime(GlobalTools.base0_0_1, function()
        if self.player and self.player:isLive() then
            if self.skill2 ~= nil and self.skill2.skill2Flag == 1 then
                self.player:useSkill("skill2", true) -- 强制用一下skill2技能
            end
        end
    end)
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    if self.player:equal(data.killer) and self.skill == data.attackData.skillConfig then  --攻击者是自己
        if(data.victim.bufMgr:hasBufByTag("liuxue"))then
            data.wantdata.damage = data.wantdata.damage + GlobalTools:Mul(data.wantdata.damage, self.hurtRate) -- 若命中的敌人身上有流血效果，则该技能对其造成的伤害提升50%
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M