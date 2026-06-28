--成功击杀敌人后，白玉堂会立即释放一次该技能
---@class W_BaiYT_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiYT_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.refreshFlag =  self:getParam(1) --是否解锁刷新技能：1=解锁，0=不解锁
    EventDispatcher:registerEvent("PlayerDead", {self, self.playerDeadHandle})
end

---@param eventData Battle_HandleData_PlayerDead
function M:playerDeadHandle(eventName, eventData)
    if self.refreshFlag == 1 and (not self.player:equal(eventData.data)) then  -- 非是自己死亡,立即释放一次技能
        if eventData.data.master == nil and eventData.data.camp ~= self.player.camp then
            if self.player.aiEngine ~= nil and self.player:equal(eventData.data.killer) then
                self.player.aiEngine.skillConfig = self.skill
                self.player.aiEngine:changeState("attack")
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self, self.playerDeadHandle})
    M.super.destroy(self)
end

return M