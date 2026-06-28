--角色的专属装备
--天策 无双状态下 天策会获得15%的吸血效果

---@class W_TianC_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_TianC_Trait0", PlayerTrait)

M.hp = 0

function M:init()
    M.super.init(self) 
    self.hp = self:getValue(1)  --回血
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
	   		local buffs =buff.playerBuf.player.bufMgr:findBufByTag("W_TianC_skill3")
	    	if table.nums(buffs) > 0 then
	    		buff.playerBuf.player.data.leeching:addToAddList(self.hp)
	    	end
	    	
	    end
	end
    
end
function M:removeBuffHandler(eventName, data)
	local buff = data["buff"]
	if buff ~= nil and buff.playerBuf.player ~= nil and buff.playerBuf.player.camp == self.player.camp then
	    if buff.playerBuf.source:equal(self.player) then
    		local buffs = buff.playerBuf.player.bufMgr:findBufByTag("W_TianC_skill3")
			if table.nums(buffs) <= 0 then
    			self.player.data.leeching:removeFromAddList(self.hp)
			end
	    end
	end
    
end


function M:destroy()
    EventDispatcher:unRegisterEvent("removeBuff", {self,self.removeBuffHandler})
    EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
    M.super.destroy(self)

end

return M