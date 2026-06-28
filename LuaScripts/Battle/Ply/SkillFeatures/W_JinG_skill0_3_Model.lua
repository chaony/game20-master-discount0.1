--若本场战斗中投掷的骰子点数为6，则该技能可以额外触发一次
local W_JinG_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_JinG_skill0_1_Model")
---@class W_JinG_skill0_3_Model : W_JinG_skill0_1_Model @
---@field super W_JinG_skill0_1_Model @W_JinG_skill0_1_Model
local M = class("W_JinG_skill0_3_Model", W_JinG_skill0_1_Model)

M.extraRevive = true

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.extraRevive = true
end

--角色死亡
---@param player PlayerModel
---@return boolean 角色是否免死
function M:checkSkill(player)
    local result = M.super.checkSkill(self, player)
    if result == false and self.extraRevive == true then    -- 骰子点数大于等于6 可再次触发免死
        local selfPoint = self:getSelfDicePoint()
        if selfPoint and selfPoint >= 6 then
            result = true
            self.extraRevive = false
            self:triggerAvoidDeath()
        end
    end 
    return result
end

function M:destroy()
    M.super.destroy(self) 
end

return M