--角色的专属装备
--八卦只要3秒内自己没有受到伤害，则伤害提升20%
---@class W_BaG_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_BaG_Trait0", PlayerTrait)

M.time = 0
M.atk = 0
function M:init()
    M.super.init(self)
    self.buff = self:getValue(1)
   -- EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawn()
    M.super.spawn(self)
    self.player.bufMgr:addBufById(self.buff, self.player)
	--self.time = 3 + TimeManager:time()
end

-- function M:killerDataChangeTemp(victim)
-- 	M.super.killerDataChangeTemp(victim)

-- 	--if self.time < TimeManager:time() then
-- 		self.player.data.atk:addToMulListTemp(self.atk)
--         self:restsCondition(victim)
-- 	--end
-- end

--function M:restsCondition(victim)
--	-- body
--end
--
--function M:injureHandler(eventName, data)
--
--    local ply = data["victim"]
--    local killer = data["killer"]
--    if ply:equal(self.player) == true then
--		self.time = 3 + TimeManager:time()       
--    end
--end


function M:destroy()
  --  EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})

    M.super.destroy(self)
end

return M