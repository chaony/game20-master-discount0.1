--战斗中，赵云每成功闪避一次敌人的攻击，便对当前目标造成一次150%攻击力的伤害，该效果每秒仅可触发一次

---@class W_ZhaoY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhaoY_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.interval = self:getParam(1)  --int 每几秒可触发一次
    self.buffId = self:getParam(2)  --buffId 閃避时自己加内力
    self.buffId2 = self:getParam(3)  --buffId 闪避时给当前目标伤害
    self.canDodge = true
    EventDispatcher:registerEvent("dodge", {self,self.dodgeHandler})
end

--发生闪避
---@param data table
function M:dodgeHandler(eventName, data)
    if self.player:equal(data.victim) and self.buffId > 0 and self.canDodge then
        self.canDodge = false
        self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
        if self.player.enemy then
            --self.player.evtMgr:commonEventWork("Shoot",1 );
            --BattleTool:safeTriggerCommonEventWork(self.player, "common", "Shoot", 1)
            self.player.enemy.bufMgr:addBufById(self.buffId2, self.player, self.skill)
        end
        TimeTools:delayTime(self.interval, function()
            self.canDodge = true
        end)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("dodge", {self,self.dodgeHandler})
    M.super.destroy(self)
end

return M