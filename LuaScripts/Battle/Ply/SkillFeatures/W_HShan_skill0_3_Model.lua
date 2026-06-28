--衡山对内功型角色造成的伤害提升20%
--受到内功型敌人的伤害减少20%
local W_HShan_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_HShan_skill0_1_Model")
---@class W_HShan_skill0_3_Model : W_HShan_skill0_1_Model @
---@field super W_HShan_skill0_1_Model @W_HShan_skill0_1_Model
local M = class("W_HShan_skill0_3_Model", W_HShan_skill0_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.res = self:getParam(2) or GlobalTools.base0
end

--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
    self.player.data.res:addToMulList(self.res)
end

--攻击结束处理
--function M:afterAttack(data)
--    local killer = data.killer
--    local victim = data.victim
--    local damage = data.damage
--    if killer ~= nil and killer:equal(self.player) == false then
--        if victim ~= nil and victim:equal(self.player) then
--            if killer.plyData.type == 3 then
--                local damage_add = GlobalTools:Mul(data.damage, self.atk);         
--                data.damage = data.damage - damage_add
--            end
--        end
--    end
--end


function M:destroy()
	M.super.destroy(self)
end

return M