--角色的专属装备
--段式 战斗中段式获得20%的攻击提升
--战斗中段式获得25%的攻击提升

local W_DuanS_Trait0 = require("Battle.Ply.Trait.W_DuanS_Trait0")


---@class W_DuanS_Trait1 : W_DuanS_Trait0 @
---@field super W_DuanS_Trait0 @W_DuanS_Trait0
local M = class("W_DuanS_Trait1", W_DuanS_Trait0)


function M:init()
    M.super.init(self)
    self.atk = self:getValue(1)  
end



return M