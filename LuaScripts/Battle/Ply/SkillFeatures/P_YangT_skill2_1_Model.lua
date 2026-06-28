--阿驼血量首次降低至40%时，立刻恢复20%最大生命值的生命
---@class P_YangT_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_YangT_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.minHpValue = self:getParam(1) -- 血量低于这个值回血
    self.buffData2 = self:getParam(2) -- 回血buff
end

function M:spawn()
    M.super.spawn(self)
    self.triggerCnt = 0
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    if self.triggerCnt < 1 and self.player.data:get_hpRate() <= self.minHpValue then
        self.player.bufMgr:addBufById(self.buffData2, self.player)
        self.triggerCnt = 1
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M