--角色的专属装备
--天鹰 战斗中天鹰命中增加60点

--战斗中天鹰命中增加80点
local W_TianY_Trait0 = require("Battle.Ply.Trait.W_TianY_Trait0")
---@class W_TianY_Trait1 : W_TianY_Trait0 @
---@field super W_TianY_Trait0 @W_TianY_Trait0
local M = class("W_TianY_Trait1", W_TianY_Trait0)


function M:init()
    M.super.init(self)
    self.buffId = self:getValue(1)
  
end



return M