-- lv2若该技能击杀了敌方任意单位，则会立即额外释放一次
local W_ShuS_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_ShuS_skill1_1_Model")

---@class W_ShuS_skill1_2_Model : W_ShuS_skill1_1_Model @
---@field super W_ShuS_skill1_1_Model @W_ShuS_skill1_1_Model
local M = class("W_ShuS_skill1_2_Model", W_ShuS_skill1_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

---@param data Battle_EventData_KillPlayer
function M:killPlayer(data)
    if data.attackData.skillConfig == self.skill then
        self.player.aiEngine.skillConfig = self.skill
        self.player.aiEngine:changeState("attack") 
    end
end

return M