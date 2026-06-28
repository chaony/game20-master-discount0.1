-- 若该技能成功击杀了敌人，则会额外释放一次，最多额外释放2次
local W_CangJ_skill0_2_Model = require("Battle.Ply.SkillFeatures.W_CangJ_skill0_2_Model")
---@class W_CangJ_skill0_3_Model : W_CangJ_skill0_2_Model @
---@field super W_CangJ_skill0_2_Model @W_CangJ_skill0_2_Model
local M = class("W_CangJ_skill0_3_Model", W_CangJ_skill0_2_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.use = false
    self.count = 0
    self.maxCount = self:getParam(1)
end

--杀死敌人
function M:killPlayer(data)
    local skillConfig = data.attackData["skillConfig"]
    if skillConfig ~= nil and skillConfig.anim_name == "skill2" then
        if self.count < self.maxCount then
            self.use = true
            self.count = self.count + 1
        end
    end
end

--技能结束
function M:skillEnd(data)
    if self.use == true and self.player.aiEngine ~= nil then
        self.player.aiEngine.skillConfig = self.skill
        self.use = false
        return "attack"
    else
        self.count = 0
    end
end

return M