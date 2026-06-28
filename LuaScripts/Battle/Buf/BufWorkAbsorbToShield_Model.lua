--吸收伤害，转化护盾
---@class BufWorkAbsorbToShield_Model : BufWork_Model
---@field super BufWork_Model
local M = class("BufWorkAbsorbToShield_Model", BufWork_Model)


function M:initFinish()
    self.internal = self.playerBuf:checkParam("internal", 0)
    self.convertParam = self.playerBuf:checkParam("convertParam", 0)
    self.buffid = self.playerBuf:checkParam("buffid", 0)
    
    -- 已经吸收的伤害
    self.absorbDamage = 0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    if self.playerBuf.player:equal(data.victim) then     -- 自己受伤
        if self.internal == 0 or self.internal == data.attackData.damageType then
            self.absorbDamage = self.absorbDamage + data.wantdata.damage
            data.wantdata.damage = 0
        end
    end
end

function M:workEnd()
    local player = self.playerBuf.player
    local buffData = player.bufMgr:getBuffCfg(self.buffid)
    if buffData and player.bufMgr:canAddBuff() then
        buffData = table.copy(buffData)   -- 要改变护盾buff的值
        for k,v in ipairs(buffData.param[1]) do
            if v[1] == "shieldParam" then
                v[2] = GlobalTools:Mul(self.absorbDamage, self.convertParam)
            elseif v[1] == "type" then
                v[2] = 3    -- fix 固定值
            end
        end
        player.bufMgr:addBufByData(buffData, self.playerBuf.player, nil, self.buffid, self)
    end
    
    M.super.workEnd(self)
end

function M:stop()
    self.absorbDamage = 0
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.stop(self)
end

return M