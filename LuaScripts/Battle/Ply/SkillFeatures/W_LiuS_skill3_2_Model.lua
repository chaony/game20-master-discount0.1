--六扇向前方射出8支箭矢，每支箭矢都会攻击一名随机敌方侠客，对其造成90%攻击力的外功伤害。
--若攻击的目标被施加了“悬赏”标记，则该技能对其造成的伤害必定暴击
---@class W_LiuS_skill3_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiuS_skill3_2_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
end

--攻击者的攻击开始处理
function M:killerBeforeAttack(attackData, victim)
    if victim ~= nil then
        local skillConfig = attackData.skillConfig
        if skillConfig == self.skill then
            local buffs = victim.bufMgr:findBufByTag("W_LiuS_skill1")
            if #buffs > 0 then
                attackData["mustCrit"] = true
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M