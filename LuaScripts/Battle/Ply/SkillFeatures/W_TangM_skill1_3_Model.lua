--发作额外降低15能量
local W_TangM_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_TangM_skill1_1_Model")
---@class W_TangM_skill1_3_Model : W_TangM_skill1_1_Model @
---@field super W_TangM_skill1_1_Model @W_TangM_skill1_1_Model
local M = class("W_TangM_skill1_3_Model", W_TangM_skill1_1_Model)


--function M:init(ply, skill,className)
--    M.super.init(self, ply, skill,className)
--    self.buffId = self:getParam(2)
--end
--
--
--function M:changeFunc(buff)
--	M.super.changeFunc(self,buff)
--	buff.player.bufMgr:addBufById(self.buffId, self.player)
--end


return M