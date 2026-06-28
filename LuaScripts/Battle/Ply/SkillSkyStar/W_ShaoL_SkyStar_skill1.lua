--不坏金身：战斗中少林获得的所有护盾值提升30%，自身存在护盾时，受到的伤害减少35%

---@class W_ShaoL_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_ShaoL_SkyStar_skill1",SkillSkyStar)

function M:init( player, param, level )
    M.super.init(self,player, param, level )
    self.addShiledValue = self:getParam(1)
    self.buffId = self:getParam(2)
    EventDispatcher:registerEvent("ShieldValue", {self,self.ShieldHandler})
end

function M:ShieldHandler(eventName, data)
    local ply = data["ply"]
    local buf = data["shieldValue"]
    local isStart = data["isStart"]
    if isStart == true then
        if buf.value > GlobalTools.base0 then
            if buf ~= nil then
                if buf.playerBuf.player:equal(self.player) then
                    buf.value = GlobalTools:Mul( buf.value, (GlobalTools.base1 + self.addShiledValue) )
                    self.player.bufMgr:addBufById(self.buffId, self.player)
                end
            end
        elseif buf.value <= GlobalTools.base0 then
            self.player.bufMgr:removeBufById(self.buffId)
        end
    elseif isStart == false then
        self.player.bufMgr:removeBufById(self.buffId)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("ShieldValue", {self,self.ShieldHandler})
    M.super.destroy(self)
end
return M;