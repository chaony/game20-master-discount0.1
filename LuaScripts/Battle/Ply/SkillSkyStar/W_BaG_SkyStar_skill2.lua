--"刹那阎罗：
--友方每存在1/2/3名刺客，自身开场将获得10%/20%/30%的暴击率和50%/100%/150%的暴击伤害，持续5秒）"

---@class W_BaG_SkyStar_skill2 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_BaG_SkyStar_skill2",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.plyNum1 = self:getParam(1)
    self.plyNum2 = self:getParam(2)
    self.plyNum3 = self:getParam(3)
    self.bufId1 = self:getParam(4)
    self.bufId2 = self:getParam(5)
    self.bufId3 = self:getParam(6)
end

function M:gameStart()
    local personCount = 0
    local allPlys = self:getTarget("self","all")
    for i = 1, allPlys.Count do
        local ply = allPlys:get(i-1)
        if ply.master == nil then
            if ply.plyData.role_type == 3 then
                personCount = personCount + 1
            end
        end
    end

    if personCount >= self.plyNum3 then
        self:addBufToRoleType(self.bufId3)
    elseif personCount >= self.plyNum2 then
        self:addBufToRoleType(self.bufId2)
    elseif personCount >= self.plyNum1 then
        self:addBufToRoleType(self.bufId1)
    end
end

function M:addBufToRoleType( bufId )
    self.player.bufMgr:addBufById(bufId, self.player)
end

return M;