---
--- 武当释放真武剑阵时，真武剑阵内的友方侠客受到伤害降低25%
---
local M = class("W_WDang_SkyStar_skill1",SkillSkyStar)


function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.damageReduceBuf = self:getParam(1)
end

--触发开始
function M:triggerStart( data )
    --加入一个 真武剑阵内的友方侠客受到伤害降低25% bufId
    self.player.bufMgr:addBufById(self.damageReduceBuf, self.player);
end

--触发结束
function M:triggerEnd( data )
    
end


return M;