--角色的专属装备
--鬼谷 
--若鬼谷击杀了施加有诛邪印机的敌人，会为全体队友回复相当于鬼谷生命值300%攻击力的血量
---@class W_GuiG_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_GuiG_Trait0", PlayerTrait)


M.hp = 0
function M:init()
    M.super.init(self)
    self.buff = self:getValue(1)
     EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})

end

--死亡回调
function M:deadHandler( eventName, data )
    local player = data["data"]
    if player.killer:equal(self.player) then
        local guigu_skill3 = player.bufMgr:findBufByTag("guigu_skill3")
        if table.nums(guigu_skill3) > 0 then
            local enemys = self.player.plyMgr:getPlayers(self.player:get_camp())
            for i = enemys.Count, 1, -1 do
                local enemy_player = enemys:get(i-1)

                enemy_player.bufMgr:addBufById(self.buff, self.player)

                self:restValue(enemy_player)
            end
        end

    end

end

function M:restValue( enemy_player )
    -- body
end
function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

return M