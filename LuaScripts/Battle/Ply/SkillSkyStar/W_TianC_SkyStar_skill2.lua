--"霸战八荒：
--友方每存在一名战士（大侠），自身将获得40点坚韧值与10%抗暴击"

---@class W_TianC_SkyStar_skill2 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_TianC_SkyStar_skill2", SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --n名战士
    self.plyNum = self:getParam(1)
    --buffid
    self.bufId = self:getParam(2)
end

function M:gameStart()
    local personCount = 0
    local allPlys = self:getTarget("self","all")
    for i = 1, allPlys.Count do
        local ply = allPlys:get(i-1)
        if ply.master == nil then
            if ply.plyData.role_type == 2 then
                personCount = personCount + 1
            end
        end
    end
    local count = math.floor(personCount/self.plyNum)
    for i = 1, count do
        self.player.bufMgr:addBufById(self.bufId, self.player)
    end
end

return M;