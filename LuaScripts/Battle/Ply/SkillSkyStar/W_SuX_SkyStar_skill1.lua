--“殺禪”状态击杀单位，蘇袖会回复10%最大生命值，并增加“殺禪”2秒持续时间

---@class W_SuX_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_SuX_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --回血buffid
    self.buffId = self:getParam(1, 0)
    --增加时间
    self.addTimes = self:getParam(2, 0)   
end

function M:triggerStart()
    self.player.bufMgr:addBufById(self.buffId, self.player)
    local buffs = self.player.bufMgr:findBufByTag("SuX_skill3") --eventData.buff:addLastTime(self.addTime)
    for i, v in ipairs(buffs) do
        v:addLastTime(self.addTimes)
    end
end

return M;