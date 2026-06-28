local W_WDang_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_WDang_skill2_1_Model")
--等级2:若该技能命中了带有护盾的敌人，则会立即达到最大伤害效果和爆炸范围
---@class W_WDang_skill2_2_Model : W_WDang_skill2_1_Model @
---@field super W_WDang_skill2_1_Model @W_WDang_skill2_1_Model
local M = class("W_WDang_skill2_2_Model", W_WDang_skill2_1_Model)

function M:checkShield(bullet, damage)
    if bullet.minHitPlayer ~= nil then
        local shieldBuff = bullet.minHitPlayer.bufMgr:findBufByType("Shield")
        if #shieldBuff > 0 then
            damage = self.maxDmg
        end
    end
    return damage
end

function M:destroy()
    M.super.destroy(self)
end
return M