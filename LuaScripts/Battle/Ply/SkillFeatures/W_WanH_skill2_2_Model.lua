--敌方身上每有一层"七伤"诅咒,造成的伤害增加10%,最多增加30%
local W_WanH_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_WanH_skill2_1_Model")

---@class W_WanH_skill2_2_Model : W_WanH_skill2_1_Model @
---@field super W_WanH_skill2_1_Model @W_WanH_skill2_1_Model
local M = class("W_WanH_skill2_2_Model", W_WanH_skill2_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.dmg = self:getParam(1)
    self.maxCount = self:getParam(2)
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if killer ~= nil and killer:equal(self.player) then
        if skillConfig ~= nil and skillConfig.anim_name == "skill2" then
            if self.skill1 ~= nil then
                local count = self.skill1:getCurseCount(victim)
                count = GlobalTools:Clamp(count, 0, self.maxCount)
                data.damage = data.damage + GlobalTools:Mul(data.damage, GlobalTools:Mul(self.dmg, GlobalTools:ToFix(count)))
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end
return M