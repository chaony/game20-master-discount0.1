--战斗开始时，天山会禁锢与自己位置相对的敌人并瞬移至其身后，对其造成300%攻击力的伤害，并使其沉默2秒，本场战斗中，天山总会优先攻击该敌人
---@class W_TianS_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianS_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.enemy = nil
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
    --对位目标
    local faceEnemy = nil
    --同排目标
    local rowEnemys = {}
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        if enemy.followTarget == nil then
            if self.player.index == enemy.index then
                faceEnemy = enemy
                break
            elseif SceneManager.curScene.ZhenFaManager:isFront(self.player.camp, self.player.index) == true then
                if SceneManager.curScene.ZhenFaManager:isFront(enemy.camp, enemy.index) == true then
                    table.insert(rowEnemys, enemy)
                end
            elseif SceneManager.curScene.ZhenFaManager:isFront(self.player.camp, self.player.index) == false then
                if SceneManager.curScene.ZhenFaManager:isFront(enemy.camp, enemy.index) == false then
                    table.insert(rowEnemys, enemy)
                end
            end
        end
    end
    if faceEnemy ~= nil then
        self.enemy = faceEnemy
    elseif #rowEnemys > 0 then
        self.enemy = rowEnemys[WRandom:randomNum(1, #rowEnemys)]
    else
        self.enemy = enemys:get(WRandom:randomNum(0, enemys.Count))
    end
end

--更新
function M:update(dt,unsdt)
    M.super.update(self, dt,unsdt)
    if self.enemy ~= nil then
        if self.enemy:isLive() ~= true or self.enemy.followTarget ~= nil  then
            self.enemy = nil
        end
        if self.enemy ~= nil and self.enemy:equal(self.player.enemy) == false then
            self.player:lockEnemy(self.enemy)
        end
    end
end

function M:skillDispatch(data)
    if data.eventName == "skill1_findPlayer" then
        if self.enemy ~= nil then
            self.player.lastSelect = Battle.List.new()
            self.player.lastSelect:add(self.enemy)
        end
    end
end

--查找敌人
function M:findPlayer(data)
    M.super.findPlayer(self, data)
    if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then
        if self.enemy ~= nil then
            data:clear()
            data:add(self.enemy)
        end
    end
    return data
end

function M:destroy()
	M.super.destroy(self)
end

return M