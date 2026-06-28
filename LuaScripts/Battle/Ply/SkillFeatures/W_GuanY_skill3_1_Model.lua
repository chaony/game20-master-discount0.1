--关羽释放武圣之力，恢复自身30%最大生命值的血量并使自身进入“武圣”状态，持续期间关羽会获得50%的伤害减免和50%的伤害提升，
--免疫所有控制效果且每秒会对自身周围的敌人造成200%攻击力的伤害，
--释放该技能不会消耗内力，但会在技能持续期间每秒消耗200点内力，且无法通过普攻和技能恢复内力,技能释放期间，关羽会在敌人之间持续移动
--技能结束时，关羽会对距离自己最近的一名敌人额外释放一次“青龙偃月”，

---@class W_GuanY_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuanY_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
   -- self.lastTime = self:getParam(1)
    self.cureBuffId = self:getParam(1) --回血buff
    self.atdBuffId = self:getParam(2) --伤害减少和攻击提升
    self.noControlBuffId = self:getParam(3) --免控buff
    self.rangeDamageBuffId = self:getParam(4) --周围伤害buff
    self.angre_value = self:getParam(5) --每秒减少125
    self.atkBuffId = self:getParam(6) --攻击和被击都无法恢复怒气
    self.suckBuffId = self:getParam(7) --吸血
    self.extraSuckBuffId = self:getParam(8) --额外吸血
    
    self.start = false
    self.timer = 0;
    self.player.skill3ClearAnger = false
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:registerEvent("ChangeAiState", {self,self.ChangeAiStateHandler})
    self.canUseSkill = true
end

function M:spawnFinish()
    self.skill1 = BattleTool:getSkillFeatureByName(self.player, "skill1")
end

--ai状态切换
---@param eventData Battle_HandleData_ChangeAiState
function M:ChangeAiStateHandler(eventName, eventData)
    if self.alreadyAdd and self.player:equal(eventData.player) == true and self.alreadyAdd then
        local targetState = eventData.targetState
        if targetState.key == "debuff" or targetState.anim_name == "debuff1" then
            self:clearSkill3Status()
        end
    end
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
                local ang_value = GlobalTools:Mul( self.angre_value, -GlobalTools.base1 )
                self.player.data:addAnger( ang_value )
                self.timer = GlobalTools.base1
            end
        elseif self.player.data:get_curAnger() <= GlobalTools.base0 then
            self:clearSkill3Status()
        end
    end
end

function M:clearSkill3Status(isBreak)
    self.start = false
    self.canUseSkill = true
    self.alreadyAdd = false
    self.player.bufMgr:removeBufById(self.atdBuffId)
    self.player.bufMgr:removeBufById(self.atkBuffId)
    self.player.bufMgr:removeBufById(self.noControlBuffId)
    self.player.bufMgr:removeBufById(self.rangeDamageBuffId)
    self.player.bufMgr:removeBufById(self.suckBuffId)
    if not isBreak then
        if self.skill1 then
            self.player:useSkill("skill1", true)
        else
            self.player.animator:changeState("attack1")
        end
    end
    self.player.moveMgr:clear()
end

--技能释放
function M:skillStart(data)
     TimeTools:delayTime( GlobalTools.base0_0_5,
        function()
            if self.canUseSkill == false then
                --self.player:setScale(GlobalTools:Mul(self.player.base_scale, GlobalTools.base1_2));
                --self.player.bufMgr:addBufById(self.material_buf,self.player)
                self.player.bufMgr:addBufById(self.cureBuffId,self.player)
                self.player.bufMgr:addBufById(self.atdBuffId,self.player)
                self.player.bufMgr:addBufById(self.noControlBuffId,self.player)
                self.player.bufMgr:addBufById(self.rangeDamageBuffId,self.player)
                self.player.bufMgr:addBufById(self.atkBuffId,self.player)
                self.player.bufMgr:addBufById(self.suckBuffId,self.player)
                self.alreadyAdd =  true
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


--增加时长
function M:addTimer(time)
    if self.timer > 0 then
        self.timer = self.timer + time
    end
end


--技能释放
function M:SkillEnterHandler( eventName, data )
    --if self.start then
    --    local ply = data["player"]
    --    local config = data["skillConfig"]
    --    if self.player:equal(ply) and config ~= nil and (config.anim_name == "attack1" or config.anim_name == "skill1") then
    --        config.extra_anim_name = config.anim_name .. "_skill3"
    --    end
    --end
end

function M:skillDispatch(data)
    --if data.eventName == "TianC_SkyStar_Hit" then
    --    if self.player.skyStar then
    --        self.player.skyStar:triggerStart(self)
    --    end
    --end    
end

function M:destroy()
	M.super.destroy(self)
    EventDispatcher:unRegisterEvent("ChangeAiState", {self,self.ChangeAiStateHandler})
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
end

return M