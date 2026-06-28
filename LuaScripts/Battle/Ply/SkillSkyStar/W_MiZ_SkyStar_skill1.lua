--"般若龙象：
--密宗涅槃时，对敌方全体侠客造成16%当前生命值的真实伤害，并降低敌方全体50%受到的治疗量，持续6秒。"

---@class W_MiZ_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_MiZ_SkyStar_skill1", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.addBuff1 = self:getParam(1, 0)   --buff[] 
end

---@param data W_MiZ_skill1_1_Model
function M:triggerStart(data)
    local targets = self:getTarget("enemy","all")
    for i = 1, targets.Count do
        local ply = targets:get(i-1)
        if ply and ply.master == nil then
            ply.bufMgr:addBufById(self.addBuff1, self.player)
        end
    end
end

return M;