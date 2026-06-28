--神机 战斗中 自身暴击率提升12%
--暴击了会使命中的敌人眩晕1秒
local W_ShenJ_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_ShenJ_skill2_1_Model")
---@class W_ShenJ_skill2_2_Model : W_ShenJ_skill2_1_Model @
---@field super W_ShenJ_skill2_1_Model @W_ShenJ_skill2_1_Model
local M = class("W_ShenJ_skill2_2_Model", W_ShenJ_skill2_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.bufid2 = self:getParam(2)
end


--作为攻击者的属性零时调整
function M:killerAfterAttack( data )
    local isCrit = data["isCrit"]
    local ply = data["killer"]
    local victim = data["victim"]
    if ply ~= nil and ply:equal(self.player) then
        if victim ~= nil and victim:isLive() and isCrit == true then
            victim.bufMgr:addBufById(self.bufid2, self.player)
            return data["damage"]
        end
    end
    return data["damage"]
end


function M:destroy()
    M.super.destroy(self)
end

return M