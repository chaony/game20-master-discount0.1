--南宫被动
--当南宫受到致命伤害时，会冲到击杀自己的地方角色面前，击飞沿途的橘色并对其造成300%攻击力的伤害，对击杀自己的橘色造成500%的攻击力伤害
--击杀南宫的角色将在后续的30秒内无法恢复能量
local W_NanG_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_NanG_skill0_1_Model")
---@class W_NanG_skill0_2 : W_NanG_skill0_1_Model @
---@field super W_NanG_skill0_1_Model @W_NanG_skill0_1_Model
local M = class("W_NanG_skill0_2", W_NanG_skill0_1_Model)


function M:init(ply, skill,className)
   M.super.init(self, ply, skill,className)
   self.buffId6 = self:getParam(6)--无法恢复能量
   EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end

--死亡回调
function M:deadHandler( eventName, data )
    local player = data["data"]
    if player ~= nil and player:equal(self.player) then
        if player.killer_player ~= nil then
            if player.killer_player.isBoss == false then
                player.killer_player.bufMgr:addBufById(self.buffId6, self.player) --无法恢复能量
            end
        end  
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

   

return M