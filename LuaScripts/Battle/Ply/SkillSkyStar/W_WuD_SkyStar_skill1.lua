--尸腐毒：
--五毒对中毒的敌方侠客造成额外15%的伤害，且场上每有一名中毒的敌方侠客，五毒的内力回复每秒提高10点。

---@class W_WuD_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_WuD_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.extraDmg = self:getParam(1, 0)   --Fix[0-1] 额外伤害比例
    self.addAnger = self:getParam(2, 0)   --Fix[0-20] 内力回复点数

    self.angerTimer = TimeTools:startOneLoopTask(GlobalTools.base1, handler(self, self.onAngerTick))
end

-- 每秒恢复内力
function M:onAngerTick()
    local addAnger = 0
    local targets = self:getTarget("enemy", "all")
    for i = 1, targets.Count do
        local ply = targets:get(i-1)
        if ply:isXiaKe() and ply.bufMgr:hasBufByTag("zhongdu") then
            addAnger = addAnger + self.addAnger
        end
    end
    if addAnger > 0 then
        self.player.data:addAnger(addAnger, true)
    end
end

function M:update(time)
    self.angerTimer:update_dt(time)
end

--攻击结束
function M:attackOver(victim, killer, wantdata)
    if victim.bufMgr:hasBufByTag("zhongdu") then
        wantdata.damage = wantdata.damage + GlobalTools:Mul(wantdata.damage, self.extraDmg) -- 额外伤害
    end
end

return M;