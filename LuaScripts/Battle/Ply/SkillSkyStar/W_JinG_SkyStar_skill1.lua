--作弊骰子：
--金刚投出的骰子，点数一定更大，且当金刚投出的点数是6时，“修罗狂煞”的效果翻倍。

---@class W_JinG_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_JinG_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)

    self.shareDmgBuff = self:getParam(1, 0)   --Buf[] -- 提升buff
end

---@param skillFeature W_JinG_skill1_1_Model
function M:triggerStart(skillFeature)
    -- 点数总是更大
    if skillFeature.selfPoint < skillFeature.enemyPoint then
        skillFeature.selfPoint, skillFeature.enemyPoint = skillFeature.enemyPoint, skillFeature.selfPoint
    elseif skillFeature.selfPoint == skillFeature.enemyPoint then
        if skillFeature.selfPoint < 6 then
            skillFeature.selfPoint = skillFeature.selfPoint + 1
        else
            skillFeature.enemyPoint = skillFeature.enemyPoint - 1
        end
    end

    if skillFeature.selfPoint == 6 then
        skillFeature.shareDmgBuff = self.shareDmgBuff
    end
end

return M;