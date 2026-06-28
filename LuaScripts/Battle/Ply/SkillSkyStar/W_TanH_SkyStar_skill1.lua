--"冷血无情：
--现在，探花的普攻可以攻击一条直线上的所有单位。"

---@class W_TanH_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_TanH_SkyStar_skill1", SkillSkyStar)

---@param evtFrame AnimEvtFrame_Model
---@param data Battle_Frame_Data_Event_Shoot
function M:shootFrame(evtFrame, data)
    if self.player:equal(evtFrame.player) and evtFrame.evtAction.animName == "skill1" then
        data.puncturedmg = true
    end
end

return M;