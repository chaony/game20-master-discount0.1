--回血buff
---@class BufWorkAddBlood : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkAddBlood", BufWork_Model)

function M:initFinish()

    self.curblood = self.playerBuf:checkParam("curBlood", 0)
    self.curAtkblood = self.playerBuf:checkParam("curAtkBlood", 0)
    self.curLostBlood = self.playerBuf:checkParam("curLostBlood", 0)
    
    self.lostBlood = self.playerBuf:checkParam("lostBlood", 0)
    self.lostBlood_init = self.playerBuf.player.data:get_hp() - self.playerBuf.player.data:get_curHp()
    --只有第一次显示回血数字
    self.showHpLabel = true
end

function M:work()
    M.super.work(self)
    
    if self.curblood > 0 then
        self.playerBuf.player:cure("hp", self.playerBuf.source, self.curblood, self.playerBuf.sourceSkill, self.showHpLabel == false, self.playerBuf)
    end
    if self.curAtkblood > 0 then
        self.playerBuf.player:cure("atk", self.playerBuf.source, self.curAtkblood, self.playerBuf.sourceSkill, self.showHpLabel == false, self.playerBuf)
    end
    if self.curLostBlood > 0 then
        local hp_cha = self.playerBuf.player.data:get_hp() - self.playerBuf.player.data:get_curHp()
        local lostBlood = GlobalTools:Mul(hp_cha, self.curLostBlood)
        self.playerBuf.player:cure("fix", self.playerBuf.source, lostBlood, self.playerBuf.sourceSkill, self.showHpLabel == false, self.playerBuf)
    end
    if self.lostBlood > 0 then
        local lostBlood = GlobalTools:Mul(self.lostBlood_init, self.lostBlood)
        self.playerBuf.player:cure("fix", self.playerBuf.source, lostBlood, self.playerBuf.sourceSkill, self.showHpLabel == false, self.playerBuf)
    end
    self.showHpLabel = false
end

return M