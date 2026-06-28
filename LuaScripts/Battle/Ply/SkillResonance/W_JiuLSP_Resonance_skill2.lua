--灵之复苏
--飞雪死亡10秒后会以100%的生命，重新进入战场

---@class W_JiuLSP_Resonance_skill2 : SkillResonance
---@field super SkillResonance
local M = class("W_JiuLSP_Resonance_skill2",SkillResonance)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.reCombatTime = self:getParam(1)
end

return M;