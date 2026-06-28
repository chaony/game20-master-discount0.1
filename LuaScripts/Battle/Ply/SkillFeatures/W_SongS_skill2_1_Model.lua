--战斗开始时，嵩山会获得一个寒冰护甲，当寒冰护甲存在时，嵩山会获得50%的伤害减免，
--在受到来自敌方的伤害5秒后，寒冰护甲会破碎若嵩山未受到任何伤害超过3秒，
--则寒冰护甲会重新生成
---@class W_SongS_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_SongS_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.shieldBuff = self:getParam(1)
    self.stopTime = self:getParam(2)
    self.createTime = self:getParam(3)
    self.hpBuff = self:getParam(4)
    self.stopTimer = 0
    self.createTimer = 0
    self.exist = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawnFinish()
    self.player.bufMgr:addBufById(self.shieldBuff, self.player)
    self.exist = true
end

function M:injureHandler(eventName, data)
    --在受到来自敌方的伤害5秒后
    local victim = data["victim"]
    if victim ~= nil and victim:equal(self.player) then
        --护盾如果存在
        if self.exist then
            if self.stopTimer <= 0 then
                self.stopTimer = self.stopTime
            end
        else
            self.createTimer = self.createTime
        end
    end
end

function M:update(dt,unsdt)
    M.super.update(self, dt,unsdt)
    if self.exist == false then
        if self.createTimer > 0 then
            self.createTimer = self.createTimer - dt
            if self.createTimer <= 0 then
                self.player.bufMgr:addBufById(self.shieldBuff, self.player)
                self.exist = true
            end
        end
    else
        if self.stopTimer > 0 then
            self.stopTimer = self.stopTimer - dt
            if self.stopTimer <= 0 then
                self.player.bufMgr:removeBufById(self.shieldBuff)
                self.exist = false
                self.player.bufMgr:addBufById(self.hpBuff, self.player)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M