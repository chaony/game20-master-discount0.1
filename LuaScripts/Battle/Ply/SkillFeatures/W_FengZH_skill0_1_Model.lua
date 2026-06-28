--嘯傲狂風：當處於“風之痕”狀態時，會獲得一個狂風護盾，使其受到的傷害減少60%；
--劍•魔焰：當處於“魔流劍”狀態時，會獲得“魔焰”效果，使其攻擊力和攻速增加40%；
--每次切換形態時，會保留上個形態的強化效果，持續5秒（霹雳效果：每额外上阵一个霹雳侠客，会使上个形态的保留时间提升1秒）

---@class W_FengZH_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FengZH_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.addBuff1 = self:getParam(1)       -- Buff[]  嘯傲狂風
    self.addBuff2 = self:getParam(2)       -- Buff[]  劍•魔焰
    self.delayTime = self:getParam(3)       -- Fix[]  滞留时间
    self.addTime = self:getParam(4)       -- Fix[]  提升时间
    self.boomBuff = self:getParam(5) --死亡buff

    self.friendCount = 0 --霹雳人的数量
    self.totalTime = 0 -- 总滞留时间
    --EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

function M:spawn()
    M.super.spawn(self)
    local skill3Item = self.player.plySkill:getSkillByName("skill3")
    if skill3Item ~= nil then
        self.skill3 = skill3Item.cur_skill_config.feature
    end
end

--技能结束
function M:SkillEnterHandler(eventName, data)
    local ply = data["player"]
    local config = data["skillConfig"]

    if config ~= nil and self.player:equal(ply) and config == self.skill and self.player.master == nil then
        if self.skill3.skill3_stage == 1 then
            self.player.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
        elseif self.skill3.skill3_stage == 2 then
            self.player.bufMgr:addBufById(self.addBuff2, self.player, self.skill)
        end
    end
end

function M:changeState(state)
    if state == 1 then
        self.player.bufMgr:addBufById(self.addBuff1, self.player)
        TimeTools:stopTask(self.timeTask)
        self.timeTask = TimeTools:delayTime(self.totalTime, function()
            self.player.bufMgr:removeBufById(self.addBuff2)
        end)

    elseif state == 2 then
        self.player.bufMgr:addBufById(self.addBuff2, self.player)
        TimeTools:stopTask(self.timeTask)
        self.timeTask = TimeTools:delayTime(self.totalTime, function()
            self.player.bufMgr:removeBufById(self.addBuff1)
        end)
    end
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self:addFriendBuff()
end

function M:addFriendBuff()
    local friends = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend", ignoreSummon = true})
    local piliCnt = 0;
    for i = friends.Count, 1, -1 do
        local friend = friends:get(i-1)
        if friend and friend ~= self.player and table.indexof(Battle.EnumData.BATTLE_PLBDX_HERO_ID, tonumber(friend.plyData.id)) then
            piliCnt = piliCnt + 1
        end
    end
    self.friendCount = piliCnt
    self.totalTime = self.delayTime + GlobalTools:Mul(self.addTime, GlobalTools:ToFix(self.friendCount))
end

function M:dead(data)
    TimeTools:stopTask(self.timeTask)
    return M.super.dead(self, data)
end

function M:destroy()
    --EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    M.super.destroy(self)
end
return M
