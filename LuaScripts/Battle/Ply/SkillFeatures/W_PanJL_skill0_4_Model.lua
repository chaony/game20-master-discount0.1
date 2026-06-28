--受到致死伤害时，潘金莲会优先瞬移至己方前排角色身后，且给予的减伤效果提升至40%

local W_PanJL_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_PanJL_skill0_1_Model")

---@class W_PanJL_skill0_4_Model : W_PanJL_skill0_1_Model @
---@field super W_PanJL_skill0_1_Model @W_PanJL_skill0_1_Model
local M = class("W_PanJL_skill0_4_Model", W_PanJL_skill0_1_Model)

function M:getAttackMoveFrame()
    return self.player.evtMgr:getCommonEventByKey("AttackMove", 2)
end

return M