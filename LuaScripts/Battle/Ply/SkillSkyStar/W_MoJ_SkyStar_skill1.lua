---
--- 墨家释放机关天罗时，从场外向敌方阵地发射2枚特制燃烧弹
--- 燃烧弹将随机锁定两个目标，造成自身攻击力200%的范围伤害和裂伤效果，被命中的目标将昏迷1s
---
local M = class("W_MoJ_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
end

--触发开始
function M:triggerStart( data )
    -- 获取到公共的 Hit 时间，开始执行
    local frame = self.player.evtMgr:getCommonEvent("Hit",1)
    if frame ~= nil then
        frame:work()
    end
end


return M;