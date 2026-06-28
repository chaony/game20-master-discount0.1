-- 宋江的普攻和技能在命中目标时，会为其添加一层“雷霆”标记，当标记叠加至3层时会被引爆，对当前目标造成150%攻击力的真实伤害并使其眩晕2秒；
-- 目标身上的标记被引爆后5秒内，将无法添加新的标记
---@class W_SongJ_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_SongJ_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffNum = self:getParam(1) -- 引爆层数
    self.buffData1 = self:getParam(2) -- 引爆敌人BUFF
    self.buffData2 = self:getParam(3) -- 特效buff1
    self.buffData3 = self:getParam(4) -- 特效buff2
    self.buffData4 = self:getParam(5) -- 特效buff3
    self.buffData5 = self:getParam(6) -- 自身回内
    self.fristBomb = false
    EventDispatcher:registerEvent("afterAddBuff", {self,self.afterAddBuffHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    local skill = self.player.plySkill:getSkillByName("skill0") -- 技能0可能未解锁
    if skill ~= nil then
        self.skill0 = skill.cur_skill_config.feature
    end
end

---@param data Battle_BeHitDirectData
function M:afterAddBuffHandler(eventName, data)
    local victim = data.victim
    if self.player:equal(data.killer) == true and victim ~= nil then -- 攻击者是自己
        local buffs = victim.bufMgr:findBufByTag("W_SongJ_skill2")
        local bufData = nil
        if #buffs == 1 then
            bufData = self.buffData2
        elseif #buffs == 2 then
            bufData = self.buffData3
        elseif #buffs == 3 then
            bufData = self.buffData4
        end
        victim.bufMgr:removeBufByTag("W_SongJ_skill2_effect") -- 移除雷霆特效buff
        victim.bufMgr:addBufById(bufData, self.player)
        if #buffs >= self.buffNum then
            victim.bufMgr:removeBufByTag("W_SongJ_skill2") -- 移除雷霆
            victim.bufMgr:addBufById(self.buffData1, self.player)
            if self.skill0 and not self.fristBomb then
                self.fristBomb = true
                self.player.bufMgr:addBufById(self.skill0.buffData1, self.player)
            elseif self.skill0 then
                self.player.bufMgr:addBufById(self.skill0.buffData2, self.player)
            end
            if self.buffData5 ~= 0 then
                self.player.bufMgr:addBufById(self.buffData5, self.player)
            end
        end
    end
end

--销毁
function M:destroy()
    EventDispatcher:unRegisterEvent("afterAddBuff", {self,self.afterAddBuffHandler})
    M.super.destroy(self)
end
return M