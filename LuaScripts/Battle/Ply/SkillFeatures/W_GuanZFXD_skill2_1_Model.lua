--战斗开始时，飞雪刀会瞬移至与自己位置相对的敌方侠客身后，对其造成240%攻击力的伤害，并立刻在其身上生成一个破绽
---@class W_GuanZFXD_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuanZFXD_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.enemy = nil
    self.isRun = true
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp())
    --对位目标
    local faceEnemy = nil
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        if self.player.index == enemy.index then
            faceEnemy = enemy
            break
        end
    end
    if faceEnemy ~= nil then
        self.enemy = faceEnemy
    end
end

function M:skillStart(data)
    M.super.skillStart(self)
    self.isRun = true
end

function M:skillEnd(data)
    M.super.skillEnd(self)
    self.isRun = false
end

--更新
function M:update(dt,unsdt)
    M.super.update(self, dt,unsdt)
    if self.enemy ~= nil and self.isRun then
        if self.enemy:isLive() ~= true then
            self.enemy = nil
        end
        if self.enemy ~= nil and self.enemy:equal(self.player.enemy) == false then
            self.player:lockEnemy(self.enemy)
        end
    end
end

function M:destroy()
    self.enemy = nil
    M.super.destroy(self)
end

return M