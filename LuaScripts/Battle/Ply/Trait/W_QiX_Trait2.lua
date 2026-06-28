--角色的专属装备
--七秀 释放大招后，七秀会立即获得300点内力


local W_QiX_Trait1 = require("Battle.Ply.Trait.W_QiX_Trait1")


---@class W_QiX_Trait2 : W_QiX_Trait1 @
---@field super W_QiX_Trait1 @W_QiX_Trait1
local M = class("W_QiX_Trait2", W_QiX_Trait1)

function M:init()
    M.super.init(self)
    self.anger = self:getValue(1)
     
end


return M