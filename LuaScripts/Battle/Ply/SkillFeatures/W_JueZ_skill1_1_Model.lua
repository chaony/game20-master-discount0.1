--蹶张现在总是会优先攻击距离自己最远的敌人，且每重复攻击相同目标一次，便获得一层攻速提升效果，最多叠加10层。
--每层效果会提升自身15点攻速。该效果会在更换目标时重置
---@class W_JueZ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JueZ_skill1_1_Model", SkillFeatures_Model)

M.targetData = require("Battle.Ply.SkillFeaturesData.W_JueZ_skill1_1_Data")

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.maxCount = self:getParam(1)
    self.buffId = self:getParam(2)
    --保留层数比例
    self.killRamainCount = self:getParam(3)
    self.kill_Player = false;
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
end

--查找敌人
function M:findPlayer(data)
    data = SelectTargetTool:findPlayerByType(self.targetData.count, self.player)
    local enemy = data:get(0)
    if enemy == self.lastEnemy or self.kill_Player == true then
        local buffs = self.player.bufMgr:findBufById(self.buffId)
        if #buffs < self.maxCount then
            self.player.bufMgr:addBufById(self.buffId, self.player)
        end
    else
        self.player.bufMgr:removeBufById(self.buffId, false)
    end
    self.kill_Player = false
    self.lastEnemy = enemy
    return data
end

function M:killPlayerHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    --击杀或者助攻
    if killer ~= nil and killer:equal(self.player) then
        local buffs = self.player.bufMgr:findBufById(self.buffId)
        local count = GlobalTools:Mul( GlobalTools:ToFix(#buffs), self.killRamainCount )
        if #buffs > 0 then
            self.player.bufMgr:removeBufById(self.buffId, false)
            for i = GlobalTools.base1, count, GlobalTools.base1 do
                self.player.bufMgr:addBufById(self.buffId, self.player)
            end
        end
        self.kill_Player = true
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
end

return M