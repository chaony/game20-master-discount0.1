--每进行三次普攻，随机为一个敌人添加一种“七伤”诅咒，每种诅咒会为敌方施加不同的负面状态
---@class W_WanH_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WanH_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.atkCount = self:getParam(1)
    self.curse1 = self:getParam(2)
    self.curse2 = self:getParam(3)
    self.curse3 = self:getParam(4)
    self.curse4 = self:getParam(5)
    self.curse5 = self:getParam(6)
    self.curse6 = self:getParam(7)
    self.curse7 = self:getParam(8)
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    self.curAtkCount = 0
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    if self.player:equal(ply) and config.anim_name == "attack1" then
        self.curAtkCount = self.curAtkCount + 1
        if self.curAtkCount > self.atkCount then
            self.curAtkCount = 1
        end
    end
end

function M:injureHandler(eventName, data)
    if self.curAtkCount == self.atkCount then
        local ply = data["killer"]
        local victim = data["victim"]
        local skillConfig = data["attackData"]["skillConfig"]
        if ply ~= nil and ply:equal(self.player) and skillConfig ~= nil and skillConfig.anim_name == "attack1"  then
            self:addCurse(victim)
            self.curAtkCount = 0
        end
    end
end

--施加诅咒
function M:addCurse(target)
    if target ~= nil and target:isLive() then
        local tempBuff = {}
        for i = 1, 7 do
            local buff = target.bufMgr:findBufById(self["curse"..i])
            if #buff == 0 then
                table.insert(tempBuff, self["curse"..i])
            end
        end
        local param = {}
        param["target"] = target
        if #tempBuff > 0 then
            local index = WRandom:randomNum(1, #tempBuff + 1, true)
            target.bufMgr:addBufById(tempBuff[index], self.player)
            param["index"] = self:getCurseIndex(tempBuff[index])
            self:dispatchEvent_Local(Battle.SkillEventType.MV_W_WanH_skill1_1_Model_ShowEffect, param)
        else
            local index = WRandom:randomNum(1, 8, true)
            target.bufMgr:addBufById(self["curse"..index], self.player)
            param["index"] = index
            self:dispatchEvent_Local(Battle.SkillEventType.MV_W_WanH_skill1_1_Model_ShowEffect, param)
        end
    end
end

function M:getCurseIndex(buffId)
    for i = 1, 7 do
        if self["curse"..i] == buffId then
            return i
        end
    end
    return 0
end

function M:getCurseCount(target)
    if target ~= nil and target:isLive() then
        local buff = target.bufMgr:findBufByTag("W_WanH_skill1")
        return #buff
    else
        return 0
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end
return M