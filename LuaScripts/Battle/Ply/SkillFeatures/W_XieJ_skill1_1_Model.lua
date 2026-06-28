-- 战斗中，每有一个侠客死亡时，邪极会便会获得1层“邪灵”效果并恢复50点内力，每层邪灵效果会邪极提供2%的伤害提升效果，邪灵效果最多叠加20层
-- 参数说明 侠客死亡获得层数，内力值，每层邪灵提升伤害百分比，邪灵最大层数，首次阴阵营首次死亡层数，侠客死亡时获取属性buff，阴侠客死亡获取属性buff

---@class W_XieJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XieJ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.obtainLevel = self:getParam(1) -- int[0-10] 有侠客死亡时，获得邪灵层数
    self.obtainAnger = self:getParam(2) -- Fix[0-1000] 获得内力值
    self.pmdamageValue = self:getParam(3) -- Fix[0-100] 每层邪灵增伤百分比
    self.maxLevel = self:getParam(4) -- int[0-5] 邪灵的最大层数
    self.obtainLevelRace6 = self:getParam(5) -- int[0-5] 首次阴阵营首次死亡层数
    self.addBuff6 = self:getParam(6) -- Buff[] 我方侠客死亡时获得buff
    self.addBuff7 = self:getParam(7) -- Buff[] 我方阴侠客死亡时获得buff

    self.curResLevel = 0        -- 当前邪灵层数
    self.lastPmDamage = 0       -- 之前的增伤

    if self.maxLevel > 5 then
        Logger.logError("邪极的邪灵层数配置大于5")
        self.maxLevel = 5
    end
    
    EventDispatcher:registerEvent("PlayerDead", {self, self.playerDeadHandle})
end

function M:getResLevel()
    return self.curResLevel
end

--- 提升邪灵层数
function M:improveResStack(level)
    if self.curResLevel < self.maxLevel then
        local addLv = Mathf.Min(self.curResLevel + level, self.maxLevel) - self.curResLevel
        if addLv > 0 then
            self.curResLevel = self.curResLevel + addLv
            self:resLevelChanged(addLv)
        end
    end
end

--- 邪灵层数变化
function M:resLevelChanged(addLv)
    -- 移除之前的效果
    if self.lastPmDamage > 0 then
        self.player.data.pmdamage:removeFromMulList(self.lastPmDamage)
    end
    self.lastPmDamage = GlobalTools:Mul(self.pmdamageValue, GlobalTools:ToFix(self.curResLevel))
    -- 加上现在的效果
    if self.lastPmDamage > 0 then
        self.player.data.pmdamage:addToMulList(self.lastPmDamage)
    end

    -- 获得内力
    if addLv > 0 then
        local addAnger = GlobalTools:Mul(self.obtainAnger, GlobalTools:ToExistFixNum(addLv))
        self.player.data:addAnger(addAnger, true)
    end
    
    EventDispatcher:dipatchEvent("XieJ_ResLevel_Changed", {player = self.player, feature = self, addLv = addLv})
    
    -- 通知视图层
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_XieJ_skill1_1_Model_ResLv_Changed, {
        player = self.player, feature = self, addLv = addLv, curLv = self.curResLevel
    })
end


---@param eventData Battle_HandleData_PlayerDead
function M:playerDeadHandle(eventName, eventData)
    if (not self.player:equal(eventData.data)) then  -- 非是自己死亡
        self:onPlayerDead(eventData.data)
    end
end

---@param player PlayerModel
function M:onPlayerDead(player)
    self:improveResStack(self.obtainLevel)  --获取邪灵层数
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self, self.playerDeadHandle})
    M.super.destroy(self)
end

return M