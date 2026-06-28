--场上每有一个非召唤物单位死亡，血刀便恢复其生命上限的10%

---@class W_XueD_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XueD_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.cureBuff = self:getParam(1)
    self.defBuff = self:getParam(2)
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("PlayerDead", {self,self.playerDeadHandler})
end

function M:playerDeadHandler(eventName, data)
    local ply = data["data"]
    if ply ~= nil and ply:equal(self.player) == false and ply:get_master() == nil  then
        self.player.bufMgr:addBufById(self.cureBuff, self.player)
        self.player.bufMgr:addBufById(self.defBuff, self.player)
    end

end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.playerDeadHandler})
end

return M