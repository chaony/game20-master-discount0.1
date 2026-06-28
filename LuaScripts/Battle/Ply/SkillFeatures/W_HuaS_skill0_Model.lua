--战斗中,华山额外增加伤害减免,闪避越高伤害减免越多.最高增加20%伤害减免

---@class W_HuaS_skill0_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuaS_skill0_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.dodgeRateUnit = self:getParam(1)           -- 单位闪避率
    self.dodgeRateResatdBuff = self:getParam(2)     -- 闪避率提供免伤
    self.dodgeValueUnit = self:getParam(3)          -- 单位闪避值
    self.dodgeValueResatdBuff = self:getParam(4)    -- 闪避值提供免伤
    self.maxRateResatdLevel = self:getParam(5)            -- 闪避率提供免伤最大层数
    self.maxValueResatdLevel = self:getParam(6)           -- 闪避值提供免伤最大层数

    self.lastDodgeValue = 0

    EventDispatcher:registerEvent("add_W_HuaS_skill2", {self,self.addBuffHandler})
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)

    -- 闪避值更新后，更新闪避值提供免伤加成
    if self.lastDodgeValue ~= self.player.data.dodge:getValue() then
        self:updateDodgeResatdBuff()
    end
end

-- 更新免伤值提供buff层数
function M:updateDodgeResatdBuff()
    local dodgeValue = self.player.data.dodge:getValue()
    local level = math.floor(GlobalTools:Div(dodgeValue, self.dodgeValueUnit))
    level = math.min(level, self.maxValueResatdLevel)

    local buffs = self.player.bufMgr:findBufById(self.dodgeValueResatdBuff)
    if #buffs < level then
        for i = 1, level - #buffs do
            self.player.bufMgr:addBufById(self.dodgeValueResatdBuff, self.player, self.skill)
        end
    elseif #buffs > level then
        for i = 1, #buffs - level do
            self.player.bufMgr:removeBufById(self.dodgeValueResatdBuff, true, true)
        end
    end
    self.lastDodgeValue = dodgeValue
end

-- 有华山2技能提供闪避了加成，直接添加最大的闪避免伤层数
function M:addBuffHandler(eventName, data)
    local buffs = self.player.bufMgr:findBufByTag("W_HuaS_skill2")
    if buffs[1] then
        for i = 1, self.maxRateResatdLevel do
            self.player.bufMgr:addBufById(self.dodgeRateResatdBuff, self.player, self.skill)
        end
    end

    --模拟测试
    --TimeTools:delayTime(GlobalTools.base3, function()
    --    self.player.data.dodge:setForce(GlobalTools.base5)
    --end)
    --TimeTools:delayTime(GlobalTools.base6, function()
    --    self.player.data.dodge:setForce(GlobalTools.base10)
    --end)
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_HuaS_skill2", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M