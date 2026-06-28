--所有友军提升15点吸血等级
--同种族额外增加10点吸血等级
local G_JinQ_skill0_1_Model = require("Battle.Ply.SkillFeatures.G_JinQ_skill0_1_Model")
---@class G_JinQ_skill0_2_Model : G_JinQ_skill0_1_Model @
---@field super G_JinQ_skill0_1_Model @W_JinQ_skill0_1_Model
local M = class("G_JinQ_skill0_2_Model", G_JinQ_skill0_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.raceLeeching = self:getParam(2)
end


function M:changeValue(player)
    M.super.changeValue(self,player)
    if self.player.plyData.race == player.plyData.race then
    	self.racePly = player
    	player.data.leeching:addToAddList(self.raceLeeching)
    end
end


function M:destroy()
    M.super.destroy(self)
    if self.racePly ~= nil then
    	self.racePly.data.leeching:removeFromAddList(self.raceLeeching)
    end
end

return M