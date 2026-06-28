--金钱帮角色的专属装备

--接住飞斧的几率提升至80%

--新：战斗中金钱会获得50%的攻速加成
local W_JinQ_Trait0 = require("Battle.Ply.Trait.W_JinQ_Trait0")

---@class W_JinQ_Trait1 : W_JinQ_Trait0 @
---@field super W_JinQ_Trait0 @W_JinQ_Trait0
local M = class("W_JinQ_Trait1", W_JinQ_Trait0)

function M:init()
    M.super.init(self)
    self.atk_speed = self:getValue(1)
    
end

return M