--- 福泽
--- 对己方目标使用护盾回血类技能，50%概率可以移除目标身上1个的负面效果
---@class TalismanFuZe : Talisman
---@field super Talisman
local M = class("TalismanFuZe", Talisman)

function M:init(player,data)
    M.super.init(self,player,data)
    self.radomValue = self:getParam(1); --几率
    self.removeNums = self:getParam(2); --数量
    EventDispatcher:registerEvent("cure", {self,self.cureHandler})
    EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})

end

---@param eventData Battle_HandleData_Cure
function M:cureHandler(eventName, eventData)
    if self.player:equal(eventData.player) then
        for i = 1, self.removeNums do
            if data.victim.bufMgr:removeRandomOneBufByTag("debuff", false) == 0 then
                break   -- 没有debuff，可以中断逻辑
            end
        end
    end
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and buff.playerBuf.player ~= nil and buff.playerBuf.player.camp == self.player.camp then
        if buff.playerBuf.source:equal(self.player) then
            if buff.type == "Shield" then
                for i = 1, self.removeNums do
                    if data.victim.bufMgr:removeRandomOneBufByTag("debuff", false) == 0 then
                        break   -- 没有debuff，可以中断逻辑
                    end
                end
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("cure", {self,self.cureHandler})
    EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
    M.super.destroy(self)
end
return M;