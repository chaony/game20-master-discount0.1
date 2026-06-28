--角色的专属装备
--峨眉
--峨眉的每次普工都会为自身叠加一层强化buf，每层buf提高自身攻击力3%，最多叠加10层
---@class W_EM_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_EM_Trait0", PlayerTrait)


M.maxCount = 0
M.atk = 0
M.count = 0
function M:init()
    M.super.init(self)
    self.atk = self:getValue(1)
    self.maxCount = self:getValue(2)
   	self.count = 0
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]


    if self.player:equal(ply) and config ~= nil then
      if config.anim_name == "attack1" then
         self.count = self.count + 1 
         if self.count >= self.maxCount then
         	self.count = self.maxCount
         	self:rest_Change()
         end
         self.player.data.atk:addToMulList(self.count * self.atk )
      end
        
    end
end

function M:rest_Change()
	-- body
end



function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
end

return M