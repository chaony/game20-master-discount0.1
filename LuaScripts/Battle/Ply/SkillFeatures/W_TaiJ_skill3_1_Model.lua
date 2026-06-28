--太极扔出身边的阴阳球并将其激发，若阴阳球已经存在于战场上，则会直接将其激发。
--激发的阴阳球会将范围的所有敌人拉扯到中心并引发大范围爆炸，造成300%攻击力内功伤害。
--该技能对召唤物造成的伤害翻倍

---@class W_TaiJ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaiJ_skill3_1_Model", SkillFeatures_Model)

local table_data = require("Battle.Ply.SkillFeaturesData.W_TaiJ_skill3_1_Data")
M.sendForData = table_data.sendForData
M.move_data = table_data.move_data

function M:spawnFinish( )
    M.super.spawnFinish(self)
    self.dmgRate = self:getParam(1)
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local damage = data["damage"]
    local skill = data.attackData["skillConfig"]
    if killer ~= nil and killer:equal(self.player) and skill ~= nil and skill.anim_name == "skill3" then
        if victim ~= nil and victim.master ~= nil then
            data["damage"] = data["damage"] + GlobalTools:Mul(data["damage"], self.dmgRate)
        end
        end
end

return M