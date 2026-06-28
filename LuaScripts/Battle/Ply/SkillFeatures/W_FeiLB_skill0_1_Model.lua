--当飞龙堡存在于战场中时，我方所有水阵营侠客会获得15%的攻击力和防御提升，
--除自身以外，己方场上每有一个水阵营侠客，攻击力和防御力还会额外提升2%，该效果会在飞龙堡死亡时消失

---@class W_FeiLB_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FeiLB_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.addBuff1 = self:getParam(1)       -- Buff[]  水系队友bff
    self.addBuffExt1 = self:getParam(2)       -- Buff[]  水系额外bff
    self.addBuff2 = self:getParam(3)       -- Buff[]  其他阵营buff
    self.addBuffExt2 = self:getParam(4)       -- Buff[]  其他阵营额外buff
    self.delayTime = self:getParam(5)       -- Fix[]  滞留时间
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self:addFriendBuff()
end

function M:addFriendBuff()
    local friends = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend", ignoreSummon = true})

    local shuiRace = Battle.EnumData.BATTLE_RACE.Mu
    local shuiCnt = 0;
    for i = friends.Count, 1, -1 do
        local friend = friends:get(i-1)
        if friend and friend ~= self.player and SelectTargetTool:isSameRaceOrYuan(friend, shuiRace) then
            shuiCnt = shuiCnt + 1
        end
    end

    for i = friends.Count, 1, -1 do
        local friend = friends:get(i-1)
        local buff, buffExt = nil, nil
        if friend then
            if friend.plyData.race == shuiRace then
                buff = self.addBuff1
                buffExt = self.addBuffExt1
            else
                buff = self.addBuff2
                buffExt = self.addBuffExt2
            end
            
            local bufMgr = friend.bufMgr
            bufMgr:addBufById(buff, self.player, self.skill)
            for i = 1, shuiCnt do
                bufMgr:addBufById(buffExt, self.player, self.skill)
            end
        end
    end
end

function M:dead(data)
    if self.delayTime > 0 then
        TimeTools:delayTime(self.delayTime, handler(self, self.removeAllAddBuff))
    else
        self:removeAllAddBuff()
    end
    return M.super.dead(self, data)
end

function M:removeAllAddBuff()    
    local friends = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend"})

    for i = friends.Count, 1, -1 do
        local friend = friends:get(i-1)
        if friend then
            friend.bufMgr:removeBufByTag("W_FeiLB_skill0", true)
        end
    end
end

return M
