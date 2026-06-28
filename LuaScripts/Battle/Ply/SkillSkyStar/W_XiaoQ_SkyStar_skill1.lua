--天香领域额外提供60点坚韧

---@class W_XiaoQ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_XiaoQ_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --坚韧
    self.buffId = self:getParam(1)
    EventDispatcher:registerEvent("remove_W_XiaoQ_Skill2", {self,self.removeBuffHandler})
    EventDispatcher:registerEvent("add_W_XiaoQ_Skill2", {self,self.addBuffHandler})
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        local player = buff.player
        if player and player.bufMgr then
            player.bufMgr:addBufById(self.buffId, self.player, self.skill)
        end
    end
end

function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        local player = buff.player
        if player and player.bufMgr then
            player.bufMgr:removeBufById(self.buffId)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_XiaoQ_Skill2", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_XiaoQ_Skill2", {self,self.removeBuffHandler})
    M.super.destroy(self)
end
return M;