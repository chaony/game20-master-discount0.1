--被【铁锁连环】命中的敌人，将被施加1层持续8秒的“引燃”状态，引燃状态下的敌人，每秒会受到80%攻击力的伤害（不会施加引燃），且内伤减免会降低10%，
--引燃状态最多可以叠加3层，当引燃状态叠加至3层时，若再次被周瑜技能命中，则会立即清除敌人身上所有引燃状态并升级为“焚烬”状态，
--焚烬状态会持续5秒，每秒会造成300%攻击力的伤害（不会施加引燃），内伤减免降低50%，且无法通过普攻和技能恢复内力，
--焚烬状态持续期间，敌人无法再被施加引燃状态，引燃状态和焚烬状态无法免疫和清除
--引燃状态伤害提升至100%攻击力
--焚烬状态下，敌人每秒还会减少20点内力
--普攻也有20%的概率对目标施加“引燃”效果
---@class W_ZhouY_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhouY_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffEffectTab = {}
    for i = 1, 3 do
        self.buffEffectTab[i] = self:getParam(i)  -- tag W_ZhouY_YinRan_Head  用于头顶换buff
    end
    self.yinRanBuff = self:getParam(4)--引燃buff
    self.fenJinBuff = self:getParam(5)--焚尽buff
    self.attack1Rate = self:getParam(6)--普攻也有20%的概率
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("add_W_ZhouY_YinRan", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_ZhouY_YinRan", {self,self.removeBuffHandler})
end

function M:canUse()
    return false
end

function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then
        local yinRanBuffs = eventData.buff.player.bufMgr:findBufByTag("W_ZhouY_YinRan")
        local yinRanCount = #yinRanBuffs
        yinRanCount = yinRanCount > #(self.buffEffectTab) and #(self.buffEffectTab) or yinRanCount
        eventData.buff.player.bufMgr:removeBufByTag("W_ZhouY_YinRan_Head",true)
        eventData.buff.player.bufMgr:addBufById(self.buffEffectTab[yinRanCount], self.player, self.skill)
    end
end

function M:removeBuffHandler( eventName, data )
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
            buff.player.bufMgr:removeBufByTag("W_ZhouY_YinRan_Head",true)
    end
end

function M:injureHandler(eventName, eventData)
    local victim = eventData.victim
    local killer = eventData.killer
    local skill = eventData.attackData.skillConfig
    if  killer ~= nil and skill ~= nil and (eventData.attackData.sourceBuff == nil or eventData.attackData.sourceBuff.sourceType == 1) and self.player:equal(killer) and eventData.victim.bufMgr ~= nil  then
        local canAddBuf = skill.anim_name == "skill2"
        if not canAddBuf and self.attack1Rate > 0 then
            canAddBuf = skill.anim_name == "attack1" and WRandom:randomNum(0, GlobalTools.base1,true) < self.attack1Rate
        end
        if canAddBuf then
            local yinRanBuffs = victim.bufMgr:findBufByTag("W_ZhouY_YinRan")
            local hasFenJin = victim.bufMgr:hasBufByTag("W_ZhouY_FenJin")
            if #yinRanBuffs >= 3 then
                victim.bufMgr:removeBufByTag("W_ZhouY_YinRan")
                victim.bufMgr:addBufById(self.fenJinBuff, self.player,self.skill)
            elseif not hasFenJin then
                for i, v in ipairs(yinRanBuffs) do
                    if v~= nil and v.bufWork then
                        v:reset(false)
                    end
                end
                victim.bufMgr:addBufById(self.yinRanBuff, self.player ,self.skill)
            end
        end
    end
end




function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    EventDispatcher:unRegisterEvent("add_W_ZhouY_YinRan", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_ZhouY_YinRan", {self,self.removeBuffHandler})
    M.super.destroy(self)
end

return M