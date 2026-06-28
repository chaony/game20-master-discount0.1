--角色的专属装备
--纯阳 场上每有一个被施加了“流血”效果的敌方武神，纯阳便获得5%的暴击率提升  当敌人流血buf消失 或者 死亡 清除效果
---@class W_ChunY_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_ChunY_Trait0", PlayerTrait)

M.critrate = 0
M.list = nil

function M:init()
    M.super.init(self)
    self.critrate = self:getValue(1)  
    self.list = Battle.List.new()
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("removeBuff", {self,self.removeBuffHandler})

end


function M:addBuffHandler(eventName, data)
	local buff = data["buff"]
	if buff ~= nil and buff.playerBuf.player ~= nil and buff.playerBuf.player.camp ~= self.player.camp then
	    if buff.type == "Bleed" then
	    	if self.list:contains(buff.playerBuf.player) == false then
	    		self.list:add(buff.playerBuf.player)
	    		self.player.data.critrate:addToAddList(self.critrate)
	    		self:addCrit()
	    	end
	       
	    end
	end
    
end
function M:removeBuffHandler(eventName, data)
	local buff = data["buff"]
	if buff ~= nil and buff.playerBuf.player ~= nil and buff.playerBuf.player.camp ~= self.player.camp then
	    if buff.type == "Bleed" then
	    	if self.list:contains(buff.playerBuf.player) == true then
	    		local buffs = buff.playerBuf.player.bufMgr:findBufByType("Bleed")
				if table.nums(buffs) <= 1 then
					self.list:remove(buff.playerBuf.player)
	    			self.player.data.critrate:removeFromAddList(self.critrate)
	    			self:removeCrit()
				end
	    		
	    	end
	       
	    end
	end
    
end

function M:addCrit( ... )
	-- body
end

function M:removeCrit( ... )
	-- body
end

function M:destroy()
    EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
     EventDispatcher:unRegisterEvent("removeBuff", {self,self.removeBuffHandler})
    M.super.destroy(self)
end

return M