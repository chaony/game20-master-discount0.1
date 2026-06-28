--密宗    金轮返生
-- 等级3：密宗离开战场时,会清除全体友方侠客的控制效果并免疫3秒,且重回战场所需的时间缩短至6秒 父类实现

local W_MiZ_skill1_2_Model = require("Battle.Ply.SkillFeatures.W_MiZ_skill1_2_Model")

---@class W_MiZ_skill1_3_Model : W_MiZ_skill1_2_Model @
---@field super W_MiZ_skill1_2_Model @W_MiZ_skill1_2_Model
local M = class("W_MiZ_skill1_3_Model", W_MiZ_skill1_2_Model)

return M