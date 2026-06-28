--角色的专属装备
--峨眉
--峨眉的每次普工都会为自身叠加一层强化buf，每层buf提高自身攻击力3%，最多叠加10层
--当buf叠满时，峨眉会额外获得30%的攻速提升

local W_EM_Trait1 = require("Battle.Ply.Trait.W_EM_Trait1")

---@class W_EM_Trait2 : W_EM_Trait1 @
---@field super W_EM_Trait1 @W_EM_Trait1
local M = class("W_EM_Trait2", W_EM_Trait1)

M.buffId = nil
function M:init()
    M.super.init(self)
    
    self.buffId = self:getValue(3)
   
end



function M:rest_Change()
    self.player.bufMgr:addBufById(self.buffId, self.player)
end


return M