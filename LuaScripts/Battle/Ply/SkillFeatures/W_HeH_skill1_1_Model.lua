--战斗开始时，随机连接敌方场上的一名女性侠客和男性侠客10秒，当其中一名侠客受到伤害时，另一名侠客也会受到等量的伤害。
---@class W_HeH_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HeH_skill1_1_Model", SkillFeatures_Model)

M.player1 = nil
M.player2 = nil

M.lineData = require("Battle.Ply.SkillFeaturesData.W_HeH_skill1_1_Data")
M.hasTarget = false

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.time = self:getParam(1)
    self.shareBuff = self:getParam(2)
    self.lineData.finishWaitTime = self.time
end

function M:canUse()
    return self.hasTarget
end

function M:spawn()
    M.super.spawn(self)
    local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
    local hasWoman = false
    local hasMan = false
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        if tonumber(enemy.plyData.sex) == 1 then
            hasMan = true
        elseif tonumber(enemy.plyData.sex) == 2 then
            hasWoman = true
        end
    end
    self.hasTarget = hasMan and hasWoman
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if killer ~= nil and killer:equal(self.player) and skillConfig == self.skill then
        self.player1 = victim
        self:lineToPlayer(self.player1)
    end
end

function M:update(dt)
    if self.line ~= nil and self.line.state == 6 then
        self.line = nil
        self.player1 = nil
        self.player2 = nil
    end
end

--连线
function M:lineToPlayer(player)
    --加载预制
    self.line = require("Battle.Line.Line_Model").new()
    self.line:init(self.lineData, self.player, player)
    --将连线加入到管理器
    player.lineMgr:addLine(self.line)
    
    self.player2 = self.line.target
    if self.player2 ~= nil then
        self.player1.bufMgr:addBufById(self.shareBuff, self.player2)
        self.player2.bufMgr:addBufById(self.shareBuff, self.player1)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M