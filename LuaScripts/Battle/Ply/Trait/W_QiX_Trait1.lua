--角色的专属装备
--七秀 释放大招后，七秀会立即获得200点内力



local W_QiX_Trait0 = require("Battle.Ply.Trait.W_QiX_Trait0")


---@class W_QiX_Trait1 : W_QiX_Trait0 @
---@field super W_QiX_Trait0 @W_QiX_Trait0
local M = class("W_QiX_Trait1", W_QiX_Trait0)

function M:init()
    M.super.init(self)
    self.anger = self:getValue(1)
    
end



return M