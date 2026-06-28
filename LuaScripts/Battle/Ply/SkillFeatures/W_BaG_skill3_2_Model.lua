---@class W_BaG_skill3_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaG_skill3_2_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    EventDispatcher:registerEvent("critCount", {self,self.critHandler})
end

--发生暴击
function M:critHandler( eventName, data )
    local ply = data["ply"]
    if ply:equal(self.player) then
        if self.player.animator.loopCount > 0 then
            if self.player.animator.curExtraLoopCount < self.player.animator.extraLoopCount then
                self.player.animator.loopCount = self.player.animator.loopCount + 1
                self.player.animator.curExtraLoopCount = self.player.animator.curExtraLoopCount + 1
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("critCount", {self,self.critHandler})
end

return M