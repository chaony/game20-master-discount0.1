--灵之迅捷：
--飞雪继承150%的属性，攻击速度提高30%

---@class W_JiuLSP_Resonance_skill1 : SkillResonance
---@field super SkillResonance
local M = class("W_JiuLSP_Resonance_skill1", SkillResonance)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.attr = self:getParam(1)
    self.spdBuff = self:getParam(2)
end

function M:destroy()
    M.super.destroy(self)
end


return M;