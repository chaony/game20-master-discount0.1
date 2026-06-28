--密宗    法相庄严
-- lv3 释放时若自身处于“涅槃”状态，则释放该技能后恢复200点内力
---@class W_MiZ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MiZ_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.addAnger1 = self:getParam(1)  --[Fix:0-1000] 非阴系恢复能量值
    self.addAnger2 = self:getParam(2)  --[Fix:0-1000] 阴系恢复能量值
    self.addBuff1 = self:getParam(3)  --[Buff] 非阴系buff
    self.addBuff2 = self:getParam(4)  --[Buff] 阴系恢复能量值

    if self.addAnger2 == 0 then -- 没有配，加普通怒气
        self.addAnger2 = self.addAnger1
    end

    if self.addBuff2 == 0 then -- 没有配,加普通buff
        self.addBuff2 = self.addBuff1
    end
end

function M:spawn()
    self.skill1 = self.player.plySkill:getSkillByName("skill1")
    M.super.spawn(self)
end

function M:skillStart(data)
    M.super.skillStart(self, data)
end

--function M:isInNirvana()
--    if self.skill1 and self.skill1.cur_skill_config then
--        ---@type W_MiZ_skill1_1_Model
--        local feature = self.skill1.cur_skill_config.feature
--        return feature:isInNirvana()
--    end
--    return false
--end

--技能事件

function M:skillDispatch(data)
    if data.eventName == "MiZ_AddBuff" then
        ---@type Battle_List
        local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
        if friends.Count > 0 then
            for i = 0, friends.Count-1 do
                ---@type PlayerModel
                local player = friends:get(i)
                if (not self.player:equal(player)) then
                    if player:isLive() then
                        self:addFriendAnger(player)
                        self:addFriendBuff(player)
                    end
                end 
            end
        end
    end
end

---@param player PlayerModel
function M:addFriendAnger(player)
    if player.plyData.race == Battle.EnumData.BATTLE_RACE.Huo then
        player.data:addAnger(self.addAnger2, true)
    else
        player.data:addAnger(self.addAnger1, true)
    end
end

---@param player PlayerModel
function M:addFriendBuff(player)
    if player.plyData.race == Battle.EnumData.BATTLE_RACE.Huo then
        player.bufMgr:addBufById(self.addBuff2, self.player, self.skill)
    else
        player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
    end
end

return M