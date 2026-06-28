--皇家御令：
--被施加“悬赏”标记的敌方侠客神志受到六扇威慑，缴械2秒。

---@class W_LiuS_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_LiuS_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.addBuff1 = self:getParam(1, 0)   --Buff[]
    EventDispatcher:registerEvent("add_W_LiuS_skill1", {self,self.addBuffHandler})
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    local buff = eventData["buff"]
    if buff ~= nil and buff.player and self.player:equal(buff.source) then
        buff.player.bufMgr:addBufById(self.addBuff1, self.player)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_LiuS_skill1", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M;