-- 该技能每命中一个敌人，藏剑便获得一层持续5秒的护盾，每层护盾可抵挡100%攻击力的伤害
local W_CangJ_skill2_2_Model = require("Battle.Ply.SkillFeatures.W_CangJ_skill2_2_Model")
---@class W_CangJ_skill2_3_Model : W_CangJ_skill2_2_Model @
---@field super W_CangJ_skill2_2_Model @W_CangJ_skill2_2_Model
local M = class("W_CangJ_skill2_3_Model", W_CangJ_skill2_2_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.shieldBuff = self:getParam(1)
end


--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local skill = data.attackData.skillConfig
    if skill ~= nil and skill.anim_name == "skill1" then
        self.player.bufMgr:addBufById(self.shieldBuff, self.player)
    end
end

return M