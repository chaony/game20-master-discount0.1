--段氏先瞬移至与攻击目标相同列，随后蓄力后向前方发射剑雨,对路径上的所有敌人造成220%攻击力的伤害和击退效果
---@class W_DuanS_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuanS_skill3_1_Model", SkillFeatures_Model)

M.targetData = require("Battle.Ply.SkillFeaturesData.W_DuanS_skill3_1_Data")

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:skillDispatch(data)
    if data.eventName == "skil3_move" then
        local enemys = SelectTargetTool:findPlayerByType(self.targetData, self.player)
        local enemy = enemys:get(0)
        if enemy ~= nil then
            local pos = self.player.position
            pos.z = enemy.position.z
            self.player:setPos(pos, true)
        end
    end
end
   

return M