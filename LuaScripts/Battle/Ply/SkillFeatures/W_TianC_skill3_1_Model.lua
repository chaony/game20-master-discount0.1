--天策进入“无双”状态8秒，持续期间，天策受到的伤害减少50%，攻击力提升50%，且普通攻击变为范围攻击。
--天下无双不会立即消耗所有怒气，但在无双状态下 天策的攻击和被击都无法恢复怒气，
--且怒气每秒会减少125点，怒气为0时，无双状态结束
---@class W_TianC_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianC_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
   -- self.lastTime = self:getParam(1)
    self.atdBuffId = self:getParam(1) --伤害减少和攻击提升
    self.atkBuffId = self:getParam(2) --攻击和被击都无法恢复怒气
    self.angre_value = self:getParam(3) --每秒减少125
    self.effect_buf = self:getParam(4) --无双buf特效
    self.material_buf = self:getParam(5) --添加材质buf特效
    self.start = false
    self.timer = 0;
    self.player.skill3ClearAnger = false
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    self.canUseSkill = true
end


function M:canUse()
    return self.canUseSkill
end


function M:update(dt)
    if self.start then
        if self.player.data:get_curAnger() > GlobalTools.base0 then
            self.timer = self.timer - dt
            if self.timer <= GlobalTools.base0 then
                local ang_value = GlobalTools:Mul( self.angre_value, -GlobalTools.base1 )
                self.player.data:addAnger( ang_value )
                self.timer = GlobalTools.base1
            end
        elseif self.player.data:get_curAnger() <= GlobalTools.base0 then
            self.player.bufMgr:removeBufById(self.atdBuffId)
            self.player.bufMgr:removeBufById(self.atkBuffId)
            self.player.bufMgr:removeBufById(self.effect_buf)
            self.player.bufMgr:removeBufById(self.material_buf)
            self.start = false
            self.player:setScale(self.player.base_scale);
            self.canUseSkill = true
            self.alreadyAdd = false
        end
    end
end


--技能释放
function M:skillStart(data)
     TimeTools:delayTime( GlobalTools.base0_0_5,
        function()
            if self.canUseSkill == false then
                self.player:setScale(GlobalTools:Mul(self.player.base_scale, GlobalTools.base1_2));
                self.player.bufMgr:addBufById(self.material_buf,self.player)
                self.player.bufMgr:addBufById(self.atdBuffId,self.player)
                self.player.bufMgr:addBufById(self.atkBuffId,self.player)
                self.player.bufMgr:addBufById(self.effect_buf,self.player)
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
    if self.start then
        local ply = data["player"]
        local config = data["skillConfig"]
        if self.player:equal(ply) and config ~= nil and (config.anim_name == "attack1" or config.anim_name == "skill1") then
            config.extra_anim_name = config.anim_name .. "_skill3"
        end
    end
end

function M:skillDispatch(data)
    if data.eventName == "TianC_SkyStar_Hit" then
        if self.player.skyStar then
            self.player.skyStar:triggerStart(self)
        end
    end    
end

function M:destroy()
	M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
end

return M