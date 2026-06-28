--金刚的防御力现在会上升10%乘以骰子点数的数值
local W_JinG_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_JinG_skill1_1_Model")
---@class W_JinG_skill1_2_Model : W_JinG_skill1_1_Model @
---@field super W_JinG_skill1_1_Model @W_JinG_skill1_1_Model
local M = class("W_JinG_skill1_2_Model", W_JinG_skill1_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.def = self:getParam(2)
end

--角色出生结束
function M:spawnFinish()
    M.super.spawnFinish(self)
    local def_value = GlobalTools:Mul(self.def, GlobalTools:ToFix(self.selfPoint))
    self.player.data.def:addToMulList(def_value)
end


function M:destroy()
    M.super.destroy(self)
end

return M