--角色的专属装备
--崆峒 因自身技能受到的负面效果，现在也会同样作用在命中的敌人身上

---@class W_KongT_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_KongT_Trait0", PlayerTrait)


M.buffId = 0
M.buffId2 = 0
function M:init()
    M.super.init(self)
	self.buffId = self:getValue(1) -- skill1的负面buf
    self.buffId2 = self:getValue(2) --skill2的负面buf

	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:injureHandler(eventName, data)

    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]

    if ply ~= nil and ply:equal(self.player) then
        if victim ~= nil then  
            if skillConfig ~= nil then
                if skillConfig.anim_name == "skill1" then
                    victim.bufMgr:addBufById(self.buffId, self.player)
                elseif skillConfig.anim_name == "skill2" then
                    victim.bufMgr:addBufById(self.buffId2, self.player)
                end
            end
        end
           

    end
end



function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end


return M