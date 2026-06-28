--当狼王死亡时，万兽会进入“复仇”状态5秒，复仇状态下，万兽的攻速提升100%，攻击力提升50%，当万兽死亡时，狼王会立刻冲至杀死万兽的敌人面前并进入“血怒”状态，血怒状态下，狼王每秒会损失10%的最大生命值，但攻击速度和攻击力提升50%
local W_WanS_skill0_2_Model = require("Battle.Ply.SkillFeatures.W_WanS_skill0_2_Model")
---@class W_WanS_skill0_3_Model : W_WanS_skill0_2_Model @
---@field super W_WanS_skill0_2_Model @W_WanS_skill0_2_Model
local M = class("W_WanS_skill0_3_Model", W_WanS_skill0_2_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.revenge_hasteBuff = self:getParam(3)
    self.revenge_atkBuff = self:getParam(4)
    self.anger_hasteBuff = self:getParam(5)
    self.anger_atkBuff = self:getParam(6)
    self.lostHp = self:getParam(7)
    self.angerTimer = 0;
    self.inAnger = false
    EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end

--死亡回调
function M:deadHandler( eventName, data )
    local player = data["data"]
    if self.summon ~= nil and self.summon:equal(player) == true then
        if self.player:isLive() == true then
            self.player.bufMgr:addBufById(self.revenge_atkBuff, self.player)
            self.player.bufMgr:addBufById(self.revenge_hasteBuff, self.player)
        end
    elseif self.player:equal(player) == true then
        if self.summon ~= nil and self.summon:isLive() == true then
            self.summon:lockEnemy( self.player.killer_player )
            self.summon.bufMgr:addBufById(self.anger_hasteBuff, self.summon)
            self.summon.bufMgr:addBufById(self.anger_atkBuff, self.summon)
            self.inAnger = true
            self.angerTimer = 0
        end
    end
end

function M:update(dt)
    M.super.update(self, dt)
    if self.inAnger == true and self.summon ~= nil and self.summon:isLive() == true then
        if self.angerTimer < 1 then
            self.angerTimer = self.angerTimer + dt
            if self.angerTimer >= 1 then
                self.angerTimer = 0
                local hp = self.summon.data.curHp - self.lostHp * self.summon.data.hp:getValue()
                if hp <= 0 then
                    hp = 0
                end
                self.summon.data:set_curHp(hp)
                if hp <= 0 then
                    self.summon:dead({}, nil);
                end
            end
        end 
    end 
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
    M.super.destroy(self)
end

return M