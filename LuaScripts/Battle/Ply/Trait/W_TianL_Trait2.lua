--角色的专属装备
--天龙
--大招持续期间，天龙会获得25%的吸血效果
--大招持续期间，每击杀一个敌人，大招持续时间就延长1秒

local W_TianL_Trait1 = require("Battle.Ply.Trait.W_TianL_Trait1")

---@class W_TianL_Trait2 : W_TianL_Trait1 @
---@field super W_TianL_Trait1 @W_TianL_Trait1
local M = class("W_TianL_Trait2", W_TianL_Trait1)



function M:init()
    M.super.init(self)
    
   
  EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})

end

--死亡回调
function M:deadHandler( eventName, data )
    local player = data["data"]
    if player.killer ~= nil and player.killer:equal(self.player) then
        local tianlong_skill3 = player.bufMgr:findBufByTag("tianlong_skill3")
        if table.nums(tianlong_skill3) > 0 then
            for k,v in ipairs(tianlong_skill3) do
                v.curLastTime = v.curLastTime + 1
            end
        end
    end
end

function M:destroy()
  M.super.destroy(self)
  EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end



return M