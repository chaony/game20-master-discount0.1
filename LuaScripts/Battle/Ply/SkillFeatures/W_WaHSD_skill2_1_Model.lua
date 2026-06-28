--开场时，娲皇神殿与友方攻击力最高的侠客进行月相连结，连结后双方攻速提升20点，攻击力提升12%；
--若连结侠客为天墉城则攻速提升25点，攻击力提升24%。连结中任意角色死亡则取消连结，娲皇神殿不会重新进行连结。（该技能优先选择天墉城）

---@class W_WaHSD_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
---@field line Line_Model
local M = class("W_WaHSD_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.linkBuff = self:getParam(1)       --Buff[] 普通链接buff
    self.linkBuff2 = self:getParam(2)       --Buff[] 天墉城链接buff
    self.resistBuff = self:getParam(3)       --Buff[] 抵抗眩晕buff
    self.linkDeadBuff = self:getParam(4)       --Buff[] 连接对象死亡buff
    self.linkDeadBuff2 = self:getParam(5)       --Buff[] 天墉城连接死亡buff
    self.deadBuff = self:getParam(6)       --Buff[] 免死buff
    self.deadBuff2 = self:getParam(7)       --Buff[] 同陣營的免死buff
    self.linkTarget = nil       -- 连接对象

    self.line = nil
    self.noDead = true;
    --EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    
    self:connectTarget()
end

-- 连接
function M:connectTarget()
    local target = self:findMaxAtkFriend()
    if target then
        local hookData
        --if target.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.TianYC then
        --    hookData = self.player.evtMgr:getCommonEventByKey("Hook", 2)
        --else
            hookData = self.player.evtMgr:getCommonEventByKey("Hook", 1)
        --end
        local lineData = table.copy(hookData.data)
        --加载预制
        self.line = require("Battle.Line.Line_Model").new()
        self.line:init(lineData, self.player, self.player, target)
        --将连线加入到管理器
        self.player.lineMgr:addLine(self.line)
        self.linkTarget = self.line.target

        --if self.linkTarget.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.TianYC then
        --    self.player.bufMgr:addBufById(self.linkBuff2, self.player, self.skill)
        --    target.bufMgr:addBufById(self.linkBuff2, self.player, self.skill)
        --    target.bufMgr:addBufById(self.resistBuff, self.player, self.skill)
        --else
            self.player.bufMgr:addBufById(self.linkBuff, self.player, self.skill)
            target.bufMgr:addBufById(self.linkBuff, self.player, self.skill)
            --target.bufMgr:addBufById(self.resistBuff, self.player, self.skill)
        --end
    end
end

function M:injureHandler(eventName, eventData)
    if self.noDead and self.deadBuff ~= 0 and self.linkTarget ~= nil and self.linkTarget:isLive() then
        if self.player:equal(eventData.victim) or self.linkTarget:equal(eventData.victim) then
            if eventData.victim:isAttackCauseDeath(eventData.attackData, eventData.wantdata) then   -- 本次伤害将会造成击杀
                self.noDead = false
                -- 免疫本次伤害
                eventData.wantdata.damage = 0
                -- 给自己加一个buff
                if self.player.plyData.race == self.linkTarget.plyData.race then
                    self.player.bufMgr:addBufById(self.deadBuff2, self.player, self.skill)
                    self.linkTarget.bufMgr:addBufById(self.deadBuff2, self.player, self.skill)
                else
                    self.player.bufMgr:addBufById(self.deadBuff, self.player, self.skill)
                    self.linkTarget.bufMgr:addBufById(self.deadBuff, self.player, self.skill)
                end
            end
        end
    end
end

-----@param eventData Battle_HandleData_KillPlayer
--function M:killerPlayerHandler(eventName, eventData)
--    if self.linkTarget then -- 有连接目标
--        if self.linkTarget:equal(eventData.victim) or self.player:equal(eventData.victim) then      -- 双方有一方已经死亡
--            self:cancelConnectTarget(eventData.victim)
--            if self.linkTarget:equal(eventData.victim) then
--                self:onLinkTargetDead()
--            end
--            self.linkTarget = nil
--        end
--    end
--end

-----@param deadPlayer PlayerModel
--function M:cancelConnectTarget(deadPlayer)
--    if self.line then
--        self.player.lineMgr:removeLine(self.line)
--        self.line:destroy()
--        self.line = nil
--    end
--
--    if self.linkTarget.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.TianYC then
--        self.player.bufMgr:addBufById(self.linkBuff2, self.player, self.skill)
--        self.linkTarget.bufMgr:addBufById(self.linkBuff2, self.player, self.skill)
--        self.linkTarget.bufMgr:addBufById(self.resistBuff, self.player, self.skill)
--    else
--        self.player.bufMgr:addBufById(self.linkBuff, self.player, self.skill)
--        self.linkTarget.bufMgr:addBufById(self.linkBuff, self.player, self.skill)
--        self.linkTarget.bufMgr:addBufById(self.resistBuff, self.player, self.skill)
--    end
--end

---- 连接对象失败
--function M:onLinkTargetDead()
--    if self.linkTarget.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.TianYC then
--        self.player.bufMgr:addBufById(self.linkDeadBuff2, self.player, self.skill)
--    else
--        self.player.bufMgr:addBufById(self.linkDeadBuff, self.player, self.skill)
--    end
--end

---@return PlayerModel
function M:findMaxAtkFriend()
    local friends = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friendExceptSelf"})
    local maxAtk = 0
    local linFriend = nil
    for i = 1, friends.Count do
        local friend = friends:get(i - 1)
        if friend:isLive() then
            --if friend.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.TianYC then       -- 优先寻找天墉城
            --    linFriend = friend
            --    break
            --end
            if maxAtk <= friend.data.atk:getValue() then
                maxAtk = friend.data.atk:getValue()
                linFriend = friend
            end
        end
    end
    return linFriend
end

function M:destroy()
    self.line = nil
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    --EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    M.super.destroy(self)
end

return M
