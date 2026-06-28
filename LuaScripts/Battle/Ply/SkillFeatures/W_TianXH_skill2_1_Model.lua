--天下会自身的血量比例每减少30%，便会立即获得一个300%攻击力的护盾并在在自身周围产生一个结界，护盾和结界会持续5秒。
--处于结界内的敌人每秒会受到80%攻击力的伤害，触发该技能时，天下会的最大生命值比例越低，则造成的伤害会越高
---@class W_TianXH_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianXH_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --触发掉血比例
    self.triggerHpRate = self:getParam(1)
    --是否死亡触发
    self.deadTrigger = self:getParam(2) == 1
    --护盾buff
    self.guardBuff = self:getParam(3)
    --结界buff
    self.areaBuff = self:getParam(4)
    --单位掉血比例
    self.lostHpRate = self:getParam(5)
    --单位伤害比例
    self.dmgRate = self:getParam(6)
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("selfHp", {self,self.conditionHandler})
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
    self.trigger = Battle.List.new()
    local curRate = GlobalTools.base1 - self.triggerHpRate
    while curRate > 0 do
        self.trigger:add(curRate)
        curRate = curRate - self.triggerHpRate
    end
end

--条件触发
function M:conditionHandler( eventName, data )
    local player = data["ply"]
    local hpRate = data.value
    if self.trigger.Count > 0 and self.player:equal(player) and self.player:isLive() == true then
        local nextTrigger = self.trigger:get(0)
        --while nextTrigger ~= nil and hpRate <= nextTrigger do
        --    self.trigger:removeAt(0)
        --    self:activate()
        --    nextTrigger = self.trigger:get(0)
        --end
        local count = self.trigger.Count
        for i = 1, count do
            if nextTrigger ~= nil and hpRate <= nextTrigger then
                self.trigger:removeAt(0)
                self:activate()
                nextTrigger = self.trigger:get(0)
            else
                break
            end
        end
    end
end

function M:killerPlayerHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if self.deadTrigger == true and victim ~= nil and victim:get_camp() ~= self.player:get_camp() then
        self:activate()
    end
end

function M:activate()
    self.player.bufMgr:addBufById(self.guardBuff, self.player, self.skill)
    self.player.bufMgr:addBufById(self.areaBuff, self.player, self.skill)
end

function M:killerAfterAttack(data)
    local dmg = data["damage"]
    local killer = data["killer"]
    local skill = data.attackData["skillConfig"]
    if self.player:equal(killer) and skill == nil or skill.anim_name ~= "skill2" then
        local count = GlobalTools:ToFix((GlobalTools.base1 - self.player.data:get_hpRate())//(self.lostHpRate))
        local dmgAdd = GlobalTools:Mul(count, self.dmgRate)
        data.damage = GlobalTools:Mul(dmg, GlobalTools.base1 + dmgAdd)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("selfHp", {self,self.conditionHandler})
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    M.super.destroy(self)
end

return M