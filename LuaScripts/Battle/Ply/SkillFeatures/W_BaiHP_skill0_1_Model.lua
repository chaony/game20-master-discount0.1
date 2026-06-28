--战斗开始时，百花派会在我方战场上布下“生息”场地，
--当己方角色处于生息场地中时，每秒会恢复50%攻击力的血量，且会持续获得20%的加速效果，
--当敌方侠客处于场地中时，会被减速20%，且每处于场地中超过10秒，会被禁锢2秒

---@class W_BaiHP_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiHP_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.triggerHitCnt = self:getParam(1)    -- number[] 攻击次数
    self.addExtraBuff1 = self:getParam(2)    -- Buff[] 额外buff
    self.triggerCureCnt = self:getParam(3)    -- number[] 恢复次数
    self.addExtraBuff2 = self:getParam(4)    -- Buff[] 额外buff
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)
end

---@param player PlayerModel
function M:isInSXBuff(player)
    if self.player.bufMgr:hasBufByTag("W_BaiH_SX") then -- 生息场地buff
        -- 同时只有一个生息场地
        local sxBuffs = self.player.bufMgr:findBufByTag("W_BaiH_SX")
        ---@type PlayerBuf_Model
        local myBuf = sxBuffs[1]
        if not myBuf then
            return false
        end

        ---@type BufWorkAddBuf
        local bufWork = myBuf.bufWork
        if bufWork:isInBuffRange(self.player) then
            return true
        end
    end
    return false
end

function M:destroy()
    M.super.destroy(self)
end

return M