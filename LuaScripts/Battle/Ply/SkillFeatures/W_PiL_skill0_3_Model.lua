--霹雳在受到致命伤害时，会冲到距离自己最近的一名敌人面前并自爆，对爆炸范围内的敌人造成600%攻击力的伤害
--若该技能击杀了敌人，则被击杀的敌人也会爆炸，额外造成一次伤害。
local W_PiL_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_PiL_skill0_1_Model")
---@class W_PiL_skill0_3_Model : W_PiL_skill0_1_Model @
---@field super W_PiL_skill0_1_Model @W_PiL_skill0_1_Model
local M = class("W_PiL_skill0_3_Model", W_PiL_skill0_1_Model)


function M:init(ply, skill,className) 
    M.super.init(self, ply, skill,className) 
    self.buffId = self:getParam(8)--伤害buf
end

--死亡
function M:killPlayer(data) 
    M.super.killPlayer(self)
    local victim = data.victim
    local killer = data.victim.killer 
    if victim ~= nil and killer ~= nil then
        if killer:equal(self.player) then
            if killer:get_curSkillConfig() ~= nil and killer:get_curSkillConfig() == self.skill then
                local buffs = victim.bufMgr:findBufById(self.buffId)
                if table.nums(buffs) <= 0 then
                    victim.bufMgr:addBufById(self.buffId, self.player) 
                end 
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M