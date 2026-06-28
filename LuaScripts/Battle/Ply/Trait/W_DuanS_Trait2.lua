--角色的专属装备
--段式 战斗中段式获得20%的攻击提升

--战斗中段式获得30%的攻击提升

local W_DuanS_Trait1 = require("Battle.Ply.Trait.W_DuanS_Trait1")


---@class W_DuanS_Trait2 : W_DuanS_Trait1 @
---@field super W_DuanS_Trait1 @W_DuanS_Trait1
local M = class("W_DuanS_Trait2", W_DuanS_Trait1)


function M:init()
    M.super.init(self)
    self.atk = self:getValue(1)  
end


return M