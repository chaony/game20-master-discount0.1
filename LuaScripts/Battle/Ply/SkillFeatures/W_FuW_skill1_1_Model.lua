---@class W_FuW_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FuW_skill1_1_Model", SkillFeatures_Model)
local send_control = require("Battle.Ply.SkillFeaturesData.W_FuW_skill1_1_Data")

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.player.medMaxCount = self:getParam(1)
    self.hpRate = self:getParam(2)
    self.buff = self:getParam(3)
    self.damage = GlobalTools.base0;
    self:setMed(self.player.medMaxCount)
    EventDispatcher:registerEvent("injure", {self, self.injureHandle})
end

function M:spawn()
    M.super.spawn(self)
    self.skill0 = self.player.plySkill:getSkillByName("skill0")
end

function M:CreateHp()
    local headUIData = {}
    headUIData.uiName = "W_FuW_skill1";
    self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelCreateHeadUI, headUIData)
    --监听数据层让 播放特效
    --self:setMed(self.player.medMaxCount)
end

function M:setMed(count)
    if self.skill0 ~= nil and self.player.medCount == self.player.medMaxCount and count < self.player.medMaxCount then
        self.skill0.cur_skill_config:use()
    end
    if self.player.medCount == nil then
        self.player.medCount = count
    end
    local useCnt = self.player.medCount - count
    self.player.medCount = count
    self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelUpdateHeadUI, {count = count})
    
    if self.player.skyStar then
        self.player.skyStar:triggerStart(self, useCnt)
    end
end

function M:injureHandle(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    if victim ~= nil and victim:equal(self.player) then
        self.damage = self.damage + data.wantdata["damage"]
        local hp_rate = GlobalTools:Mul(self.player.data:get_hp(), self.hpRate)
        if self.damage >= hp_rate then
            if self:canUse() then
                self.damage = self.damage - hp_rate
                self:useMedicine()
            end
        end
    end
end

function M:canUse()
    if self.player.medCount > 0 then
        self:sendforControl()
        self:setMed(self.player.medCount - 1)
        return true
    else
        return false
    end
end

function M:useMedicine()
   -- self.player.bufMgr:addBufById(self.buff)
    if self.player:isLive() then
        self.player.bufMgr:addBufById(self.buff, self.player)
    end
end

--控制召唤物
function M:sendforControl()
    local enemys = SelectTargetTool:findPlayerByType(send_control["count"], self.player,true)
    if enemys.Count > 0 then
        local id = send_control["id"]
        for i = 1, self.player.summonList.list.Count do
            local key = self.player.summonList.list:get(i-1)
            if key == id then
                local plys = self.player.summonList:get(key)
                for i, v in ipairs(plys) do
                    local canUse = true
                    if v.aiEngine.curState.key == "skill" and string.match(v.summonData.animName, "skill3") ~= nil then
                        canUse = false
                    end
                    if canUse then
                        v.summonData.target = enemys:get(0)
                        v.summonData.targetDist = send_control["targetDist"]
                        v.summonData.animName = send_control["animName"]
                        v:set_curSkillConfig( self.player:get_curSkillConfig() )
                        v.aiEngine:changeState("skill")
                    end
                end
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    --if self.headUI ~= nil then
    --    self.headUI:destroy()
    --end
    if self.player ~= nil then
        self.player.bufMgr:removeBufById(self.buff, true, false)
    end
    EventDispatcher:unRegisterEvent("injure", {self, self.injureHandle})
end

return M