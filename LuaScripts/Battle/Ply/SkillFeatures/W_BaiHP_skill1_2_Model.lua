--当被施加了寄生之种的敌人处于狂野场地中时，寄生之种会被激活，立刻使敌人禁锢2秒，
--并在之后的5秒内，每秒对其额外造成100%攻击力的伤害，之后寄生之种会消失

local W_BaiHP_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_BaiHP_skill1_1_Model")

---@class W_BaiHP_skill1_2_Model : W_BaiHP_skill1_1_Model @
---@field super W_BaiHP_skill1_1_Model @W_BaiHP_skill1_1_Model
local M = class("W_BaiHP_skill1_1_Model", W_BaiHP_skill1_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.checkFieldTimer = TimeTools:startOneLoopTask(GlobalTools.base1, handler(self, self.checkFieldState)) 
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)
    self.checkFieldTimer:update_dt(dt)
end

--- 检查敌方种子
function M:checkFieldState()
    local buffs = self.player.bufMgr:findBufByTag("W_BaiH_KY")
    if #buffs > 0 then -- 有狂野场地
        local enemies = SelectTargetUtil:findPlayerByParam(self.player, {camp = "enemy", ignoreSummon = true})

        ---@type BufWorkAddBuf[]
        local bufWorks = {}
        for i, v in ipairs(buffs) do
            if v.bufWork and v.bufWork.isInBuffRange then
                table.insert(bufWorks, v.bufWork)
            end
        end

        enemies:safeWalkInverted(function(enemy)
            if enemy.bufMgr:hasBufByTag("W_BaiH_skill1") then  -- 有种子
                for i, v in ipairs(bufWorks) do
                    if v:isInBuffRange(enemy) then
                        self:triggerJSSeed(enemy)
                        break
                    end
                end
            end
        end)
    end
end

---@param enemy PlayerModel
function M:triggerJSSeed(enemy)
    enemy.bufMgr:removeBufByTag("W_BaiH_skill1")
    enemy.bufMgr:addBufById(self.addEnemyBuff1, self.player, self.skill)
end

function M:destroy()
    self.checkFieldTimer = nil
    M.super.destroy(self)
end

return M