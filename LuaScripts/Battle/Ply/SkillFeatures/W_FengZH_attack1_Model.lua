--风之痕
---@class W_FengZH_attack1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FengZH_attack1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
    EventDispatcher:registerEvent("PlayerDead", {self,self.playerDeadHandler})
end

function M:spawn()
    M.super.spawn(self)
    ---@type PlayerSkillItem
    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil and skill2.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill2 = skill2.cur_skill_config.feature
    end
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil and skill0.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill0 = skill0.cur_skill_config.feature
    end
end

--召唤成功
function M:sendForHandler( eventName, data )
    ---@type PlayerModel
    local player = data["player"]
    if self.player:equal(player.master) == true and self.skill2 then
        player.bufMgr:addBufById( self.skill2.chaofengBuff, player)
    end
end

---@param eventData Battle_HandleData_PlayerDead
function M:playerDeadHandler(eventName, eventData)
    if eventData.data and self.player:equal(eventData.data.master) and eventData.data.master.playerId == self.player.playerId then
        local player = eventData["data"]
        BattleTool:safeTriggerActionEventWork(eventData.data, "die_1", "Hit", 1)
        if self.skill2 then
            self.player.bufMgr:addBufById(self.skill2.cureHpBuff, self.player, self.skill2.skill) -- 给自己加回血buffd
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SendForFinish", {self,self.sendForHandler})
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.playerDeadHandler})
    M.super.destroy(self)
end

return M