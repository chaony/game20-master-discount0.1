-- 战斗开始时，唐伯虎身后的画卷上会出现3个光芒组成的枪头，
-- 且战斗时间每过去10秒，还会额外生成一个枪头，最多5个，每个枪头会为唐伯虎提供10%的攻击和攻速加成

---@class W_BaWQ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaWQ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    
    self.initResLv = self:getParam(1)   -- int[0-10] 初始枪头数量
    self.maxResLv = self:getParam(2)    -- int[0-10] 最大枪头数量
    self.genResCD = self:getParam(3)    -- Fix[0-20] 生成枪头时间
    self.addBuff1 = self:getParam( 4)    -- Buff[] 每个枪头提供buff加成
    self.addBuff2 = self:getParam(5)    -- Buff[] 消耗1个枪头提供buff加成
    self.triggerHpRate = self:getParam(6)    -- Fix[0-100] 加免伤buf累计血量比例
    self.triggerUseResLv = self:getParam(7)    -- Fix[0-100] 加免伤消耗枪头上限
    self.triggerAddBuff = self:getParam(8)    -- buff[] 每个枪头加的免伤buf

    if self.maxResLv > 10 then
        self.maxResLv = 10
        Logger.log("唐伯虎的枪头数量不超过10")
    end
    
    self.curResLv = 0
    self.genResTask = TimeTools:startOneDtTask(self.genResCD, function()  
        self:willAddResLv(1)
    end, true)
end

function M:spawnFinish()
    self:willAddResLv(self.initResLv)
    M.super.spawnFinish(self)
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)

    self.genResTask:update_dt(dt)   -- 执行循环逻辑
end

--- 获得枪头
function M:willAddResLv(lv)
    if self.curResLv < self.maxResLv then
        local newLv = Mathf.Min(self.curResLv + lv, self.maxResLv)
        local addLv = newLv - self.curResLv
        self.curResLv = self.curResLv + addLv
        self:onAddResLv(addLv)
        self:dispatchEvent_Local(Battle.SkillEventType.MV_W_BaWQ_skill1_1_Model_Res_Changed,{ addLv = addLv, curResLv = self.curResLv})
    end
end

function M:willCostResLv(lv)
    if self.curResLv >= 1 then
        local newLv = Mathf.Max(self.curResLv - lv, 0)
        local costLv = self.curResLv - newLv
        self.curResLv = newLv
        self:onCostResLv(costLv)
        return costLv
    else
        Logger.logError("当前TangBH没有枪头，不能被消耗")
    end
    return 0
end

function M:onAddResLv(addLv)
    for i = 1, addLv do
        self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
    end
end

function M:onCostResLv(costLv)
    local buffs = self.player.bufMgr:findBufById(self.addBuff1)
    for i = 1, costLv do
        if buffs[i] then
            self.player.bufMgr:removeBuf(buffs[i], true)
        end
    end
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_BaWQ_skill1_1_Model_Res_Changed,{ consumeLv = costLv, curResLv = self.curResLv})
end

function M:getCurrentResLv()
    return self.curResLv
end

return M
