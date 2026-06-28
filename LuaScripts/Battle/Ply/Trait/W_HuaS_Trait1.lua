--角色的专属装备
--华山
--战斗中，华山会获得70点闪避
--华山会获得90点闪避

local W_HuaS_Trait0 = require("Battle.Ply.Trait.W_HuaS_Trait0")
---@class W_HuaS_Trait1 : W_HuaS_Trait0 @
---@field super W_HuaS_Trait0 @W_HuaS_Trait0
local M = class("W_HuaS_Trait1", W_HuaS_Trait0)

function M:init()
    M.super.init(self)
    self.buffId = self:getValue(1)
   
end

return M