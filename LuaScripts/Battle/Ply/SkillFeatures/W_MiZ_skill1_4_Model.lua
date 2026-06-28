--密宗    金轮返生
-- 开场时给己方阴系侠客增加密宗自身的20%内伤减免,涅槃后追加30%

local W_MiZ_skill1_3_Model = require("Battle.Ply.SkillFeatures.W_MiZ_skill1_3_Model")

---@class W_MiZ_skill1_4_Model : W_MiZ_skill1_3_Model @
---@field super W_MiZ_skill1_3_Model @W_MiZ_skill1_3_Model
local M = class("W_MiZ_skill1_3_Model", W_MiZ_skill1_3_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

return M