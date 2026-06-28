--反弹
---@class BufWorkRebound : BufWork_Model
local M = class("BufWorkRebound", BufWork_Model)


function M:initFinish()
    self.type = self.playerBuf:checkParam("type", 1)
    self.time = self.playerBuf:checkParam("time", 0)
    self.damage = self.playerBuf:checkParam("damage", 0)
    self.buffId = self.playerBuf:checkParam("buffId", 0)
    self.curTime = GlobalTools.base0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:update(time)
    M.super.update(self, time)
    self.curTime = self.curTime - time
end

---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    if self.curTime <= 0 then
        local killer = data["killer"]
        local victim = data["victim"]
        local attackType = data["attackData"]["type"]
        local damage = data["wantdata"]["damage"]
        if killer ~= nil and killer.data:checkInvincible(0) == true then
            return
        end
        if killer ~= nil and killer:equal(self.playerBuf.player) == false and victim:equal(self.playerBuf.player) == true and attackType ~= 3 then

            if killer.reboundNum ~= nil and killer.reboundNum > 0 then  -- 有可反伤人数
                local attackData = BattleTool:getBaseAttackData()
                attackData["injureType"] = "buff"
                attackData["sourceBuff"] = self.playerBuf

                local atk = self.playerBuf:getBaseAtk()
                if self.type == 1 then
                    attackData["damage"] = GlobalTools:Mul(self.damage, atk)
                    attackData["player"] = self.playerBuf.source
                elseif self.type == 2 then
                    attackData["damage"] = GlobalTools:Mul(self.damage, damage)
                    attackData["player"] = victim
                end
                attackData["angerAir"] = GlobalTools.base1
                attackData["type"] = 3
                attackData["injureBuf"] = 0
                attackData["damageType"] = 1

                if self.type == 1 then
                    killer:injure(attackData)
                elseif self.type == 2 then
                    local wantdata = {}
                    wantdata["damage"] = attackData["damage"]
                    wantdata["suck_value"]  = 0
                    wantdata["tag"] = self.playerBuf.tag
                    killer:beHitDirect(self.playerBuf.source, attackData, wantdata, false, true)
                end

                if self.buffId ~= 0 then
                    killer.bufMgr:addBufById(self.buffId, self.playerBuf.source)
                end

                killer.reboundNum = killer.reboundNum - 1   -- 反伤人数减1
            end

            self.curTime = self.time
        end
    end
end

function M:stop()
    M.super.stop(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M