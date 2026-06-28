--"玄天星降：
--持有此技能的侠客上场时，提升友方全体侠客3%最终伤害"

---@class W_HeH_SkyStar_skill2 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_HeH_SkyStar_skill2",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    
    --全体侠客3%最终伤害
    self.damageRateBuf = self:getParam(1, 0)    --Buff[]
end

function M:gameStart()
    --提升友方全体侠客3%最终伤害
    local allPlys = self:getTarget("self","all")
    for i = 1, allPlys.Count do
        local ply = allPlys:get(i-1)
        if ply.master == nil then
            ply.bufMgr:addBufById(self.damageRateBuf, self.player)
        end
    end
end

return M;