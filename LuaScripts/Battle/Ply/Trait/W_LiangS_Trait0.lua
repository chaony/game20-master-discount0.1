--角色的专属装备
--梁山 必杀技造成的伤害20% 会转换为自身的血量
---@class W_LiangS_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_LiangS_Trait0", PlayerTrait)


--百分比
M.cure = nil


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cure = self:getValue(1)
end

function M:spawn()
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:injureHandler(eventName, data)

    local ply = data["killer"]
    local skillConfig = data["attackData"]["skillConfig"]
    local wantdata = data["wantdata"]
    local dmg = wantdata["damage"]
    if ply ~= nil and ply:equal(self.player) then
        if skillConfig ~= nil and skillConfig.anim_name == "skill3" then
            self.player:cure("fix", self.player, dmg * self.cure)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
   
end
return M