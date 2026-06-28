--角色的专属装备
--纯阳 场上每有一个被施加了“流血”效果的敌方武神，纯阳便获得5%的暴击率提升  当敌人流血buf消失 或者 死亡 清除效果
--当被施加流血效果的敌方武神死亡时，纯阳便获得5%的暴击率和10%的暴击伤害提升该效果会一直持续到战斗结束
local W_ChunY_Trait1 = require("Battle.Ply.Trait.W_ChunY_Trait1")

---@class W_ChunY_Trait2 : W_ChunY_Trait1 @
---@field super W_ChunY_Trait1 @W_ChunY_Trait1
local M = class("W_ChunY_Trait2", W_ChunY_Trait1)



M.buff = 0


function M:init()
    M.super.init(self)
    self.buff = self:getValue(3)  
    
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("PlayerDead", {self,self.playerDeadHandler})
   

end


function M:playerDeadHandler(eventName, data)
	local ply = data["data"]

	if ply ~= nil and ply.camp ~= self.player.camp  then
		local buffs = ply.bufMgr:findBufByType("Bleed")
		if table.nums(buffs) > 0 then
			self.player.bufMgr:addBufById(self.buff, self.player)
		end
	end

end



function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.playerDeadHandler})
    M.super.destroy(self)
end

return M