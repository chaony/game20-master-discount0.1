--战斗开始时，小乔会在我方阵营中布下“天香领域”，处于天香领域中的友方侠客，最大血量提升30%，防御力提升50%，处于天香领域中的侠客在受到攻击时，受到的伤害会被“吸收”20%，天香领域会在小乔死亡时消失（吸收：计算伤害时，会先计算吸收值，再计算伤害减免）
--若周瑜存在与天香领域中，则周瑜获得的增益效果不会消失
--最大血量提升至40%，防御力提升至60%
--天香领域的吸收效果增加至30%
--小乔死亡时，天香领域依然会存在6秒
---@class W_XiaoQ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XiaoQ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1) --处于天香领域中的友方侠客获得buff  buff_tag为W_XiaoQ_Skill2
    self.reduceDamagePer = self:getParam(2) -- 吸收伤害百分比
    self.disapearTime = self:getParam(3)--死亡后残留的时间
    self.canUseSkill = false;
    self.areaIn = Battle.List.new()
    self.areaOut = Battle.List.new()
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    BattleTool:safeTriggerActionEventWork(self.player, "skill2", "SpecialAreaEffect", 1)
    self.center = SelectTargetTool:findFixPoint(self.player, "sceneCenter")
    --SelectTargetTool:findFixPoint(self.player, "sceneCenter")
    --local friendList = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    local friendList = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend", ignoreSummon = true})
    local index = self.player.index
    for i = 1, friendList.Count do
        local friend = friendList:get(i - 1)
        if friend.plyType == self.player.plyType and index > friend.index then
            index = friend.index
        end
    end
    self.canUseSkill = (index == self.player.index)
    for i = 1, friendList.Count do
        self:addBuff(friendList:get(i - 1))
        --self.areaIn:add(friendList:get(i - 1))
    end
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil then
        skill0.cur_skill_config.feature:addResatdValue()
    end
end

function M:canUse()
    if self.player and self.player.bufMgr then
        local charmBuff = self.player.bufMgr:findBufByType("Charm")
        if #charmBuff > 0 then
            return false
        end
    end
    return self.canUseSkill
end


function M:update(dt,unsdt)
    for i = 1, self.areaOut.Count do
        local ply = self.areaOut:get(i - 1)
        if ply ~= nil  then
            if self.player.camp == 1 and ply.position.x < self.center.x then
                self:addBuff(ply)
            elseif self.player.camp == -1 and ply.position.x > self.center.x then
                self:addBuff(ply)
            end
        end
    end

    for i = 1, self.areaIn.Count do
        local ply = self.areaIn:get(i - 1)
        if ply ~= nil  then
            if self.player.camp == 1 and ply.position.x >= self.center.x then
                self:removeBuff(ply)
            elseif self.player.camp == -1 and ply.position.x <= self.center.x then
                self:removeBuff(ply)
            end
        end
    end
end

function M:addBuff(ply)
    self.areaIn:add(ply)
    self.areaOut:remove(ply)
    ply.bufMgr:addBufById(self.buffId, self.player)
end

function M:removeBuff(ply)
    if ply.playerId ~= Battle.EnumData.BATTLE_SPECIAL_HERO_ID.ZhouY then
        self.areaIn:remove(ply)
        self.areaOut:add(ply)
        ply.bufMgr:removeBufByTag("W_XiaoQ_Skill2")
    end
end



function M:killerPlayerHandler(eventName, data)
    if self.player:equal(data.victim) and self.player.master == nil then
        local disappearTime = self.disapearTime > 0 and self.disapearTime or GlobalTools.base0_1
        TimeTools:delayTime(disappearTime,function()
            local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
            friends:safeWalkInverted(function(ply)
                if ply ~= nil and ply:isLive() and ply.playerId ~= Battle.EnumData.BATTLE_SPECIAL_HERO_ID.ZhouY then
                    ply.bufMgr:removeBufByTag("W_XiaoQ_Skill2")
                end
            end)
        end)
    end
end

function M:injureHandler(eventName, eventData)
    if  eventData.victim ~= nil and eventData.victim.camp == self.player.camp and eventData.victim.bufMgr ~= nil and eventData.victim.bufMgr:hasBufByTag("W_XiaoQ_Skill2")  then
        local recordDamage = GlobalTools:Mul(self.reduceDamagePer, eventData.wantdata.damage)
        eventData.wantdata.damage = eventData.wantdata.damage - recordDamage
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M