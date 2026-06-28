--蝴蝶君每次普攻命中敵人時，會為其施加一層“蝶焰”效果，每層蝶焰效果會使其造成的傷害減少10%，內力恢復效果減少10%，最多疊加6層，持續5秒；
--當蝶焰效果疊加至6層時，會消耗所有效果立即引爆目標，對其造成300%攻擊力的傷害並使其眩暈3秒，之後會為其施加持續5秒的“血焰”狀態，血焰狀態下目標造成的傷害會減少60%，內力恢復效果減少60%，（處於血焰狀態的敵人無法再被施加蝶焰狀態）

---@class W_HuDJ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuDJ_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffNum = self:getParam(1) -- 蝶焰引爆层数
    self.buffData1 = self:getParam(2) -- 引爆敌人BUFF
    self.buffData3 = self:getParam(3) -- 蝴蝶君特效buff
    self.buffData4 = self:getParam(4)
    self.buffData5 = self:getParam(5)
    self.buffData6 = self:getParam(6)
    self.buffData7 = self:getParam(7)
    self.buffData8 = self:getParam(8)
    self.buffData2 = self:getParam(9) -- 引爆自身BUFF
    self.buffWudi = self:getParam(10)
    EventDispatcher:registerEvent("afterAddBuff", {self,self.afterAddBuffHandler})
end

---@param data Battle_BeHitDirectData
function M:afterAddBuffHandler(eventName, data)
    local victim = data.victim
    if self.player:equal(data.killer) == true and victim ~= nil then -- 攻击者是自己
        local buffs = victim.bufMgr:findBufByTag("W_HuDJ_skill0")
        local bufData = self:getBufIdByCount(buffs)
        victim.bufMgr:removeBufByTag("W_HuDJ_skill0_effect",true) -- 移除蝶焰特效buff
        victim.bufMgr:addBufById(bufData, self.player)
        if table.nums(buffs) >= self.buffNum then
            victim.bufMgr:removeBufByTag("W_HuDJ_skill0") -- 移除蝶焰
            victim.bufMgr:addBufById(self.buffData1, self.player, self.skill)
            self.player.bufMgr:addBufById(self.buffData2, self.player)
            if self.buffWudi > 0 and self.skill.level >= 2 then
                local piliNums = self:getPiliHeroNum()
                for i = 1, piliNums do
                    self.player.bufMgr:addBufById(self.buffWudi, self.player, self.skill)
                end
            end
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

function M:getPiliHeroNum()
    local nums = 0
    local friends = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend", ignoreSummon = true})
    for i = friends.Count, 1, -1 do
        local friend = friends:get(i-1)
        if friend and friend ~= self.player and table.indexof(Battle.EnumData.BATTLE_PLBDX_HERO_ID, tonumber(friend.plyData.id)) then
            nums = nums + 1
        end
    end
    return nums
end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("afterAddBuff", {self,self.afterAddBuffHandler})
    M.super.destroy(self)
end
return M