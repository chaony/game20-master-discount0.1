--武则天在开场时会对攻击力最高的敌人沉默3秒

---@class W_WuZT_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_WuZT_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    
    --沉默3秒
    self.buffId = self:getParam(1, 0)    --Buff[]
end

function M:triggerStart(data)
    --提升友方全体侠客3%最终伤害
    local enemies = SelectTargetUtil:findPlayerByParam(self.player, {
        camp = "enemy",
        ignoreSummon = true,
        pos = "forceMax",
        --priority = true,
    })
    local ememy = enemies:get(0)
    if ememy and ememy.bufMgr then
        ememy.bufMgr:addBufById(self.buffId, self.player)
    end
end
return M;