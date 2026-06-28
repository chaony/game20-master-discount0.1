--场上任意武神死亡时，幽魂魅影便恢复最大生命值的10%
---@class W_GuM1_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuM1_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureBuff = self:getParam(1)
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})

end

function M:killPlayerHandler(eventName, data)
    local victim = data["victim"]
    local killer = data["killer"]
    if victim.master == nil then
        self.player.bufMgr:addBufById(self.cureBuff, self.player)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
    M.super.destroy(self)
end

   

return M