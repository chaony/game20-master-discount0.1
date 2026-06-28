--命中的敌人没有一层霜羽状态，还会使其受到的伤害增加10%，持续5秒

---@class W_WuZT_skill3_plus_4_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WuZT_skill3_plus_4_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffId = self:getParam(1)
end

function M:skillEnd(data)
    local targets = SelectTargetUtil:findPlayerByParam(self.player, { camp = "enemy", ignoreSummon = true, priority = true})
    for i = 1, targets.Count do
        local player = targets:get(i - 1)
        if player and player.bufMgr then
            local buffs = player.bufMgr:findBufByTag("W_WuZT_skill2_plus")
            local buffNums = #buffs
            for j = 1, buffNums do
                player.bufMgr:addBufById(self.buffId, self.player, self.skill)
            end
        end
    end
end

--销毁
function M:destroy()
    M.super.destroy(self)
end

return M
