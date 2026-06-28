--该技能每命中一个敌人，自身便获得10%的伤害减免
---@class W_BaiT_skill1_2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiT_skill1_2_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)
    self.lastEnemy = Battle.List.new()
end

function M:spawn()
	 M.super.spawn(self)
end

--查找敌人
function M:findPlayer(data)
	if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then
		for i = 1, data.Count do
			self.player.bufMgr:addBufById(self.buffId,self.player)
   		 end
	end
    return data
end

function M:destroy()
	M.super.destroy(self)
end

return M