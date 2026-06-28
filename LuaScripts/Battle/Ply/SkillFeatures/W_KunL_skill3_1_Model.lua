--昆仑姐弟两在战斗中会共享生命值和能量，释放绝技时，两人会瞬移到战场中央一同演奏，
--演奏结束后，两人会提升己方侠客30%的攻击力、防御力、攻击速度、移动速度，持续6秒
---@class W_KunL_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_KunL_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
    EventDispatcher:registerEvent("selfHp", {self,self.conditionHandler})
    EventDispatcher:registerEvent("AngerUpdate", {self,self.AngerUpdateHandler})

    if self.player.summonList.Count > 0 then
        --删除宠物列表 
        for i = 1, self.player.summonList.list.Count do
            local key = self.player.summonList.list:get(i-1)
            local plys = self.player.summonList:get(key)
            for i, v in ipairs(plys) do
                self.player.plyMgr:destoryPlayer(v)
            end
        end
        self.player.summonList:clear();
    end

    local frame = self.player.evtMgr:getCommonEvent("Sendfor", 1)
    self.SendforData = frame.data
    local SendForFuncframe = require("Battle.Ply.Fuc.SendForFunc").new()
    SendForFuncframe:init(self.SendforData, self.player, nil, "idle")
end

function M:canUse()
    if self.other == nil then      -- 此时弟弟还没有召唤出来
        return false
    end
    if self:checkBuff(self.player) == true or self:checkBuff(self.other) == true then
        return false
    end
    return true
end

function M:checkBuff(ply)
    if ply == nil then     --容错
        return true
    end
    local imprisonBuff = ply.bufMgr:findBufByType("Imprison")
    if #imprisonBuff > 0 then
        return true
    end
    local charmBuff = ply.bufMgr:findBufByType("Charm")
    if #charmBuff > 0 then
        return true
    end
    local NoSkillBuff = ply.bufMgr:findBufByType("NoSkill")
    for k, v in ipairs(NoSkillBuff) do
        if v.skill3 == false then
            return true
        end
    end
end

--初始化完成
function M:initFinish()
    M.super.initFinish(self)
    --如果之前创建过宠物需要先销毁掉
    if self.player.summonList.Count == 0 then
        local frame = self.player.evtMgr:getCommonEvent("Sendfor", 1)
        self.SendforData = frame.data
        local SendForFuncframe = require("Battle.Ply.Fuc.SendForFunc").new()
        SendForFuncframe:init(self.SendforData, self.player, nil, "idle")
    end
end

--出生完成
function M:spawnFinish()
    M.super.spawnFinish(self)
    local skill1Item = self.player.plySkill:getSkillByName("skill1")
    if skill1Item ~= nil then
        self.skill1 = skill1Item.cur_skill_config.feature
    end
    local skill2Item = self.player.plySkill:getSkillByName("skill2")
    if skill2Item ~= nil then
        self.skill2 = skill2Item.cur_skill_config.feature
    end
    if self.other ~= nil then
        self:setSendForAttr(self.other)
    end
end

--召唤成功
function M:sendForHandler( eventName, data )
    local player = data["player"]
    if self.player:equal(player.master) == true then
        self.other = player
        --self:setSendForAttr(player)
    end
end

function M:setSendForAttr(player)
    player.data.hp:setInitialValue(player.data:getCopyData(self.player.data.hp, true, GlobalTools.base1))
    player.data.atk:setInitialValue(player.data:getCopyData(self.player.data.atk, true, GlobalTools.base1))
    player.data.def:setInitialValue(player.data:getCopyData(self.player.data.def, true, GlobalTools.base1))
    player.data.hp = self.player.data.hp
    player.data:set_curHp(player.data:get_hp())

    self.other.aiEngine:changeState("idle")

    local otherSkill1Item = self.other.plySkill:getSkillByName("skill1")
    if otherSkill1Item ~= nil then
        self.otherSkill1 = otherSkill1Item.cur_skill_config.feature
    end

    if self.skill1 ~= nil and self.skill1.SendForFinish ~= nil then
        self.skill1:SendForFinish(self.other)
    end
    if self.otherSkill1 ~= nil and self.otherSkill1.SendForFinish ~= nil then
        self.otherSkill1:SendForFinish()
    end
    if self.skill2 ~= nil and self.skill2.SendForFinish ~= nil then
        self.skill2:SendForFinish()
    end
end

--血量改变
function M:conditionHandler( eventName, data )
    local player = data["ply"]
    if self.other ~= nil and self.other:isLive() == true and self.player:isLive() == true then
        if self.player.data:get_curHp() ~= self.other.data:get_curHp() then
            if self.player:equal(player) then
                self.other.data:set_curHp(self.player.data:get_curHp())
            elseif self.other:equal(player) then
                self.player.data:set_curHp(self.other.data:get_curHp())                
            end
        end
    end
end

--怒气改变
function M:AngerUpdateHandler( eventName, data )
    local player = data.data
    if self.other ~= nil and self.other:isLive() == true and self.player:isLive() == true then
        if self.player.data:get_curAnger() ~= self.other.data:get_curAnger() then
            if self.player:equal(player) then
                self.other.data:set_anger(self.player.data:get_curAnger())
            elseif self.other:equal(player) then
                self.player.data:set_anger(self.other.data:get_curAnger())
            end
        end
    end
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.other ~= nil then
        self.other:useSkill("skill3", true)
    end
end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("selfHp", {self,self.conditionHandler})
    EventDispatcher:unRegisterEvent("AngerUpdate", {self,self.AngerUpdateHandler})
    EventDispatcher:unRegisterEvent("SendForFinish", {self,self.sendForHandler})
    M.super.destroy(self)
end

return M