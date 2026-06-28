--角色的专属装备
--峨眉
--峨眉的每次普工都会为自身叠加一层强化buf，每层buf提高自身攻击力3%，最多叠加10层
--最多叠加15层

local W_EM_Trait0 = require("Battle.Ply.Trait.W_EM_Trait0")

---@class W_EM_Trait1 : W_EM_Trait0 @
---@field super W_EM_Trait0 @W_EM_Trait0
local M = class("W_EM_Trait1", W_EM_Trait0)


function M:init()
    M.super.init(self)
    
    self.maxCount = self:getValue(2)
   
end


return M