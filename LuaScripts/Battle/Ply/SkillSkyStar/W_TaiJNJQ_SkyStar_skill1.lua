--"无量慈悲：极阴印记爆炸时附加一次3秒内无法使用技能，此效果10秒内只能触发一次
---@class W_TaiJNJQ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_TaiJNJQ_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.chenMoBuff = self:getParam(1)
    self.chenMoCd = self:getParam(2)
    self.canUse = true
end

function M:triggerStart(victim)
    if self.canUse and victim and victim.bufMgr then
        self.canUse = false
        victim.bufMgr:addBufById(self.chenMoBuff, self.player)
        TimeTools:delayTime(self.chenMoCd, function()
            self.canUse = true
        end)
    end
end

return M;