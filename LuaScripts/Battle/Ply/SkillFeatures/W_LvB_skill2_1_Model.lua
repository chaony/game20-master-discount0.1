--战斗开始时，吕布会立刻释放战神之威，威吓与自己位置相对的敌方侠客，立即对其造成300%攻击力的伤害，且在本场战斗中，
--只要吕布在场，该侠客造成的伤害就会减少20%，吕布自身伤害增加20%（效果不会被净化）


---@class W_LvB_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LvB_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)
    self.targetEnemyPlayer = nil
    EventDispatcher:registerEvent("add_W_LvB_skill2", {self,self.addBuffHandler})
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    local buff = eventData["buff"]
    if buff ~= nil and buff.player and self.player:equal(buff.source) then
        self.targetEnemyPlayer = buff.player
    end
end

--死亡
function M:dead(data)
    M.super.dead(self)
    if self.targetEnemyPlayer and self.targetEnemyPlayer:isLive() then
        self.targetEnemyPlayer.bufMgr:removeBufByTag("W_LvB_skill2", false)
        self.targetEnemyPlayer.bufMgr:addBufById(self.buffId, self.player)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_LvB_skill2", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M