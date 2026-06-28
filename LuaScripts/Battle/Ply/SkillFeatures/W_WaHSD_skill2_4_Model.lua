--若连结对象被击败，娲皇神殿降下冰雹对敌方全体侠客造成160%的内功伤害，并有80%概率的造成冰冻效果，持续2秒。

local W_WaHSD_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_WaHSD_skill2_1_Model")
---@class W_WaHSD_skill2_4_Model : W_WaHSD_skill2_1_Model @
---@field super W_WaHSD_skill2_1_Model
local M = class("W_WaHSD_skill2_4_Model", W_WaHSD_skill2_1_Model)
    
--function M:onLinkTargetDead()
--    M.super.onLinkTargetDead(self)
--    if self.player.evtMgr and self.player:isLive() then
--        self.player.evtMgr:commonEventWorkByKey("PlayEffect", 1)
--        self.player.evtMgr:commonEventWorkByKey("PlaySound", 2)
--        self.player.evtMgr:commonEventWorkByKey( "Hit", 1)
--    end
--end

return M
