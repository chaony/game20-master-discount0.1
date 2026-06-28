--战斗开始时，金刚与自己位置相对的敌人会各投一次骰子，若金刚投出的点数比敌人的大，则金刚会对敌人施加诅咒，之后的10秒内，当金刚受到伤害时，该敌人也将受到金刚所受伤害60%的伤害
---@class W_JinG_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JinG_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.shareDmgBuff = self:getParam(1)

    -- 技能初始化的时候，内置好了点数
    self.selfPoint = WRandom:randomNum(1, 7, true )
    self.enemyPoint = WRandom:randomNum(1, 7, true )
end

function M:spawn()
    if self.player.skyStar then
        self.player.skyStar:triggerStart(self)
    end
    M.super.spawn(self)
end

--角色出生结束
function M:spawnFinish()
    local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player.camp)
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        if enemy.index == self.player.index then
            self.enemy = enemy
            break
        end
    end
    if self.enemy == nil then
        local enemyIndex = WRandom:randomNum(1,enemys.Count + 1, true)
        self.enemy = enemys:get(enemyIndex - 1)
    end
    if self.enemy ~= nil and self.selfPoint > self.enemyPoint then
        self.enemy.bufMgr:addBufById(self.shareDmgBuff, self.player)
    end
    M.super.spawnFinish(self)
end


function M:destroy()
    M.super.destroy(self)
end

return M