--战斗开始时，我方场上每有一个攻击力低于武则天的角色，武则天便会额外获得其5%攻击力的加成，该效果会持续到战斗结束，若场上同时存在狄仁杰，则通过该效果获得的加成会提升50%
--LV4该技能还会额外选择三名随机敌方侠客，若其攻击力低于武则天，则武则天会吸取其10%的攻击力加给自己

---@class W_WuZT_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WuZT_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.buffId1 = self:getParam(1)       --5%攻击力的加成
    self.buffId2 = self:getParam(2)       --同时存在狄仁杰，则通过该效果获得的加成会提升50%
    self.enemyNums = self:getParam(3)      --额外选择三名随机敌方侠客
    self.buffId3 = self:getParam(4)      --吸取攻击力的buff 吸别人给自己加
    self.buffId4 = self:getParam(5)      --给敌人的被吸取10%的攻击力
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    local friends = SelectTargetUtil:findPlayerByParam(self.player, {
        camp = "friend",
        ignoreSummon = true,
        pos = "forceLeast",
        --priority = true,
    })
    local breakAddBuff = false
    local useExtraBuff = false
    local addBuffNums = 0
    for i = 1, friends.Count do
        local friend = friends:get(i - 1)
        if friend then
            if friend.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.WuZT then
                breakAddBuff = true
            elseif friend.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.DiRJ then
                useExtraBuff = true
            end
            if not breakAddBuff then
                addBuffNums = addBuffNums + 1
            end
        end
    end
    if addBuffNums > 0 then
        for i = 1, addBuffNums do
            if useExtraBuff then
                self.player.bufMgr:addBufById(self.buffId2, self.player, self.skill)
            else
                self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
            end
        end
    end

    if self.enemyNums > 0 then
        local enemies = SelectTargetUtil:findPlayerByParam(self.player, {
            camp = "enemy",
            ignoreSummon = true,
            pos = "forceLeast",
            --priority = true,
        })
        local addNums = 0
        for i = 1, enemies.Count do
            if addNums < self.enemyNums then
                local ememy = enemies:get(i - 1)
                if ememy and ememy.bufMgr then
                    if ememy.data.atk:getValue() < self.player.data.atk:getValue() then
                        self.player.bufMgr:addBufById(self.buffId3, ememy, self.skill)
                        ememy.bufMgr:addBufById(self.buffId4, self.player, self.skill)
                        addNums = addNums + 1
                    end
                end
            end
        end
    end
end

return M
