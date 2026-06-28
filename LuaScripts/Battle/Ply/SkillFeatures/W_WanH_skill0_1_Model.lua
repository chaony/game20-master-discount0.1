--当场上敌方武神死亡时，立即为随机两名敌方添加一种七伤诅咒
---@class W_WanH_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WanH_skill0_1_Model", SkillFeatures_Model)

M.enemyData = require("Battle.Ply.SkillFeaturesData.W_WanH_skill0_1_Data")

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.isEnemyDead = self:getParam(1)
    self.targetCount = self:getParam(2)

    EventDispatcher:registerEvent("killPlayer", {self,self.killPlayerHandler})
end

function M:spawn()
    M.super.spawn(self)
    local skill1Item = self.player.plySkill:getSkillByName("skill1")
    if skill1Item ~= nil then
        self.skill1 = skill1Item.cur_skill_config.feature
    end
    
    self.targetData = table.shallow_copy(self.enemyData)
    if self.targetCount == 1 then
        self.targetData.count.count = "one"
    elseif self.targetCount == 2 then
        self.targetData.count.count = "two"
    elseif self.targetCount == 3 then
        self.targetData.count.count = "three"
    elseif self.targetCount == 4 then
        self.targetData.count.count = "four"
    else
        self.targetData.count.count = "all"
    end
end

function M:killPlayerHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    if victim ~= nil and (self.isEnemyDead == 0 or victim.camp ~= self.player.camp) then
        local enemys = SelectTargetTool:findPlayerByType(self.targetData["count"], self.player)
        for i = 1, enemys.Count do
            local enemy = enemys:get(i - 1)
            if self.skill1 ~= nil then
                self.skill1:addCurse(enemy)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killPlayerHandler})
    M.super.destroy(self)
end
return M