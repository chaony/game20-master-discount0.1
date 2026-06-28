--潘金莲被击败时，所有男性角色恢复200点怒气

---@class W_PanJL_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_PanJL_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.buffId = self:getParam(1, 0)
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

---@param eventData Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, eventData)
    if self.player:equal(eventData.victim) then
        local men = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend", gender = "man", ignoreSummon = true})
        for i = 1, men.Count do
            local man = men:get(i - 1)
            if man.bufMgr then
                man.bufMgr:addBufById(self.buffId, self.player)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    M.super.destroy(self)
end

return M;