--该技能至少击中了一名敌人，则随后释放的“战八方”的攻击力会提升50%
local W_TianC_skill1_2_Model = require("Battle.Ply.SkillFeatures.W_TianC_skill1_2_Model")
---@class W_TianC_skill1_3_Model : W_TianC_skill1_2_Model @
---@field super W_TianC_skill1_2_Model @W_TianC_skill1_2_Model
local M = class("W_TianC_skill1_3_Model", W_TianC_skill1_2_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.atk = self:getParam(2)
    self.hitPlayer = false
    self.improve = false
end

--查找敌人
function M:findPlayer(data)
    M.super.findPlayer(self, data)
    if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then
        if data.Count > 0 then
            self.hitPlayer = true
        end
    end
    return data
end

--作为攻击者的属性临时调整
function M:killerBeforeAttack(attackData, victim)
    if self.improve == true and attackData["skillConfig"] ~= nil and attackData["skillConfig"].anim_name == "skill1" then
        attackData["damageFront"] = attackData["damageFront"] + self.atk
    end
end

--技能结束
function M:skillStart()
    self.improve = self.hitPlayer
    self.hitPlayer = false
end

function M:destroy()
    M.super.destroy(self)
end

return M