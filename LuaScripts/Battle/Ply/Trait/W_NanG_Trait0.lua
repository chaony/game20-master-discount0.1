--角色的专属装备
--南宫 战斗中 当南宫的血量低于50%时，会立即释放一次必杀技，且本次必杀技不消耗能量

---@class W_NanG_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_NanG_Trait0", PlayerTrait)

M.hp = 0
M.start = false

function M:init()
    M.super.init(self) 
    self.hp = self:getValue(1)  --回血
    self.start = false
end

function M:spawn()
    M.super.spawn(self)
 	EventDispatcher:registerEvent("selfHp", {self,self.conditionHandler})
end

--条件触发
function M:conditionHandler( eventName, data )
    local player = data["ply"]
   if self.player:equal(player) and self.player.data:get_curHp() >0 then 
	   if self.start == false  then
	   		local hpPercent = self.player.data:get_hp() * self.hp
	        if  self.player.data:get_curHp() <= hpPercent  then
	            local skill3 = self.player.plySkill:getSkillByName("skill3")  
	            self.player:set_curSkillConfig(skill3.cur_skill_config)
	            self.player.skill3ClearAnger = false
	            self.player.aiEngine:changeState("skill")
	            self.player.skill3ClearAnger = true
	            self:alterValue()
	            self.start  = true
	        end
	   end               
        
        
    end
end

function M:alterValue( ... )
	-- body
end

function M:destroy()
     EventDispatcher:unRegisterEvent("selfHp", {self,self.conditionHandler})
    M.super.destroy(self)
    self.start = false
end

return M