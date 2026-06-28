--独孤
---@class W_DuG_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuG_attack1_Model", SkillFeatures_Model)

M.bufid = 0
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
    EventDispatcher:registerEvent("PlayerDead", {self,self.playerDeadHandler})
end

function M:spawn()
    M.super.spawn(self)
    ---@type PlayerSkillItem
    local skill3 = self.player.plySkill:getSkillByName("skill3")
    if skill3 ~= nil and skill3.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill3 = skill3.cur_skill_config.feature
    end
end

--召唤成功
function M:sendForHandler( eventName, data )
    ---@type PlayerModel
    local player = data["player"]
    if self.player:equal(player.master) == true and self.player.enemy and self.player.enemy.bufMgr and self.skill3 then
        self.player.enemy.bufMgr:addBufById(self.skill3.chaofengBuff, player)
    end
end

---@param eventData Battle_HandleData_PlayerDead
function M:playerDeadHandler(eventName, eventData)
    if eventData.data and self.player:equal(eventData.data.master) and eventData.data.master.playerId == self.player.playerId then
        -- 这里的player 其实是召唤的分身
        --eventData.data.evtMgr:triggerActionEventWork( "skill3", "AddBuf",1) -- 爆炸buff
        BattleTool:safeTriggerActionEventWork(eventData.data, "skill3", "Hit", 1)
        BattleTool:safeTriggerActionEventWork(eventData.data, "skill3", "PlayEffect", 2)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SendForFinish", {self,self.sendForHandler})
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.playerDeadHandler})
    M.super.destroy(self)
   
end

return M