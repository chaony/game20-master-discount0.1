---
--- 瑶弦天籁将同时提升友军20%抗暴率
---
local M = class("W_KunL_SkyStar_skill1",SkillSkyStar)


function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --抗暴率buf
    self.bufId = self:getParam(1)
end

--触发开始
function M:skillStart( ply, skill )
    if skill.anim_name == "skill3" then
        --所有友军加 20% 抗暴率
        local allPlys = self:getTarget("self","all")
        for i = 1, allPlys.Count do
            local mFriend = allPlys:get(i-1)
            if mFriend:equal(self.player) == false then
                mFriend.bufMgr:addBufById(self.bufId, self.player)
            end
        end
    end
end


function M:skillEnd( ply, skill)
    if skill.anim_name == "skill3" then
        --技能结束删除友军加 20% 抗暴率
        local allPlys = self:getTarget("self","all")
        for i = 1, allPlys.Count do
            local mFriend = allPlys:get(i-1)
            if mFriend:equal(self.player) == false then
                mFriend.bufMgr:removeBufById(self.bufId)
            end
        end
    end
end



return M;