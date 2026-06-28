--角色的专属装备
--崆峒 因自身技能受到的负面效果，现在也会同样作用在命中的敌人身上
--战斗中，崆峒的最大血量提升20%


local W_KongT_Trait0 = require("Battle.Ply.Trait.W_KongT_Trait0")

---@class W_KongT_Trait1 : W_KongT_Trait0 @
---@field super W_KongT_Trait0 @W_KongT_Trait0
local M = class("W_KongT_Trait1", W_KongT_Trait0)


M.buffId3 = 0
function M:init()
    M.super.init(self)
    self.buffId3 = self:getValue(3) --最大血量提升20￥
end


function M:spawn()
    self.player.bufMgr:addBufById(self.buffId3, self.player)
end

return M