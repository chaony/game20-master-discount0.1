--角色的专属装备
--天龙
--大招持续期间，天龙会获得25%的吸血效果
--天龙会获得35%的吸血效果

local W_TianL_Trait0 = require("Battle.Ply.Trait.W_TianL_Trait0")

---@class W_TianL_Trait1 : W_TianL_Trait0 @
---@field super W_TianL_Trait0 @W_TianL_Trait0
local M = class("W_TianL_Trait1", W_TianL_Trait0)


function M:init()
    M.super.init(self)
    self.buffId = self:getValue(1)
end

return M