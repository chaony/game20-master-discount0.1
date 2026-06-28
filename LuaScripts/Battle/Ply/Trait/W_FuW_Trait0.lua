--角色的专属装备
--福威
--战斗中每隔15秒福威会为一名随机的乙方角色回复100点内力
---@class W_FuW_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_FuW_Trait0", PlayerTrait)


M.time = 0

M.localTime = 0

M.anger = nil

function M:init()
    M.super.init(self)
    self.time = self:getValue(1)
    self.anger = self:getValue(2)
    self.localTime = self.time
end


function M:update(dt)
    M.super.update(self,dt)
    if self.localTime > 0 then
        self.localTime = self.localTime - dt
        if self.localTime <= 0 then
            local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
            local random = WRandom:randomNum(0, friends.Count)
            if friends[random] ~= nil then
                friends[random].angerData:addAnger(self.anger)
                self.localTime = self.time
            end
        end
    end 
    
end


function M:destroy()
    M.super.destroy(self)
   
end
return M