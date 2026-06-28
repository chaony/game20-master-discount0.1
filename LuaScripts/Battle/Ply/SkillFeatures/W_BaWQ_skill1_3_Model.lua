-- lv3 战斗中，唐伯虎每消耗一根枪头，便会获得5%的攻击和攻速加成，最多获得50%的攻击和攻速加成，该效果会持续到战斗结束 

local W_BaWQ_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_BaWQ_skill1_1_Model")

---@class W_BaWQ_skill1_3_Model : W_BaWQ_skill1_1_Model @
---@field super W_BaWQ_skill1_1_Model @W_BaWQ_skill1_1_Model
local M = class("W_BaWQ_skill1_3_Model", W_BaWQ_skill1_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
end

function M:onCostResLv(costLv)
    M.super.onCostResLv(self, costLv)
    for i = 1, costLv do
        self.player.bufMgr:addBufById(self.addBuff2, self.player, self.skill)
    end
end

return M