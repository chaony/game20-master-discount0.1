--"疾电狂雷：
--友方每存在1/2/3名神射（大侠），自身的初始怒气提高100/200/400点"

---@class W_YuRFJ_SkyStar_skill2 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_YuRFJ_SkyStar_skill2",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    self.plyNum1 = self:getParam(1)
    self.plyNum2 = self:getParam(2)
    self.plyNum3 = self:getParam(3)
    self.angerValue1 = self:getParam(4)
    self.angerValue2 = self:getParam(5)
    self.angerValue3 = self:getParam(6)
end

function M:gameStart()
    local personCount = 0
    local allPlys = self:getTarget("self","all")
    for i = 1, allPlys.Count do
        local ply = allPlys:get(i-1)
        if ply.master == nil then
            if ply.plyData.role_type == 4 then
                personCount = personCount + 1
            end
        end
    end

    if personCount >= self.plyNum3 then
        self:addAngerToAllFriend(self.angerValue3)
    elseif personCount >= self.plyNum2 then
        self:addAngerToAllFriend(self.angerValue2)
    elseif personCount >= self.plyNum1 then
        self:addAngerToAllFriend(self.angerValue1)
    end
end

-- 增加怒气
function M:addAngerToAllFriend( value )
    self.player.data:addAnger(value)
end

return M;