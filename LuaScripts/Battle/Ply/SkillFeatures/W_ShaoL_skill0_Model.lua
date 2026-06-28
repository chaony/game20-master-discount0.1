--少林被动 战斗中 少林获得的护盾值提升20%  当自身存在护盾时，受到的伤害会减少50%
---@class W_ShaoL_skill0_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShaoL_skill0_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.shiled = self:getParam(1)
    self.buffId = self:getParam(2)
end


function M:spawn()
    M.super.spawn(self)
   EventDispatcher:registerEvent("ShieldValue", {self,self.ShieldHandler})
end


function M:ShieldHandler(eventName, data)
    if self.player.skyStar then
    else
        local ply = data["ply"]
        local buf = data["shieldValue"]
        local isStart = data["isStart"]
        if isStart == true then
            if buf.value > GlobalTools.base0 then
                if buf ~= nil then
                    if buf.playerBuf.player:equal(self.player) then
                        buf.value = GlobalTools:Mul( buf.value, (GlobalTools.base1 + self.shiled) )
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
end

function M:destroy()
    M.super.destroy(self) 
    EventDispatcher:unRegisterEvent("ShieldValue", {self,self.ShieldHandler})
end

return M