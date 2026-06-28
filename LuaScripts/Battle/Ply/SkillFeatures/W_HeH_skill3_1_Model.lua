--合欢选取场上最多3名女性侠客并召唤其幻影，幻影拥有原侠客60%的属性，且会受到150%的伤害，召唤出来的幻影只能使用普攻。
---@class W_HeH_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HeH_skill3_1_Model", SkillFeatures_Model)

M.effectPrefab = "W_Heh_Skill3_Born_001"

M.summonList = nil

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    --宠物信息
    local summonData = require("Battle.Ply.SkillFeaturesData.W_HeH_skill3_1_Data")
    self.summonData = table.copy(summonData)

    self.attrRate = self:getParam(1)
    --攻击力buff
    self.extraAttr = self:getParam(2)
    --减伤buff
    self.buff1 = self:getParam(3)
    --封印技能buff
    self.buff2 = self:getParam(4)
    --属性提升比例
    self.attrAddRate = self:getParam(5)
    --己方材质
    self.friendBuff = self:getParam(6)
    --敌方材质
    self.enemyBuff = self:getParam(7)
    --召唤幻影个数
    self.maxSummon = 1
    self.summonList = {}
    
    self.targetInitHp = 0
    self.targetInitAtk = 0
    self.targetInitDef = 0
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
end

--死亡回调
function M:deadHandler( eventName, data )
    local player = data["data"]
    for i, summon in ipairs(self.summonList) do
        if summon:equal(player) then
            table.remove(self.summonList, i)
            break
        end
    end
end

function M:canUse()
    local womanList = self:findGirl()
    if #womanList > 0 then
        return true
    end
    return false
end

function M:findGirl(...)
    local womanList = {}
    local womanListNoRepeat = {}
    local girls = SelectTargetUtil:findPlayerByParam(self.player, {gender = "woman", ignoreSummon = true})
    
    for i = 1, girls.Count do
        local girl = girls:get(i - 1)
        if girl:isLive() then
            table.insert(womanList, girl)
            if self:checkRepeat(girl) == false then
                table.insert(womanListNoRepeat, girl)
            end
        end
    end

    return womanList, womanListNoRepeat
end

function M:skillDispatch(data)
    if data.eventName == "summon" then
        self:summonHandle(data)
    end
end

function M:summonHandle(data)
    local max = math.min(self.maxSummon, 3) -- 容错，最多召唤3个
    local delay = 0
    local index = 0
    for i = 1, max do
        if self.summonList[i] then  -- 如果存在
            self:summonOne(i, data)
        else
            if index == 0 then      -- 第一个召唤不需要延迟
                self:summonOne(i, data)
            else
                if delay > 0 then   -- 第二个及以后的召唤延迟0.2s
                    TimeTools:delayTime(delay, function()
                        self:summonOne(i, data)
                    end)
                end
            end
            index = index + 1
            delay = delay + GlobalTools.base0_2
        end
    end
end


function M:summonOne(i, data)
    local frame = data.frame
    if frame.player:equal(self.player) then
        local womanList,womanListNoRepeat= self:findGirl()
        local summon = self.summonList[i]
        if summon == nil then
            ---@type PlayerModel
            local target = nil
            if #womanListNoRepeat > 0 then
                target = womanListNoRepeat[WRandom:randomNum(1, #womanListNoRepeat, true)]
            else
                target = womanList[WRandom:randomNum(1, #womanList, true)]
            end
            if target ~= nil then
                local summonData = table.copy(self.summonData)
                summonData.summonName = target.plyData.id
                local SendForFuncFrame = require("Battle.Ply.Fuc.SendForFunc").new()
                local ply = self.player
                SendForFuncFrame:init(summonData, ply)
                local summon = SendForFuncFrame.player
                if summon ~= nil then
                    self.summonList[i] = summon
                    summon.loadPlayerViewFinish = function()
                        if summon ~= nil then
                            self:playEffect(summon)
                            summon:ShowHpBar(true)
                        end
                    end

                    --table.insert(self.summonList, summon)
                    summon.data:get_level( target.data:get_level() )
                    summon.data:set_evo( target.data:get_evo() )
                    summon.plySkill:refreshSkill(nil)
                    local attr = self.attrRate + GlobalTools:Mul( GlobalTools:ToFix(#womanList - 1), self.extraAttr)
                    summon.data.hp:setInitialValue(summon.data:getCopyData(target.data.hp, true, attr))
                    summon.data.atk:setInitialValue(summon.data:getCopyData(target.data.atk, true, attr))
                    summon.data.def:setInitialValue(summon.data:getCopyData(target.data.def, true, attr))

                    self.targetInitHp = target.data.hp:getInitialValue()
                    self.targetInitAtk = target.data.atk:getInitialValue()
                    self.targetInitDef = target.data.def:getInitialValue()

                    summon.data:set_curHp(summon.data:get_hp())
                    summon.bufMgr:addBufById(self.buff1, self.player)
                    summon.bufMgr:addBufById(self.buff2, self.player)
                    if summon.camp == 1 then
                        summon.bufMgr:addBufById(self.friendBuff, self.player)
                    else
                        summon.bufMgr:addBufById(self.enemyBuff, self.player)
                    end
                    summon:setPos(target.position + target:getForward() * GlobalTools.base2);
                    summon.aiEngine:changeState("idle")
                end
            end
        else
            self:attrAdd(summon)
            self:playEffect(summon)
            summon:ShowHpBar(true)
        end
    end
end


--女性幻影属性提升
function M:attrAdd(summon)
    if summon ~= nil then
        --summon.data.hp:addToMAAList(self.attrAddRate, "skill3")
        --summon.data.atk:addToMAAList(self.attrAddRate, "skill3")
        --summon.data.def:addToMAAList(self.attrAddRate, "skill3")
        summon.data.hp:addToAddList(GlobalTools:Mul(self.attrAddRate, self.targetInitHp))
        summon.data.atk:addToAddList(GlobalTools:Mul(self.attrAddRate, self.targetInitAtk))
        summon.data.def:addToAddList(GlobalTools:Mul(self.attrAddRate, self.targetInitDef))
        summon.data:set_curHp(summon.data.hp:getValue())
    end
end


function M:checkRepeat(player)
    for k,v in ipairs(self.summonList) do
        if v.plyData.id == player.plyData.id then
            return true
        end
    end
    return false
end

function M:playEffect(player)
    local data = {}
    data.player = player;
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_HeH_skill3_1_Model_PlayEffect, data)
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

return M