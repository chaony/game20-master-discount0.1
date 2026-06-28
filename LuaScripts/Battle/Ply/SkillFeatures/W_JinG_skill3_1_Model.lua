--金刚进入蓄力状态8秒，蓄力期间，金刚受到的所有伤害减少50%且免疫控制效果。蓄力期间每受到1次攻击，会累积1点怒气，
--蓄力结束后，金刚会向前横挥，对范围内的敌人造成300%攻击力的外功伤害，自身每存在一点怒气，该技能造成的伤害就提升1%，
--金刚最多储存100点怒气。
---@class W_JinG_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JinG_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.maxTime = self:getParam(1) --蓄力状态持续时间
    self.buffId = self:getParam(2) --伤害减少50% buf
    self.buffId2 = self:getParam(3) --免疫控制buf
    self.buffId3 = self:getParam(4) --免疫伤害控制buf
    self.dmgRate = self:getParam(5) --反弹伤害值
    self.skill_Start = false
    self.curTime = self.maxTime
    self.skill3Start = false
    self.buff1 = {}
end


function M:spawn( ... )
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil then
        self.skill0 = skill0.cur_skill_config.feature
    end
end


function M:update(dt,unsdt)
    if self.skill_Start then --蓄力状态开始
        self.curTime = self.curTime - dt
        if self.curTime <= 0 then
            for k,v in ipairs(self.buff1) do
                if v ~= nil then
                    self.player.bufMgr:removeBuf(v)
                end
            end
            self.buff1 = {}
            self.player.animator:changeState("skill3_end")
            self.skill_Start = false --结束
        end
    end
end


--技能释放
function M:skillStart()
    self.totalDamage = 0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

--攻击开始处理
function M:killerAfterAttack(attackHandleData)
    M.super.killerAfterAttack(self, attackHandleData)
    local skill = attackHandleData.attackData.skillConfig
    local damage = attackHandleData.damage
    if skill ~= nil and skill == self.skill then
        attackHandleData.damage = damage + GlobalTools:Mul( self.totalDamage, self.dmgRate)
    end
end

--技能结束
function M:skillEnd(data)
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

function M:skillDispatch(data)
    if data.eventName == "changeSkill3" then
        self:changeHandle(data)
    end
end

function M:changeHandle(data)
    local frame = data.frame
    if frame.player:equal(self.player) then
        self.skill_Start = true
        self.curTime = self.maxTime

        local buff = self.player.bufMgr:addBufById(self.buffId, self.player)
        table.insert(self.buff1, buff)
        buff = self.player.bufMgr:addBufById(self.buffId2, self.player)
        table.insert(self.buff1, buff)
        buff = self.player.bufMgr:addBufById(self.buffId3, self.player)
        table.insert(self.buff1, buff)
        if self.player ~= nil and self.player.trait ~= nil then
            if self.skill3Start == false then
                buff = self.player.bufMgr:addBufById(self.player.trait.buffId, self.player)
                table.insert(self.buff1, buff)
                self.player.trait.count = self.player.trait.count -1
                if self.player.trait.count <= 0 then
                    self.skill3Start = true
                end
            end
        end
    end
end

function M:injureHandler(eventName, data)
    local victim = data["victim"]
    local damage =  data["wantdata"]["damage"] or 0
    if victim ~= nil and victim:equal(self.player) then
        if self.skill_Start then --在持续时间内
            self.totalDamage = self.totalDamage + damage
        end
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end


return M