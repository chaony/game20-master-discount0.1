-- 聂隐娘对单个敌人发起攻击，造成200%的伤害，受到伤害的敌人会受到【摄魂】效果，在下次释放绝技之前，造成的伤害都将降低50%，
--如果是术士或辅助侠客，则还会在下次释放绝技之前受到的伤害提高30%。
--伤害降低效果提高至70%
--受到伤害效果提高至50%
--受到【摄魂】效果影响的敌人，被普攻命中时，会降低20点内力
---@class W_NieYN_skill2_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_NieYN_skill2_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffTag = "W_NieYN_SheHun"--self:getParam(1) --摄魂tag
    self.roleTypeArray = self:getParam(1) --职业
    self.extraBuf = self:getParam(2) --如果是术士或辅助侠客，则还会在下次释放绝技之前受到的伤害提高30%。
    self.anger = self:getParam(3) --被普攻命中时，会降低20点内力
    EventDispatcher:registerEvent("SkillEnter", {self,self.skillEnterHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:killerAfterAttack(data)
    if self.player:equal(data.killer) and data.attackData.skillConfig == self.skill and data.victim ~= nil and data.victim:isLive() and data.victim.bufMgr ~= nil and table.indexof(self.roleTypeArray, data.victim.plyData.role_type) then
        data.victim.bufMgr:addBufById(self.extraBuf , self.player, self.skill)
    end
end

function M:injureHandler(eventName, eventData)
    local victim = eventData.victim
    local skill = eventData.attackData.skillConfig

    if self.anger > 0 and skill ~= nil and skill.anim_name == "attack1" and victim  ~= nil and victim:isLive() and victim.bufMgr ~= nil and victim.bufMgr:hasBufByTag(self.buffTag) then
        victim.data:addAnger(-self.anger)
    end
end

--技能释放
function M:skillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    if ply ~=nil and ply:isLive() and ply.bufMgr ~= nil and ply.bufMgr:hasBufByTag(self.buffTag) and config ~= nil and  config.anim_name == "skill3" then
        ply.bufMgr:removeBufByTag(self.buffTag)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.skillEnterHandler})
    M.super.destroy(self)
end

return M