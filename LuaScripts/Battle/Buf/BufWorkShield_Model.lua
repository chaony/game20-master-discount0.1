--额外护盾
---@class BufWorkShield : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkShield", BufWork_Model)

M.isWork = true

function M:initFinish()
    local type = self.playerBuf:checkParam("type", 3)
    local param = self.playerBuf:checkParam("shieldParam", 0)
    local convertParam = self.playerBuf:checkParam("convertParam", 1)
    self.value = 0;
    if self.playerBuf.player:get_master() == nil then
         if type == 1 then
            type = "hp"
        elseif type == 2 then
            type = "atk"
        elseif type == 3 then
            type = "fix"
            --转化当前生命值（会扣除生命值）
        elseif type == 4 then
             type = "fix"
             local curHp = Mathf.Max(self.playerBuf.player.data:get_curHp(), GlobalTools.base1)
             param = GlobalTools:Mul( curHp, param)
             self.playerBuf.player.data:set_curHp(self.playerBuf.player.data:get_curHp() - param)
             self.playerBuf.player:calculateTotalLostHp(param)
         elseif type == 5 then --转化当前生命值（会扣除生命值）
             type = "fix"
             local curHp = Mathf.Max(self.playerBuf.player.data:get_curHp(), GlobalTools.base1)
             param = GlobalTools:Mul(curHp, param)
             self.playerBuf.player.data:set_curHp(self.playerBuf.player.data:get_curHp() - param)
             self.playerBuf.player:calculateTotalLostHp(param)
             param = GlobalTools:Mul(param, convertParam) -- 血量和护盾之间的转换比例
         elseif type == 6 then   -- 战斗中实时计算的值(实际使用中，代码会改变这个类型为3fix，理论上不会走这里)
             Logger.logError(self.playerBuf.buffId,"没有改变护盾的数值类型，应该改成3(fix)")
         else
             Logger.logError(self.playerBuf.buffId,"不识别的护盾类型")
         end
        self.value = self.playerBuf.player.data:getGuardValue(self.playerBuf.source, type, param)
        EventDispatcher:dipatchEvent("ShieldValue",{ ply = self.playerBuf.player,shieldValue = self,isStart = true,lastTime = self.playerBuf.lastTime})
    end
    self.isWork = true
    if SceneManager.curScene.collectData then
        SceneManager.curScene.collectData:causeShield(self.playerBuf)
    end
end


function M:get_value()
    return self.value;
end

function M:update(time)
    M.super.update(self, time)
    if self.playerBuf.player:get_master() == nil then
        if self.value <= 0 and self.isWork == true then
            self.playerBuf.player.bufMgr:removeBuf(self.playerBuf)
            self.isWork = false
        end
    end
end

function M:stop()
    M.super.stop(self)
    EventDispatcher:dipatchEvent("ShieldValue",{ ply = self.playerBuf.player,shieldValue = self,isStart = false})
    self.value = 0
end

return M