--林冲每次普攻命中敌人时，会为其施加一层“寒星”效果，每层寒星效果会使其造成的伤害减少10%，内力恢复效果减少10%，最多叠加6层，持续5秒；
--当寒星效果叠加至6层时，会消耗所有效果立即引爆目标，对其造成300%攻击力的伤害并使其冰冻3秒，冰冻结束后，目标造成的伤害会减少60%，内力恢复效果减少60%，持续5秒

---@class W_LinC_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LinC_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffNum = self:getParam(1) -- 寒星引爆层数
    self.buffData1 = self:getParam(2) -- 引爆敌人BUFF
    self.buffData3 = self:getParam(3) -- 林冲特效buff
    self.buffData4 = self:getParam(4)
    self.buffData5 = self:getParam(5)
    self.buffData6 = self:getParam(6)
    self.buffData7 = self:getParam(7)
    self.buffData8 = self:getParam(8)
    self.buffData2 = self:getParam(9) -- 引爆自身BUFF
    EventDispatcher:registerEvent("afterAddBuff", {self,self.afterAddBuffHandler})
end

---@param data Battle_BeHitDirectData
function M:afterAddBuffHandler(eventName, data)
    local victim = data.victim
    if self.player:equal(data.killer) == true and victim ~= nil then -- 攻击者是自己
        local buffs = victim.bufMgr:findBufByTag("W_LinC_skill0")
        local bufData = self:getBufIdByCount(buffs)
        victim.bufMgr:removeBufByTag("W_LinC_skill0_effect",true) -- 移除寒星特效buff
        victim.bufMgr:addBufById(bufData, self.player)
        if table.nums(buffs) >= self.buffNum then
            victim.bufMgr:removeBufByTag("W_LinC_skill0") -- 移除寒星
            victim.bufMgr:addBufById(self.buffData1, self.player, self.skill)
            self.player.bufMgr:addBufById(self.buffData2, self.player)
        end
    end
end

function M:getBufIdByCount(buffs)
    local bufData = nil
    if #buffs == 1 then
        bufData = self.buffData3
    elseif #buffs == 2 then
        bufData = self.buffData4
    elseif #buffs == 3 then
        bufData = self.buffData5
    elseif #buffs == 4 then
        bufData = self.buffData6
    elseif #buffs == 5 then
        bufData = self.buffData7
    elseif #buffs == 6 then
        bufData = self.buffData8
    end
    return bufData
end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("afterAddBuff", {self,self.afterAddBuffHandler})
    M.super.destroy(self)
end
return M