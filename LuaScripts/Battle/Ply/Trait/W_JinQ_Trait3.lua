--金钱帮角色的专属装备

--接住飞斧的几率提升至100%

local W_JinQ_Trait2 = require("Battle.Ply.Trait.W_JinQ_Trait2")

---@class W_JinQ_Trait3 : W_JinQ_Trait2 @
---@field super W_JinQ_Trait2 @W_JinQ_Trait2
local M = class("W_JinQ_Trait3", W_JinQ_Trait2)


function M:init()
    M.super.init(self)
    self.rate = self:getValue(1) 
   
end



function M:destroy()
    M.super.destroy(self)
end

return M