--明教为自身施加一个护盾，抵挡相当于自身攻击力200%的伤害，
--持续5秒，护盾存在期间，自身提升60点攻速。
---@class W_MingJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MingJ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1) --攻速buf
 	EventDispatcher:registerEvent("ShieldValue", {self,self.ShieldHandler})
end


function M:ShieldHandler(eventName, data)
    local ply = data["ply"]
    local buf = data["shieldValue"]
    local isStart = data["isStart"]
    if buf.playerBuf.player:equal(self.player) then
    	if isStart == true then
	        if buf.value > 0 then
	            self.player.bufMgr:addBufById(self.buffId, self.player)
	        elseif buf.value <= 0 then
	        	self.player.bufMgr:removeBufById(self.buffId, self.player)
	        end
	    elseif isStart == false then
	    	self.player.bufMgr:removeBufById(self.buffId, self.player)
    	end
    end
end


function M:destroy()
    M.super.destroy(self) 
    EventDispatcher:unRegisterEvent("ShieldValue", {self,self.ShieldHandler})
end


return M