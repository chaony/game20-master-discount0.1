--丐帮身上的每层“酒意”buff，都会为其提供12%的伤害减免以及10%的攻速提升。
--当“酒意”buff叠满时，丐帮会进入“醉倒”状态5秒，“醉倒”状态下，
--丐帮无法攻击也无法移动。“醉倒”状态结束后，会清除身上所有“酒意”buff。
---@class W_GaiB_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GaiB_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --减伤提速
    self.buffId1 = self:getParam(1)
    --免疫buff
    self.buffId2 = self:getParam(2)
    self.time = self:getParam(3)
    self.buffCount = 0
    self.maxCount = 4
    self.timer = GlobalTools.base0;
    EventDispatcher:registerEvent("markCount", {self,self.addBuffHandler})
end


function M:addBuffHandler(eventName, data)
    local source = data["source"]
    local count = data["count"]
    if self.player:equal(source) then
        self.player.bufMgr:addBufById(self.buffId1, self.player)
        self.buffCount = count
        if self.buffCount >= self.maxCount then
            --self.player.aiEngine.skillConfig = self.skill
            --self.player.aiEngine:changeState("attack")
            self.player.bufMgr:addBufById(self.buffId2, self.player)
            self.timer = self.time
        end
    end
end

----技能结束
--function M:skillEnd()
--    self.buffCount = 0
--    self.player.bufMgr:removeBufByTag("W_GaiB_skill2")
--    self.player.bufMgr:removeBufById(self.buffId1)
--    self.player.bufMgr:removeBufById(self.buffId2)
--end

--技能结束
function M:clearBuff()
    local markBuff = self.player.bufMgr:findBufByTag("W_GaiB_skill2")
    for k,v in ipairs(markBuff) do
        if v.bufWork.count >= self.maxCount then
            local count = v.bufWork.count//2
            self.buffCount = v.bufWork.count - count
            v.bufWork:removeMark(count)
        end
    end

    self.player.bufMgr:removeBufById(self.buffId1)
    self.player.bufMgr:removeBufById(self.buffId2)
end

--更新
function M:update(dt)
    if self.timer > GlobalTools.base0 then
        self.timer = self.timer - dt
        if self.timer <= GlobalTools.base0 then
            --self.player.animator:changeState("skill0_end")
            self:clearBuff()
        end
    end
end

----攻击开始处理
--function M:beforeAttack(attackData, killer)
--    M.super.beforeAttack(self, attackData, killer)
--    if self.timer > 0 then
--        attackData.mustDodgeOut = true
--    end
--end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("markCount", {self,self.addBuffHandler})
    M.super.destroy(self)
end
return M