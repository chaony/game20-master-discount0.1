-- 禁锢 buff
---@class BufWorkImprison : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkImprison", BufWork_Model)

function M:initFinish()
    
    local timeRaiseHpBase = self.playerBuf:checkParam("timeRaiseHpBase", 0)
    local timeRaiseAdd = self.playerBuf:checkParam("timeRaiseAdd", 0)
    if self.playerBuf.player.animator ~= nil then
        local stopAnim = self.playerBuf:checkParam("stopAnim", GlobalTools.base1)
        self.playerBuf.player:setAnimSpeed( stopAnim )
    end
    if timeRaiseHpBase > 0 then
        local hp_Raise = GlobalTools:Mul(self.playerBuf.source.data:get_hp(), timeRaiseHpBase)
        local total_lost_raise = GlobalTools:Div( self.playerBuf.source.totalLostHp, hp_Raise);
        local timeRaiseByHp =  GlobalTools:Mul(total_lost_raise, timeRaiseAdd)
        if timeRaiseByHp > self.playerBuf:checkParam("timeRaiseByHp", 0) then
            timeRaiseByHp = self.playerBuf:checkParam("timeRaiseByHp", 0)
        end

        self.playerBuf.lastTime = self.playerBuf.lastTime + timeRaiseByHp
    end

    if self.playerBuf.source ~= nil and self.playerBuf.source.isUnScale then
        self.playerBuf.player:setUnScale(true)
    end

    if self.playerBuf.player.aiEngine ~= nil and self.playerBuf.player.aiEngine.curState ~= nil then
        if self.playerBuf.player.aiEngine.curState.key ~= "injureMove" then
            --切换ai状态
            self.playerBuf.player.aiEngine:changeState("debuff")
        end
    end
end

function M:stop()
    M.super.stop(self)
    if self.playerBuf.player.animator ~= nil then
        self.playerBuf.player.animator:set_animSpeed( GlobalTools.base1 ) 
    end
    local imprison = self.playerBuf.player.bufMgr:findBufByType("Imprison")
    if table.nums(imprison) == 1 then
        if self.playerBuf.player.aiEngine ~= nil and self.playerBuf.player.aiEngine.curState ~= nil and self.playerBuf.player.aiEngine.curState.key == "debuff" then
            self.playerBuf.player.aiEngine:changeState("move")
        end
    end
end

return M