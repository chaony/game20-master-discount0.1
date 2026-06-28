--角色的专属装备
-- 六扇 普通攻击现在会攻击额外攻击到被施加了“悬赏”印记的敌人
--攻击被施加了“悬赏”印记的敌人时，自身造成的伤害提升10%

local W_LiuS_Trait0 = require("Battle.Ply.Trait.W_LiuS_Trait0")


---@class W_LiuS_Trait1 : W_LiuS_Trait0 @
---@field super W_LiuS_Trait0 @W_LiuS_Trait0
local M = class("W_LiuS_Trait1", W_LiuS_Trait0)


function M:init()
    M.super.init(self)
    self.atk = self:getParam(1)
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim)
    if victim ~= nil then
        local buffs = victim.bufMgr:findBufByTag("W_LiuS_skill1")
        if #buffs > 0 then
            self.player.data.atk:addToMulListTemp(self.atk)
        end
    end
end


function M:destroy()
    M.super.destroy(self)
   
end

return M