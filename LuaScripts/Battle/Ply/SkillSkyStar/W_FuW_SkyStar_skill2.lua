--"无量慈悲：
--持有此技能的侠客上场时，提升友方全体侠客每秒10点内力回复"

---@class W_FuW_SkyStar_skill2 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_FuW_SkyStar_skill2",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.angerRestoreBuf = self:getParam(1)
end

function M:gameStart()
    self:addBufToAllFriends(self.angerRestoreBuf)
end

--给队友加buf
function M:addBufToAllFriends( bufid )
    local allPlys = self:getTarget("self","all")
    for i = 1, allPlys.Count do
        local ply = allPlys:get(i-1)
        if ply.master == nil then
            ply.bufMgr:addBufById(bufid, ply)
        end
    end
end

return M;