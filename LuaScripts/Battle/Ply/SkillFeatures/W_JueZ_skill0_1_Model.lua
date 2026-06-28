--自己贴身范围没有敌人时,命中提升80,暴击率提升25%
---@class W_JueZ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JueZ_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.range = self:getParam(1)
    self.buffId = self:getParam(2)
    self.someOne = false;
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)    
    if  self.player ~= nil  then
        if self.player.data:get_curHp() > GlobalTools.base0 then
            local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp())
            for i = enemys.Count, 1, -1 do
                local enemy_player = enemys:get(i-1)
                local distance = GlobalTools:Distance(self.player.position, enemy_player.position)
                if distance > self.range then
                    self.someOne = true
                else
                    self.someOne = false
                    break
                end
            end
            self:changeData()
        end
    end
end


function M:changeData()
    if self.someOne ~= nil  then
        if self.someOne == true  then
            if self.buff == nil  then
                self.buff = self.player.bufMgr:addBufById(self.buffId, self.player)
            end
        else
            if self.buff ~= nil  then
                self.player.bufMgr:removeBuf(self.buff, false)
                self.buff = nil
            end
        end
    end
end


return M