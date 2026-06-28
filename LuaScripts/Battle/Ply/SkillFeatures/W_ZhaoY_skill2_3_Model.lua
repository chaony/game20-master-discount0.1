--战斗开始时，赵云会立刻瞬移至与自己位置相对的敌人身后，对其造成300%攻击力的伤害，并使其眩晕3秒（优先级低于元系刺客）
local W_ZhaoY_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_ZhaoY_skill2_1_Model")
---@class W_ZhaoY_skill2_3_Model : W_ZhaoY_skill2_1_Model @
---@field super W_ZhaoY_skill2_1_Model @SkillFeatures_Model
local M = class("W_ZhaoY_skill2_3_Model", W_ZhaoY_skill2_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
end

function M:spawn()
    M.super.spawn(self)
end

---@param data Battle_HandleData_KillPlayer
function M:killPlayerHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if killer ~= nil and killer:equal(self.player) then
        if self.player.aiEngine ~= nil  then
            self.player.aiEngine.skillConfig = self.skill
            self.player.aiEngine:changeState("attack")
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    M.super.destroy(self)
end

return M