--角色的专属装备
--七秀 释放大招后，七秀会立即获得100点内力
---@class W_QiX_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_QiX_Trait0", PlayerTrait)


M.anger = 0
function M:init()
    M.super.init(self)
    self.buff = self:getValue(1)
     EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end


--技能释放
function M:SkillEndHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    if ply == self.player  and ply:isLive() == true then
        if config ~= nil then  
            if config.anim_name == "skill3" then
                self.player.bufMgr:addBufById(self.buff, self.player)
            end
        end
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})

    M.super.destroy(self)
end

return M