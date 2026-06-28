---@class W_EM_skill3_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_EM_skill3_Model", SkillFeatures_Model)


--function M:init(ply, skill,className)
--    M.super.init(self, ply, skill,className)
--    self.hp = self:getParam(1)
--	EventDispatcher:registerEvent("remove_emei_skill3", {self,self.removeHandler})
--end
--
--function M:removeHandler(eventName, data)
--    local hp_cha = self.player.data:get_hp() - self.player.data:get_curHp()
--    local hp_value =  GlobalTools:Mul(hp_cha,self.hp)
--    self.player:cure("fix", self.player, hp_value)
--end
--
--function M:destroy()
--    EventDispatcher:unRegisterEvent("remove_emei_skill3", {self,self.removeHandler})
--    M.super.destroy(self)
--end



return M