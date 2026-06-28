--战斗中，天下会的最大生命值提升20%，且每损失1%的最大生命值，自身便获得1%的伤害减免，最多提升40%
---@class W_TianXH_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianXH_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --最大生命值提升
    self.hpBuff = self:getParam(1)
    --损失生命比例 
    self.lostHpRate = self:getParam(2)
    --伤害减免增加比例
    self.addAtdRate = self:getParam(3)
    --最大叠加层数
    self.maxCount = self:getParam(4)
end

function M:spawn()
    M.super.spawn(self)
    self.player.bufMgr:addBufById(self.hpBuff, self.player, self.skill)
    self.count = 0
    EventDispatcher:registerEvent("selfHp", {self,self.conditionHandler})
end

--条件触发
function M:conditionHandler( eventName, data )
    local player = data["ply"]
    local hpRate = data.value
    if self.player:equal(player) and self.player:isLive() == true then
        local count = (GlobalTools.base1 - hpRate)//(self.lostHpRate)
        if count >= self.maxCount then
            count = self.maxCount
        end
        count = GlobalTools:ToFix(count)
        if count ~= self.count then
            self.player.data.atd:removeFromMulList(GlobalTools:Mul(self.count, self.addAtdRate))
            self.player.data.res:removeFromMulList(GlobalTools:Mul(self.count, self.addAtdRate))
            self.count = count
            self.player.data.atd:addToMulList(GlobalTools:Mul(self.count, self.addAtdRate))
            self.player.data.res:addToMulList(GlobalTools:Mul(self.count, self.addAtdRate))
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("selfHp", {self,self.conditionHandler})
    M.super.destroy(self)
end

return M