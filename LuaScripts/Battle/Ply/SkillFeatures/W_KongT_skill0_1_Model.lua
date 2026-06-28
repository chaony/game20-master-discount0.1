--崆峒身上每存在一层负面状态，便获得10%的伤害提升，最多提升60%
---@class W_KongT_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_KongT_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)
    self.maxCount = self:getParam(2)
    self.buffCount = 0
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("add_debuff", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_debuff", {self,self.removeBuffHandler})
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.player) then
        if self.buffCount < self.maxCount then
            self.player.bufMgr:addBufById(self.buffId, self.player)
        end
        self.buffCount = self.buffCount + 1
    end
end

function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.player) then
        if self.buffCount <= self.maxCount then
            local buffs = self.player.bufMgr:findBufById(self.buffId)
            if table.nums(buffs) > 0 then
                self.player.bufMgr:removeBuf(buffs[#buffs])
            end
        end
        self.buffCount = self.buffCount - 1
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("add_debuff", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_debuff", {self,self.removeBuffHandler})
end

return M