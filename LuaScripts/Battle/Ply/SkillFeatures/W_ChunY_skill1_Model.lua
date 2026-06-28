--战斗中，每过去10秒，纯阳会进入“无我”状态，“无我”状态持续5秒，持续期间，纯阳会获得60%的攻速提升
---@class W_ChunY_skill1_Model : SkillFeatures_Model
local M = class("W_ChunY_skill1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.delay = self:getParam(1)
    self.interval = self:getParam(2)
    self.buffId1 = self:getParam(3)
    self.time = self.delay
end

function M:update(dt,unsdt)
    self.time = self.time - dt
    if self.time <= 0 then
        self.time = self.interval
        self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
    end
end

return M