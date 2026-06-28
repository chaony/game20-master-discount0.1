--"水莲玉心：
--慈航位于后排时，前排侠客获得额外10%内伤减免。"

---@class W_CiH_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_CiH_SkyStar_skill1", SkillSkyStar)

function M:init( player, param, level )
    M.super.init(self,player, param, level )
    self.addBuff1 = self:getParam(1, 0)     -- Buff[]   -- 内伤减免buff
end

function M:gameStart()
    -- 自己在后排
    if SceneManager.curScene.ZhenFaManager:isFront(self.player:get_camp(), self.player.index) == false then
        self:giveFrontFriendsBuff()
    end
end

function M:giveFrontFriendsBuff()
    local targets = self:getTarget("self","frontrow")
    for i = 1, targets.Count  do
        local ply = targets:get(i-1)
        if ply:isXiaKe() then
            ply.bufMgr:addBufById(self.addBuff1, self.player)
        end
    end
end

return M;