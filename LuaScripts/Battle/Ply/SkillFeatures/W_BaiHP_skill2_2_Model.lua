--当被施加了共生之种的友军处于生息场地中时，共生之种会被激活“：在5秒内，每秒为其恢复100%攻击力的血量，之后共生之种会消失

local W_BaiHP_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_BaiHP_skill2_1_Model")

---@class W_BaiHP_skill2_2_Model : W_BaiHP_skill2_1_Model @
---@field super W_BaiHP_skill2_1_Model @W_BaiHP_skill2_1_Model
local M = class("W_BaiHP_skill2_2_Model", W_BaiHP_skill2_1_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.checkFieldTimer = TimeTools:startOneLoopTask(GlobalTools.base0_5, handler(self, self.checkFieldState)) 
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)
    self.checkFieldTimer:update_dt(dt)
end

--- 检查敌方种子
function M:checkFieldState()
    local buffs = self.player.bufMgr:findBufByTag("W_BaiH_SX") -- 生息场地buff
    if #buffs > 0 then -- 有狂野场地
        local targets = SelectTargetUtil:findPlayerByParam(self.player, { camp = "friend", ignoreSummon = true})

        ---@type BufWorkAddBuf[]
        local bufWorks = {}
        for i, v in ipairs(buffs) do
            if v.bufWork and v.bufWork.isInBuffRange then
                table.insert(bufWorks, v.bufWork)
            end
        end

        targets:safeWalkInverted(function(target)
            if target.bufMgr:hasBufByTag("W_BaiH_skill2") then  -- 有种子
                for i, v in ipairs(bufWorks) do
                    if v:isInBuffRange(target) then
                        self:triggerSXSeed(target)
                        break
                    end
                end
            end
        end)
    end
end

---@param target PlayerModel
function M:triggerSXSeed(target)
    target.bufMgr:removeBufByTag("W_BaiH_skill2")
    target.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
end

function M:destroy()
    self.checkFieldTimer = nil
    M.super.destroy(self)
end

return M