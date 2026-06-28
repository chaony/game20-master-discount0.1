--霸者心 自身血量高于80%时，自身防御力提升100%
---@class W_BaD_skill2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaD_skill2_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.maxHp = self:getParam(1) --自身血量高于80
    self.buffId = self:getParam(2) --防御buf提升
    self.start = false
end

function M:spawn()
    M.super.spawn(self)
   self.start = true
   self.player.bufMgr:addBufById(self.buffId,self.player)
end

function M:update(dt,unsdt)
    if self.start then
        if self.player.data:get_curHp() <= 0 then
            self.start = false
        end
        local max_hp_value = self.player.data:get_hp();
        local buffs = self.player.bufMgr:findBufById(self.buffId)
        --血量
        local max_rate_hp = GlobalTools:Mul(max_hp_value, self.maxHp)
        if #buffs <= 0 then
            if self.player.data:get_curHp() >= max_rate_hp then
                self.player.bufMgr:addBufById(self.buffId,self.player)
            end
        end
        if self.player.data:get_curHp() < max_rate_hp then
            self.player.bufMgr:removeBufById(self.buffId)
        end
    end
end


function M:destroy()
    M.super.destroy(self)
    
end

return M