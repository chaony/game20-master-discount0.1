---
--- 若“弦迸雁落”技能造成了暴击，额外释放时会命中敌方全体目标，且造成每秒50%攻击力的伤害，持续5秒
---
local M = class("W_HuaR_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.buffId = self:getParam(1, 0)  -- Buff[] 沉默buff
end


function M:triggerStart()
    local enemys = self:getTarget("enemy", "all")
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        if enemy.bufMgr then
            enemy.bufMgr:addBufById(self.buffId, self.player)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;