--战斗开始时，赵云自身的闪避值会提升100点，但战斗时间每过去5秒，该加成效果会减少20%
--当赵云的闪避值大于200点时，每额外获得10点闪避值，便会使自身受到的伤害减少1%，最多减少30%

---@class W_ZhaoY_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill1 W_ZhaoY_skill1_1_Model
local M = class("W_ZhaoY_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.addDodgeValue = self:getParam(1)  --定点数 初始增加的闪避值 
    self.curAddDodgeValue = self.curAddDodgeValue
    self.lastDodgeValue = 0
    self.interval = self:getParam(2)  -- int 战斗时间每过去interval秒 加成减少
    self.reduceDodgeValue = self:getParam(3)  -- int 战斗时间每过去interval秒 该加成效果会减少reduceDodgeValue%
    self.tiggerDodgeValue = self:getParam(4)  -- 定点数 当赵云的闪避值大于tiggerDodgeValue点时
    self.buffId = self:getParam(5)  --
    self.maxDodgeLevel = self:getParam(6)  --最多减少30%
    self.unitDodgeValue = self:getParam(7)  --每额外获得10点闪避值
    if self.addDodgeValue > 0 and self.reduceDodgeValue > 0 then
        self.addDebuffTimer = TimeTools:startOneLoopTask(self.interval, handler(self, self.onAddDebuffTrigger))
    end
end

function M:spawn()
    M.super.spawn(self)
    self.player.data.dodge:addToAddList(self.addDodgeValue)
end

function M:onAddDebuffTrigger()
    local reduceValue = GlobalTools:Mul(self.addDodgeValue, self.reduceDodgeValue) 
    if reduceValue > 0 and self.curAddDodgeValue > reduceValue then
        self.curAddDodgeValue = self.curAddDodgeValue - reduceValue
        self.player.data.dodge:addToAddList(-reduceValue)
    end
end

function M:update(dt, unsdt)
    M.super.update(self, dt, unsdt)

    -- 闪避值更新后，更新闪避值提供免伤加成
    if self.lastDodgeValue ~= self.player.data.dodge:getValue() and self.player.data.dodge:getValue() > self.tiggerDodgeValue then
        self:updateDodgeResatdBuff()
    end
end

-- 更新免伤值提供buff层数
function M:updateDodgeResatdBuff()
    local dodgeValue =  self.player.data.dodge:getValue() - self.tiggerDodgeValue
    local level = math.floor(GlobalTools:Div(dodgeValue, self.unitDodgeValue))
    level = math.min(level, self.maxDodgeLevel)

    local buffs = self.player.bufMgr:findBufById(self.buffId)
    if #buffs < level then
        for i = 1, level - #buffs do
            self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
        end
    elseif #buffs > level then
        for i = 1, #buffs - level do
            self.player.bufMgr:removeBufById(self.buffId, true, true)
        end
    end
    self.lastDodgeValue = self.player.data.dodge:getValue()
end

function M:destroy()
    self.addDebuffTimer = nil
    M.super.destroy(self)
end

return M