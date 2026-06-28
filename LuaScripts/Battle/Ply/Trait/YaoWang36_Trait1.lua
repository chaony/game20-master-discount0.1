--药王角色的专属装备

--普通攻击时会治疗最虚弱的友军，使其恢复自己攻击力60%的生命值
--普通攻击如果暴击了，则此次治疗的回复效果提升75%

--新：药王造成和受到的所有治疗效果提升15%
local YaoWang36_Trait0 = require("Battle.Ply.Trait.YaoWang36_Trait0")


---@class YaoWang36_Trait1 : YaoWang36_Trait0 @
---@field super YaoWang36_Trait0 @YaoWang36_Trait0
local M = class("YaoWang36_Trait1", YaoWang36_Trait0)



function M:init()
    M.super.init(self) 
    self.hpRecover = self:getValue(1) 
    self.cureRate = self:getValue(2) 
end



-- function M:spawn()
--     M.super.spawn(self)
--     EventDispatcher:registerEvent("critCount", {self,self.critHandler})
    
-- end
  
-- function M:critHandler( eventName, data )
    
--     local ply = data["ply"]
--     local victim = data["victim"]
--     if ply:equal(self.player) then
--         if ply.animator.curState.name == "attack1" then
--             self.hp = self:getValue(1) 
--         end
--     end
-- end


-- function M:destroy()
--     M.super.destroy(self)
--     EventDispatcher:unRegisterEvent("critCount", {self,self.critHandler})
-- end

 

return M