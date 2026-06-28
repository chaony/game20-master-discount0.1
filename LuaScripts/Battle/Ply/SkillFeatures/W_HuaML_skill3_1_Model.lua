-- 花木兰挥舞马槊在自身周围布下xx战阵（这里文案起个名字），战阵会跟随花木兰移动，
--花木兰受到来自战阵以外的内功伤害会减免100%，受到的来自战阵以内的所有伤害会减少50%；
--释放该技能时不会消耗内力，而是会在战阵持续期间，每秒消耗200点内力，当内力消耗完时，技能效果结束；战阵持续期间，花木兰无法通过自身以外的手段恢复内力
--lv3来自战阵以外的外功伤害也会减少50%
---@class W_HuaML_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HuaML_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.resPer = self:getParam(1)--内伤减免百分比
    self.allPer = self:getParam(2)--所有伤害减免百分比
    self.costAnger = self:getParam(3)
    self.noAngerBuff = self:getParam(4)
    self.skillRange = self:getParam(5)
    self.atkBuff = self:getParam(6)
    self.atdPer = self:getParam(7)--外伤减伤百分比 
    self.player.skill3ClearAnger = false
    self.start = false
    self.timer = 0;
    --self.canUseSkill = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:canUse()
    return self.canUseSkill
end

function M:update(dt)
    if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill and self.player:isLive() == false then
        self:clearSkill3Status()
        return
    end
    if self.alreadyAdd then
        if self.player.data:get_curAnger() > GlobalTools.base0 then
            self.timer = self.timer - dt
            if self.timer <= GlobalTools.base0 then
                local ang_value = GlobalTools:Mul( self.costAnger, -GlobalTools.base1 )
                self.player.data:addAnger( ang_value )
                self.timer = GlobalTools.base1
            end
        elseif self.player.data:get_curAnger() <= GlobalTools.base0 then
            self:clearSkill3Status()
        end
    end
end

function M:injureHandler(eventName, eventData)
    local killer = eventData.killer
    local victim = eventData.victim
    local attackData = eventData.attackData
    if self.alreadyAdd and self.player:equal(victim) then
        if self.player.bufMgr:hasBufByTag("W_HuaML_skill0") then
            --计算我的和敌人之间的方向
            local inSkillRange = false
            local dis = GlobalTools:Distance(self.player:get_position(), killer:get_position())
            if dis <= GlobalTools:Mul(self.skill.skill_dis, self.skill.skill_dis) then
                inSkillRange = true
            end
            --伤害类型
            --1 nei伤
            --2 wai伤
            if attackData.damageType == 1 and inSkillRange == false then
                eventData.wantdata.damage = GlobalTools:Mul(GlobalTools.base1 - self.resPer, eventData.wantdata.damage)
            elseif self.atdPer > 0 and attackData.damageType == 2 and inSkillRange == false then
                eventData.wantdata.damage = GlobalTools:Mul(GlobalTools.base1 - self.atdPer, eventData.wantdata.damage)
            elseif inSkillRange == true then
                eventData.wantdata.damage = GlobalTools:Mul(GlobalTools.base1 - self.allPer, eventData.wantdata.damage)
            end
        end
    end
end

function M:clearSkill3Status()
    self.start = false
    self.canUseSkill = true
    self.alreadyAdd = false
    self.player.bufMgr:removeBufById(self.noAngerBuff)
    self.player.bufMgr:removeBufById(self.atkBuff)
    self.player.bufMgr:removeBufByTag("W_HuaML_skill3")
end

--技能释放
function M:skillStart(data)
    TimeTools:delayTime( GlobalTools.base0_0_5,
            function()
                if self.canUseSkill == false then
                    self.player.bufMgr:addBufById(self.noAngerBuff,self.player)
                    self.player.bufMgr:addBufById(self.atkBuff,self.player)
                    self.alreadyAdd = true
                end
            end)
    self.canUseSkill = false
end

--技能结束
function M:skillEnd(data)
    if data == nil or type(data) ~= "table" or data.normalEnd == true or self.alreadyAdd == true then
        self.timer = GlobalTools.base1
        self.start = true
    else
        self.timer = GlobalTools.base0
        self.start = false
        self.canUseSkill = true
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M