-- lv2 战斗中，当我方阴阵营侠客首次死亡时，邪极会直接获得20层“邪灵”效果

local W_XieJ_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_XieJ_skill1_1_Model")
---@class W_XieJ_skill1_2_Model : W_XieJ_skill1_1_Model @
---@field super W_XieJ_skill1_1_Model @W_XieJ_skill1_1_Model
local M = class("W_XieJ_skill1_2_Model", W_XieJ_skill1_1_Model)
--
--function M:init(ply, skill,className)
--    M.super.init(self, ply, skill,className)
--
--    self.obtainLevelRace6 = self:getParam(5) -- Fix[0-20] 我方阴阵营首次死亡增加层数
--    self.isTriggerFirstRace6 = false    -- 是否已经触发过【我方首次阴阵营死亡】
--end
--
-----@param player PlayerModel
--function M:onPlayerDead(player)
--    if not self.isTriggerFirstRace6 then
--        if player.camp == self.player.camp and player.plyData.race == 6 then
--            self.isTriggerFirstRace6 = true
--            self:improveResStack(self.obtainLevelRace6)  --获取邪灵层数
--        end
--    end
--    M.super.onPlayerDead(self, player)
--end

return M