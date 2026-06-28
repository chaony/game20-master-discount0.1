--处于天香领域中的每个友方侠客都会为小乔提供10%的伤害减免，当小乔受到致命伤害时，若天香领域中存在其他友军，则小乔会免疫本次伤害且每存在1个友军，小乔便会获得1秒无敌效果；若天香领域中存在周瑜，则小乔还会立即将生命值恢复至与周瑜生命百分比相同，改技能1场战斗中仅能触发1次
--每个友军为小乔提供的伤害减免提升至15%
--触发该技能时，天香领域中友军会立即将攻击目标转移至攻击者，且攻速增加30%，持续5秒
--触发该技能时，天香领域中友军会立即将攻击目标转移至攻击者，且攻速增加40%，持续5秒
---@class W_XiaoQ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field skill2 W_XiaoQ_skill2_1_Model
local M = class("W_XiaoQ_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.resatdValue = self:getParam(1) -- 每个友方侠客都会为小乔提供resatdValue的伤害减免
    self.invincibleBuffs = { self:getParam(2), self:getParam(3), self:getParam(4), self:getParam(5),self:getParam(6)}--友军数量提供的无敌buff id
    self.hasteBuff = self:getParam(7) -- 天香领域中友军会立即将攻击目标转移至攻击者，且添加攻速hasteBuff

    local skill2 = self.player.plySkill:getSkillByName("skill2")
    self.skill2 = skill2.cur_skill_config.feature
    self.hasTriggered = false
    self.lastResatdValue = 0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:addResatdValue()
    local friendsCount,playerZhouY = self:getFriendParamInArea()
    if self.lastResatdValue > 0 then
        self.player.data.resatd:removeFromMulList(self.lastResatdValue)
    end
    self.lastResatdValue = GlobalTools:Mul(self.resatdValue, GlobalTools:ToFix(friendsCount))
    if self.lastResatdValue > 0 then
        self.player.data.resatd:addToMulList(self.lastResatdValue)
    end
end

--作为受伤者的属性临时调整
function M:victimDataChangeTemp(killer, skill)
    self:addResatdValue()
end

function M:getFriendParamInArea()
    local friendsCount = 0
    local playerZhouY = nil
    for i = self.skill2.areaIn.Count, 1, -1 do
        local friend = self.skill2.areaIn:get(i - 1)
        if friend ~= nil and friend:isLive() then
            friendsCount = friendsCount + 1
            if friend.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.ZhouY then
                playerZhouY = friend
            end
        end
    end
    return friendsCount,playerZhouY
end

function M:injureHandler(eventName, eventData)
    if not self.hasTriggered then
        if self.player:equal(eventData.victim) then
            if self.player:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
                local friendsCount,playerZhouY = self:getFriendParamInArea()

                if friendsCount > 1 then   -- 若天香领域中存在其他友军
                    self.hasTriggered = true
                    -- 免疫本次伤害
                    eventData.wantdata.damage = 0
                    -- 给自己加一个无敌buff
                    self.player.bufMgr:addBufById(self.invincibleBuffs[friendsCount - 1], self.player, self.skill)
                    --若天香领域中存在周瑜，则小乔还会立即将生命值恢复至满血
                    if playerZhouY ~= nil and playerZhouY:isLive() then
                        local cure_value = self.player.data:get_hp() - self.player.data:get_curHp()
                        if cure_value > 0 then
                            self.player:cure("fix", self.player, cure_value, self.skill )
                        end
                    end
                    --触发该技能时，天香领域中友军会立即将攻击目标转移至攻击者，且攻速增加30%，持续5秒
                    if self.hasteBuff > 0 and eventData.killer ~= nil and eventData.killer:isLive() then
                        for i = self.skill2.areaIn.Count, 1, -1 do
                            local friend = self.skill2.areaIn:get(i - 1)
                            if friend ~= nil and friend:isLive() then
                                friend:lockEnemy(eventData.killer)
                                friend.bufMgr:addBufById(self.hasteBuff, self.player, self.skill)
                            end
                        end
                    end
                end
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M