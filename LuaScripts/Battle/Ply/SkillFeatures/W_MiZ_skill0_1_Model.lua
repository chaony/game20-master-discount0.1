--密宗    龙象马牛
---@class W_MiZ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MiZ_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.shardDamageBuffId = self:getParam(1)  --[Buff] 分担伤害buffid
    self.shieldBuffId = self:getParam(2)  --[Buff] 护盾buffid
    self.shardFriend = nil  -- 被分担伤害的队友
    EventDispatcher:registerEvent("relive", {self,self.relive})
end

function M:spawn()
    self.skill1 = self.player.plySkill:getSkillByName("skill1")
    -- 设置复活动画
    local reliveState = self.player.aiEngine:getStateByName("relive")
    reliveState.extra_anim_name = "skill1"
    reliveState.disappearTime = GlobalTools.base0_5

    -- 设置死亡动画
    local dieState = self.player.aiEngine:getStateByName("die_into")
    dieState.extra_anim_name = "die"
    dieState.disappearTime = GlobalTools.base1_7
    M.super.spawn(self)
end

function M:canUse()
    if not self:isInNirvana() then
        return self:findTargetFriend() ~= nil
    end
    return M.super.canUse(self)
end


function M:skillStart(data)
    M.super.skillStart(self,data)
    self:castSkillEffect();
end

--复活调用
function M:relive( eventName, data )
    
end


--- 释放技能效果 【被动技能】
function M:castSkillEffect()
    if self:isInNirvana() then
        self:doAddShieldEffect()
    else
        self:doShardDamageEffect()
    end
end

--- 为友方目标分担伤害
function M:doShardDamageEffect()
    local friend = self:findTargetFriend()
    if friend then
        friend.bufMgr:addBufById(self.shardDamageBuffId, self.player, self.skill)
        self.shardFriend = friend
    end
end

--- 为自己和友方添加护盾
function M:doAddShieldEffect()
    self.player.bufMgr:addBufById(self.shieldBuffId, self.player, self.skill)
    local friend = self:findTargetFriend()
    if friend then
        friend.bufMgr:addBufById(self.shieldBuffId, self.player, self.skill)
    end
end

---@param data Battle_EventData_Dead
function M:dead(data)
    self:removeShardEffect()
    M.super.dead(self, data)
end

function M:removeShardEffect()
    if self.shardFriend then
        self.shardFriend.bufMgr:removeBufById(self.shardDamageBuffId, true, true)
        --local buffs = self.shardFriend.bufMgr:findBufByTag("MiZ_skill0")
        --for i, v in ipairs(buffs) do
        --    if self.player:equal(v.source) then
        --        self.shardFriend.bufMgr:removeBuf(v, true)
        --    end
        --end
        self.shardFriend = nil
    end
end

function M:isInNirvana()
    if self.skill1 and self.skill1.cur_skill_config then
        ---@type W_MiZ_skill1_1_Model
        local feature = self.skill1.cur_skill_config.feature
        return feature:isInNirvana()
    end
    return false
end

---@return PlayerModel 找除自己外的防御最高的角色
function M:findTargetFriend()
    local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    local maxDef = nil
    local targetFriend = nil
    for i = 1, friends.Count do
        ---@type PlayerModel
        local friend = friends:get(i - 1)
        if friend:equal(self.player) == false and friend:isLive() then
            if (not maxDef) or maxDef < friend.data.def:getValue() then
                maxDef = friend.data.def:getValue()
                targetFriend = friend
            end
        end
    end
    return targetFriend
end


function M:destroy()
    EventDispatcher:unRegisterEvent("relive", {self,self.relive})
    M.super.destroy(self)
end

return M