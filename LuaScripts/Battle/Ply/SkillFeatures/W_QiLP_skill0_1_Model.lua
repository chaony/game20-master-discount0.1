--将启灵派打出骑射状态的敌人会被施加一个复仇印记，启灵派会优先攻击被施加了复仇印记的敌人，且对其造成的攻击力提高20%
--当启灵派击杀被施加了复仇印记的敌人时，会再次进入骑射状态，若自身已经处于骑射状态，则会恢复20%最大生命值的血量
---@class W_QiLP_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_QiLP_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffData = self:getParam(1) -- 复仇印记特效buff
    self.hurtUpRate = self:getParam(2) -- 造成伤害提升数值
    self.changeStateFlag = self:getParam(3) --击杀后是否进入骑乘状态
    self.buffData2 = self:getParam(4) -- 回血buff
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("PlayerDead", {self,self.playerDeadHandler})
end

--角色出生
function M:spawn()
    M.super.spawn(self)
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil and skill1.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill1 = skill1.cur_skill_config.feature
    end

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

function M:addSkill0EffectBuff()
    if self.skill1 then
        local target = self.skill1.playerTarget
        if target and target:isLive() then
            target.bufMgr:addBufById(self.buffData, self.player)
        end
    end 
end

function M:findPlayer(data)
    if self.skill1 and self.skill1.playerTarget then
        data:clear()
        data:add(self.skill1.playerTarget) -- 优先攻击被施加了复仇印记的敌人(这里用lockEnemy为因为beHit的时候重置目标)
    end
    return data
end

---@param data Battle_BeHitDirectData
function M:injureHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if self.player:equal(killer) and victim ~= nil then -- 造成伤害的是自己
        local buffList = victim.bufMgr:findBufById(self.buffData)
        if #buffList > 0 then
            data.wantdata.damage = data.wantdata.damage + GlobalTools:Mul(data.wantdata.damage,self.hurtUpRate) -- 且对其造成的攻击力提高20%
        end
    end
end

---@param eventData Battle_HandleData_PlayerDead
function M:playerDeadHandler(eventName, eventData)
    local ply = eventData["data"]
    if ply ~= nil and self.player:equal(ply) == false then
        if ply.killer ~= nil and ply.killer:equal(self.player) then
            local buffList = ply.bufMgr:findBufById(self.buffData)
            if #buffList > 0 and self.attack1 and self.attack1:getPlayerState() then
                self.player.bufMgr:addBufById(self.buffData2, self.player) -- 杀敌回血buff
            elseif #buffList > 0 and self.attack1 and not self.attack1:getPlayerState() and self.changeStateFlag then
                self.player.animator:changeState("skill1") -- 直接切换动画(或者配到common里代码调用切换)
                self.attack1:changePlayerState(true) -- 再次进入骑乘状态
                TimeTools:delayTime(GlobalTools.base0_0_1, function()
                    if self.player and self.player:isLive() then
                        if self.skill2 ~= nil and self.skill2.skill2Flag == 1 then
                            self.player:useSkill("skill2", true) -- 强制用一下skill2技能
                        end
                    end
                end)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.playerDeadHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M