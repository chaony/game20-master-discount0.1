--角色的专属装备
--蹶张 战斗开始，自身获得80%的攻速提升，该效果会在后续10秒内衰减至0%
---@class W_JueZ_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_JueZ_Trait0", PlayerTrait)

--攻速
M.speed = nil
--时长
M.max_time = 0

M.start = true

M.remove_value = 0

local i = 0

M.num_value = 0

M.max_value = 0

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.speed = self:getValue(1)
    self.max_time = self:getValue(2)
    self.max_value = self:getValue(3)
    self.start = true
    self.num_value = self.speed
    i = 0

end

function M:spawn()
    self.player.data.haste:addToAddList(self.speed)
    self.remove_value = self.speed / self.max_time
end


function M:update(dt)

    if self.start then
        if i >= 1 then
            self.max_time = self.max_time - 1
            if self.max_time > 0 and self.num_value > self.max_value then
                self.player.data.haste:removeFromAddList( self.speed )
                self.speed = self.speed - self.remove_value
                self.player.data.haste:addToAddList( self.speed )
                self.num_value = self.speed
            else
                self.start = false
            end
            
            i = i - 1
        end
        i = i + dt 
    end
      
end



function M:destroy()
    M.super.destroy(self)
end

return M