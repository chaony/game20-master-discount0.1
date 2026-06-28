--释放成功后，立即为所有敌方施加一层中毒，
--并每秒对所有敌人造成70%攻击力伤害，持续12秒技能结束时，
--将持续期间造成总伤害的50%转化为对自身的血量（中毒：每2秒发作一次，
--发作时造成100%攻击力的伤害并减少中毒者3点内力，持续6秒，最多叠加5层）
---@class W_WuD_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WuD_skill3_1_Model", SkillFeatures_Model)

M.curAtkCount = 0

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --self.hp = self:getParam(1)
    --self.atk = self:getParam(2)
end

function M:update(dt)
    M.super.update(self, dt)
    --local count = GlobalTools:Div(self.player.data:get_hpRate(), self.hp)
    --self:change(count)
end

function M:change(count)
    --if count ~= self.curAtkCount then
    --    if count > self.atkMaxCount then
    --        count = self.atkMaxCount
    --    end
    --    local atk_value = GlobalTools:Mul( self.curAtkCount, self.atk )
    --    self.player.data.atk:removeFromMulList( atk_value )
    --    self.curAtkCount = count
    --    self.player.data.atk:addToMulList( atk_value )
    --end
end

function M:destroy()
    M.super.destroy(self)
end
return M