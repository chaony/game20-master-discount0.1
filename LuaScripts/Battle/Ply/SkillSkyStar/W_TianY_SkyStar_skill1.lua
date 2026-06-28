--猎天袭：
--天鹰施展“隼击长空”时，将在敌方密集区域额外发射一波翎羽，天鹰触发额外释放时，也会激活该效果

---@class W_TianY_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_TianY_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
end

---@param data W_TianY_skill3_Model
function M:triggerStart(data)
    if self.player:isLive() then
        self.player.evtMgr:commonEventWorkByKey("Hit", 1)
    end
end

return M;