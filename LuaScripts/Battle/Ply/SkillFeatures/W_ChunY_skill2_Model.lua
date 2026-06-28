--纯阳 纯阳的生命值没减少1% 便获得2的攻速提升，至多提升100的攻速
---@class W_ChunY_skill2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ChunY_skill2_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hp_value = self:getParam(1)
    self.max_speed = self:getParam(3)
    self.addvalue = self:getParam(2)
    self.last_value = GlobalTools.base0
	EventDispatcher:registerEvent("selfHp", {self,self.conditionHandler})
end

--条件触发
function M:conditionHandler( eventName, data )
    local player = data["ply"]
   if self.player:equal(player) and self.player.data:get_curHp() > GlobalTools.base0 then                
        -- local hpPercent = self.player.data:get_curHp() / self.player.data:get_hp()
        local hpPercent = GlobalTools.base1 - data["value"]
        if  hpPercent >= self.hp_value then
            if self.last_value  > GlobalTools.base0 then
                self.player.data.haste:removeFromAddList(self.last_value )
            end
            local hp_value = GlobalTools:Div( hpPercent, self.hp_value);
            local speed = GlobalTools:Mul( hp_value, self.addvalue )
            if speed > self.max_speed then
                speed = self.max_speed
            end
            self.player.data.haste:addToAddList(speed)   
            self.last_value = speed               
        end
    end
end



function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("selfHp", {self,self.conditionHandler})
end


return M