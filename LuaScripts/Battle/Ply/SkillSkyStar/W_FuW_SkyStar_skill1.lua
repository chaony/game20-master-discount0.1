--珍珑丹术：
--天师在消耗丹药时，有50%的概率立即补充一颗新的丹药。

---@class W_FuW_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_FuW_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    
    self.genRate = self:getParam(1, 0)     -- Fix[0-1]   -- 补充弹药概率
end

---@param skillFeature G_FuW_skill1_1_Model
function M:triggerStart(skillFeature, useCnt)
    if useCnt > 0 then    -- 是在消耗丹药
        if GlobalTools:CheckRandom1(self.genRate) then
            skillFeature:setMed(self.player.medCount + 1)
        end
    end
end

return M;