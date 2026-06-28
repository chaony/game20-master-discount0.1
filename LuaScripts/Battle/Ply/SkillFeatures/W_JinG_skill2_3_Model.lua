
--该技能造成伤害的30%会转化为自身血量
local W_JinG_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_JinG_skill2_1_Model")

---@class W_JinG_skill2_3_Model : W_JinG_skill2_1_Model @
---@field super W_JinG_skill2_1_Model @W_JinG_skill2_1_Model
local M = class("W_JinG_skill2_3_Model", W_JinG_skill2_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.hpRate = self:getParam(3)
end

function M:injureHandler(eventName, data)
    M.super.injureHandler(self, eventName, data)
    if self.skill1 ~= nil then
        local ply = data["killer"]
        local victim = data["victim"]
        local skillConfig = data["attackData"]["skillConfig"]
        local wantdata = data["wantdata"]
        if victim ~= nil then
            if skillConfig ~= nil and skillConfig.anim_name == "skill2" then
                if self.player:equal(ply) then
                    self.player:cure("fix", self.player, GlobalTools:Mul(wantdata.damage, self.hpRate), self.skill)
                end
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M