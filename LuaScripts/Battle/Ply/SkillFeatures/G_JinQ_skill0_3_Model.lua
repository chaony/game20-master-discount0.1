--金钱开场获得4层“狂血”，每层增加25%攻击力和防御，每击杀一个目标后失去一层
local G_JinQ_skill0_1_Model = require("Battle.Ply.SkillFeatures.G_JinQ_skill0_1_Model")
---@class G_JinQ_skill0_3_Model : G_JinQ_skill0_1_Model @
---@field super G_JinQ_skill0_1_Model @G_JinQ_skill0_1_Model
local M = class("G_JinQ_skill0_3_Model", G_JinQ_skill0_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.bufData = self:getParam(1) -- buffid
    self.bufCount = self:getParam(2) -- buff层数
end
-- 出生
function M:spawn()
    M.super.spawn(self)
    for i = 1, self.bufCount do
        self.player.bufMgr:addBufById(self.bufData, self.player) -- 加buff
    end
    EventDispatcher:registerEvent("PlayerDead", {self,self.playerDeadHandler})
end

-- 角色死亡
function M:playerDeadHandler(eventName, data)
    local ply = data["data"]
    if ply ~= nil and ply:equal(self.player) == false then
        if ply.killer ~= nil and ply.killer:equal(self.player) then
            local buffs = self.player.bufMgr:findBufById(self.bufData) -- 加了多少层buff
            local addNum = #buffs -- 加了多少层buff
            if addNum > 0 then
                self.player.bufMgr:removeBufById(self.bufData, true, true)
            end
        end
    end

end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.playerDeadHandler})
    M.super.destroy(self)
end

return M