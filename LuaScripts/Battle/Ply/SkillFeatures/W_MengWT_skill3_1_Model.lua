--蒙武堂进入防御姿态8秒，期间免疫控制，受到的伤害减少40%，且每秒会恢复自身生命值8%的血量，
-- 技能结束时，会对自身周围的敌人造成300%攻击力的伤害和2秒眩晕效果
---@class W_MengWT_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MengWT_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --时长 
    self.time = self:getParam(1) -- 防御时间
    self.buffBuff = self:getParam(2) --防御期间给自身加的buff
    self.timer = 0
end

function M:spawn()
    M.super.spawn(self)
end

function M:skillDispatch(data)
    if data.eventName == "skill3_addBuff" then
        self.timer = self.time
        self.player.bufMgr:addBufById(self.buffBuff, self.player, self.skill)
    end
end

function M:update(dt)
    M.super.update(self, dt)
    if self.player.animator ~= nil and self.player.animator.curState ~= nil and self.player.animator.curState.name == "skill3_loop" then
        self.timer = self.timer - dt
        if self.timer <= 0 or self.player:isLive() ~= true then
            self:stopState()
        end
    end
end

function M:stopState()
    self.player.animator:changeState("skill3_end")
end

function M:destroy()
    M.super.destroy(self)
end

return M