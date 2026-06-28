--绝情被动
--在自身周围召唤结界，结界内的敌人受到的所有内力恢复效果会降低40% 敌人首次尝试出入结界的时候 会受到200%攻击力的伤害和2秒眩晕
--结界内的敌人换回降低50%的血量恢复效果
--当我方英雄被击杀时，立即为击杀者添加5层绝杀印
local W_JueQ_skill0_2_Model = require("Battle.Ply.SkillFeatures.W_JueQ_skill0_2_Model")
---@class W_JueQ_skill0_3_Model : W_JueQ_skill0_2_Model @
---@field super W_JueQ_skill0_2_Model @W_JueQ_skill0_2_Model
local M = class("W_JueQ_skill0_3_Model", W_JueQ_skill0_2_Model)


--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId5 = self:getParam(6) --绝杀印机
 	EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end


--死亡回调
function M:deadHandler( eventName, data )
    local player = data["data"]
    if player:equal(self.player) == false then
    	if player.camp == self.player.camp then
    		if player.killer_player ~= nil then
    			for i=1,5 do
    				player.killer_player.bufMgr:addBufById(self.buffId5, self.player) --绝杀印机
    			end
    			
    		end
    	end
    end
end


--销毁
function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

   

return M