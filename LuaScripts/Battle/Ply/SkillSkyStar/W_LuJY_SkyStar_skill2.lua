--无漏金身：
--此侠客位于前排时，后排临近的两个侠客获得额外10%的免伤

---@class W_LuJY_SkyStar_skill2 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_LuJY_SkyStar_skill2",SkillSkyStar)

function M:init( player, param, level )
    M.super.init(self,player, param, level )
    self.bufid = self:getParam(1)
end

function M:gameStart()
    local my_frontrow = false;
    --前排队友
    local targets = self:getTarget("self","frontrow")
    for i = 1, targets.Count  do
        local ply = targets:get(i-1)
        if ply.master == nil then
            --如果我在前排的话
            if ply:equal(self.player) then
                my_frontrow = true;
            end
        end
    end

    --如果我在前排
    if my_frontrow then
        local backrows = self:getTarget("self","backrow")
        if self.player.index == 0 then
            --根据我的位置来找到后排位置的人
            for i = 1, backrows.Count do
                local ply = backrows:get(i-1)
                if ply.master == nil then
                    if ply.index == 2 or ply.index == 3 then
                        ply.bufMgr:addBufById(self.bufid, self.player)
                    end
                end
            end
        elseif self.player.index == 1 then
            for i = 1, backrows.Count do
                local ply = backrows:get(i-1)
                if ply.master == nil then
                    if ply.index == 4 or ply.index == 3 then
                        ply.bufMgr:addBufById(self.bufid, self.player)
                    end
                end
            end
        end
    end
end

return M;