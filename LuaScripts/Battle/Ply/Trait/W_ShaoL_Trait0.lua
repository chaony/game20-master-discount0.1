--角色的专属装备
--少林 被少林的技能“佛光普照”施加了护盾的友军，在护盾的持续时间内，因受伤恢复能量增加20%

---@class W_ShaoL_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_ShaoL_Trait0", PlayerTrait)

M.hurtrageregen = 0


function M:init()
    M.super.init(self) 
    self.hurtrageregen = self:getValue(1)  --回血
    
end

function M:spawn()
    M.super.spawn(self)
 	EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("removeBuff", {self,self.removeBuffHandler})

end


function M:addBuffHandler(eventName, data)
	local buff = data["buff"]
	if buff ~= nil and buff.playerBuf.player ~= nil and buff.playerBuf.player.camp == self.player.camp then
	    if buff.playerBuf.source:equal(self.player) then
	    	if buff.type == "Shield" then
	    		buff.playerBuf.player.data.hurtrageregen:addToAddList(self.hurtrageregen)
	    	end
	    	
	    end
	end
    
end

function M:removeBuffHandler(eventName, data)
	local buff = data["buff"]
	if buff ~= nil and buff.playerBuf.player ~= nil and buff.playerBuf.player.camp == self.player.camp then
	    if buff.playerBuf.source:equal(self.player) then
	    	if buff.type == "Shield" then
	    		buff.playerBuf.player.data.hurtrageregen:removeFromAddList(self.hurtrageregen)
	    	end
	    end
	end
    
end

function M:destroy()
    EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("removeBuff", {self,self.removeBuffHandler})
    M.super.destroy(self)
end

return M