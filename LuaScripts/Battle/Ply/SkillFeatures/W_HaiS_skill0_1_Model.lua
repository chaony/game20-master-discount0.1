--自身每损失1%的血量，受到的恢复效果就提升1%
---@class W_HaiS_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HaiS_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.lostRate = self:getParam(1) -- 每累积损失多少加一层
    --self.hpRecoverRate = self:getParam(2)  -- 此参数不再使用，因为是修改技能，依然保留占位
    self.bufData = self:getParam(5) -- 每层的buffid
    self.buffMaxNum = self:getParam(6) -- 持有buf层数上限
    self.addNum = 0 -- 加了多少层buff
    self.oldTotalLostHp = 0  -- 按比例累计损失血量
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    local hp_max = self.player.data:get_hp() -- 获取血量上限
    local lastTotalLostHp = self.player.totalLostHp or 0 -- 累计损失血量
    local buffs = self.player.bufMgr:findBufById(self.bufData) -- 加了多少层buff
    self.addNum = #buffs -- 加了多少层buff
    if self.addNum < self.buffMaxNum then
        local lostRate = GlobalTools:Div((lastTotalLostHp - self.oldTotalLostHp),hp_max) -- (累计损失血量 - 上次累计损失血量 ) / 血量上限 = 当前损失血量的比例
        local curAddBuffNum = GlobalTools:Div(lostRate, self.lostRate) -- (当前损失血量的比例 / 每累积损失多少加一层) = 要加多少层
        local num = math.floor(GlobalTools:ToFloat(curAddBuffNum)) -- 定点数转浮点数
        for i = 1, num do
            if self.addNum < self.buffMaxNum then
                self.player.bufMgr:addBufById(self.bufData, self.player) -- 加buff
                self.oldTotalLostHp = self.oldTotalLostHp + GlobalTools:Mul(hp_max, self.lostRate)
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

   

return M