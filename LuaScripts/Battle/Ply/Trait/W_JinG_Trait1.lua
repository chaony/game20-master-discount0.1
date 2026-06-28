--角色的专属装备
-- 金刚 每场战斗第一次释放绝技时，技能蓄力期间金刚不会死亡
--战斗中，金刚获得的所有护盾值提升20%
local W_JinG_Trait0 = require("Battle.Ply.Trait.W_JinG_Trait0")
---@class W_JinG_Trait1 : W_JinG_Trait0 @
---@field super W_JinG_Trait0 @W_JinG_Trait0
local M = class("W_JinG_Trait1", W_JinG_Trait0)

M.shiled = 0

function M:init()
    M.super.init(self)
	self.shiled = self:getValue(3) -- 提高的护盾值
	EventDispatcher:registerEvent("ShieldValue", {self,self.ShieldHandler})
end



function M:ShieldHandler(eventName, data)
    local ply = data["ply"]
    local buf = data["shieldValue"]
    local isStart = data["isStart"]
    if isStart == true then
        if buf ~= nil then
            if buf.value > 0 then
                if ply:equal(self.player) then
                    buf.value = GlobalTools:Mul( buf.value, (GlobalTools.base1 + self.shiled) ) 
                end
            end
        end
    end
end



function M:destroy()
    M.super.destroy(self) 
    EventDispatcher:unRegisterEvent("ShieldValue", {self,self.ShieldHandler})
end




return M