---
--- 荡尽重魔将缴械被命中的敌人，持续2s（缴械，无法攻击和使用技能）
---
local M = class("W_BeiMSZ_SkyStar_skill1",SkillSkyStar)


function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --缴械，无法攻击和使用技能
    self.bufId = self:getParam(1)
end

--触发开始
function M:triggerStart( data )
    --data 被攻击到的敌人
    if data ~= nil then
        data.bufMgr:addBufById(self.bufId, self.player)
    end
end

--触发结束
function M:triggerEnd( data )
    
end


return M;