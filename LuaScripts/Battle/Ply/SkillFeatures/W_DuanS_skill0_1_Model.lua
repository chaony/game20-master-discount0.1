
--段氏被动
--自身的技能和普工命中敌人后降低目标3%的防御，无法叠加--最多叠加6层
---@class W_DuanS_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuanS_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffId = self:getParam(1)
    self.buffId2 = self:getParam(2)
    --self.maxCount = self:getParam(2)
    
    self.count = GlobalTools.base0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:spawn()
    M.super.spawn(self)
    self.count = GlobalTools.base0
end

function M:injureHandler(eventName, data)

    local ply = data["killer"]
    local victim = data["victim"]
    if ply ~= nil and ply:equal(self.player) then
        --if self.count <= 0 then
            --self.count = self.count +1

        if victim ~= nil then  
            local duanshi_skill0 = victim.bufMgr:findBufByTag("duanshi_skill0")
            if table.nums(duanshi_skill0) > 0 then
                return 
            else
                victim.bufMgr:addBufById(self.buffId, ply)
                victim.bufMgr:addBufById(self.buffId2, ply)
                self:countChange(self.count,victim)
                
            end
            
        end
           
        --end
    end
end

function M:countChange(count,victim)

end


function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    self.count = GlobalTools.base0
    M.super.destroy(self)
end

   

return M