-- 若是在xx战阵中释放该技能，则该技能的最后一击伤害会翻倍且会使敌人眩晕2秒
local W_HuaML_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_HuaML_skill1_1_Model")
---@class W_HuaML_skill1_3_Model : W_HuaML_skill1_1_Model @
---@field super W_HuaML_skill1_1_Model @W_HuaML_skill1_1_Model
local M = class("W_HuaML_skill1_3_Model", W_HuaML_skill1_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:skillStart(data)
    local skill3 = self:getSkill3()
    if (skill3 and skill3.alreadyAdd) or (self.player.bufMgr and self.player.bufMgr:findBufByTag("W_HuaML_skill3_plus2")) then   
        self.skill.extra_anim_name = "skill1_1"
    else
        self.skill.extra_anim_name = "skill1"
    end
    M.super.skillStart(self, data)
end

---@return W_HuaML_skill3_1_Model
function M:getSkill3()
    if not self.skill3 then
        self.skill3 = self.player.plySkill:getSkillByName("skill3")
    end
    return self.skill3
end

return M