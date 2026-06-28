-- 修改每次加buff改为0-30后每个阶段使用不同的buff

---@class W_TianL_skill0_Model : SkillFeatures_Model
local M = class("W_TianL_skill0_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.intervalBuffs = { self:getParam(1), self:getParam(2), self:getParam(3), self:getParam(4)}
    self.nextBuffIndex = 1

    self.interval = self:getParam(5)
    self.noPoisonBuff = self:getParam(6)
    self.noBleedBuff = self:getParam(7)
    self.time = self.interval
end

---添加下一个buff
function M:addNextIntervalBuff()
    local index = math.min(#self.intervalBuffs, self.nextBuffIndex)
    local buffId = self.intervalBuffs[index]
    self.player.bufMgr:addBufById(buffId, self.player)
    self.nextBuffIndex = self.nextBuffIndex + 1
end

function M:spawn()
    M.super.spawn(self)
    self:addNextIntervalBuff()
    self.player.bufMgr:addBufById(self.noPoisonBuff, self.player)
    self.player.bufMgr:addBufById(self.noBleedBuff, self.player)
end

function M:update(dt,unsdt)
    self.time = self.time - dt
    if self.time <= 0 then
        self.time = self.interval
        self:addNextIntervalBuff()
    end
end

return M