--每拥有最大生命值的18%，便获得6%的攻击力提升效果，至多提升30%攻击力
---@class W_WuD_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WuD_skill0_1_Model", SkillFeatures_Model)

M.curAtkCount = 0

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --0.18
    self.hp = self:getParam(1)
    --0.06
    self.atk = self:getParam(2)
    --5
    self.atkMaxCount = self:getParam(3)
    self.curAtkCount = 0
    self.last_atk_value = 0;
end

function M:update(dt)
    M.super.update(self, dt)
    --0 ~ 1
    local count = GlobalTools:Div(self.player.data:get_hpRate(), self.hp)
    count = self:get_level_count(count)
    self:change(count)
end


function M:get_level_count( count )
    if count >= GlobalTools.base5 then
        return GlobalTools.base5
    end
    if count >= GlobalTools.base4 then
        return GlobalTools.base4
    end
    if count >= GlobalTools.base3 then
        return GlobalTools.base3
    end
    if count >= GlobalTools.base2 then
        return GlobalTools.base2
    end
    if count >= GlobalTools.base1 then
        return GlobalTools.base1
    end
    return 0
end


function M:change(count)
    if count ~= self.curAtkCount then
        if count > self.atkMaxCount then
            count = self.atkMaxCount
        end
        self.curAtkCount = count
        self.player.data.atk:removeFromMulList( self.last_atk_value )
        local atk_value = GlobalTools:Mul( self.curAtkCount, self.atk );
        self.last_atk_value = atk_value
        self.player.data.atk:addToMulList( atk_value )
    end
end

function M:destroy()
    M.super.destroy(self)
end
return M