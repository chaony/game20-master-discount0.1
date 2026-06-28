--吸血增强下次攻击
---@class BufWorkBloodThirsty : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkBloodThirsty", BufWork_Model)

--function M:initFinish()
--    local cur_hp = self.playerBuf.player.data:get_curHp();
--    local hp = GlobalTools:Mul( cur_hp, self.playerBuf:checkParam("hp",0) )
--    self:dispatchEvent_Local(Battle.EventType.MV_BufWorkBloodThirstyShowHitLable, hp);
--    self.playerBuf.player.data:set_curHp(cur_hp - hp)
--    self.stashHp = hp
--    self.rate = self.playerBuf:checkParam("rate",0)
--end

function M:reset(  )
    M.super.reset(self)
    local cur_hp = self.playerBuf.player.data:get_curHp();
    local hp = GlobalTools:Mul( cur_hp, self.playerBuf:checkParam("hp",0) )
    self:dispatchEvent_Local(Battle.EventType.MV_BufWorkBloodThirstyShowHitLable, GlobalTools:ToFloat(hp));
    self.playerBuf.player.data:set_curHp(cur_hp - hp)
    self.stashHp = hp
    self.rate = self.playerBuf:checkParam("rate",0)
end

function M:GetValue()
    self.playerBuf.player.bufMgr:removeBufByType("BufWorkBloodThirsty")
    return GlobalTools:Mul(self.stashHp, self.rate)
end

return M