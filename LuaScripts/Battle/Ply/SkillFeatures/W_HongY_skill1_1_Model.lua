--红衣的普攻得到强化，威力提升100%且变为范围伤害，但每攻击两次之后，需要3秒时间重新装弹。
---@class W_HongY_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HongY_skill1_1_Model", SkillFeatures_Model)

M.timer = 0

M.count = 0

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.cd = self:getParam(1)
    --动作起手和收招时长
    self.animTime = GlobalTools.base1
    self.attackCount = self:getParam(2)
    self.timer = 0
    self.count = 0
end

function M:update(dt)
    M.super.update(self, dt)
    if self.timer > 0 and self.player.animator.curState ~= nil and self.player.animator.curState.name == "reload_loop" then
        self.timer = self.timer - dt
        if self.timer <= GlobalTools.base0 then
            self.player.animator:changeState("reload_end")
        end
    end
end

function M:skillDispatch(data)
    if data.eventName == "skill1_reload" then
        self.count = self.count + 1
        if self.count >= self.attackCount then
            self.count = 0
            self.timer = self.cd - self.animTime
            self.player.animator:changeState("reload")
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M