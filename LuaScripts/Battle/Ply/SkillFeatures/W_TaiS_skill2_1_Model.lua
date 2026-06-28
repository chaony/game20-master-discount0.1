--泰山 泰山没减少1%的 最大生命值，便获得1%……的防御强化
---@class W_TaiS_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaiS_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hp_value = self:getParam(1)
    self.add_def = self:getParam(2)
    self.max_def = self:getParam(3)
    self.last_value = GlobalTools.base0
    EventDispatcher:registerEvent("selfHp", {self,self.conditionHandler})
end

--条件触发
function M:conditionHandler( eventName, data )
    local player = data["ply"]
    local value = data["value"]
   if self.player:equal(player) and self.player.data:get_curHp() > GlobalTools.base0 then                
        local hpPercent = GlobalTools.base1 - value
       local count = GlobalTools:Div(hpPercent, self.hp_value)
        if  count ~= self.last_value then
            if self.last_value > 0 then
                self.player.data.atd:removeFromMulList(self.last_value)
                self.player.data.res:removeFromMulList(self.last_value)        
            end
            local def = GlobalTools:Mul(count, self.add_def)
            if def > self.max_def then
                def = self.max_def
            end
            self.player.data.atd:addToMulList(def)     
            self.player.data.res:addToMulList(def)
            self.last_value  = def
        end
    end
end



function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("selfHp", {self,self.conditionHandler})
end




return M