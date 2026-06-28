--紅蝶天紋斬释放时若敵人身上有“蝶焰”效果，則該技能必定暴击
---@class W_HuDJ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_HuDJ_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
end

--触发开始
---@param data Battle_HandleData_Attack
function M:triggerStart(data)
    if data then
        data.mustCrit = true
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;