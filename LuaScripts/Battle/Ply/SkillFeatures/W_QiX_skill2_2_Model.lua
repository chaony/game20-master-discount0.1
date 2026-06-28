
local W_QiX_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_QiX_skill2_1_Model")
---@class W_QiX_skill2_2_Model : W_QiX_skill2_1_Model @
---@field super W_QiX_skill2_1_Model @W_QiX_skill2_1_Model
local M = class("W_QiX_skill2_2_Model", W_QiX_skill2_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end


function M:spawn()
    M.super.spawn(self)
end


function M:destroy()
	M.super.destroy(self)
end

return M
