--吕布释放战神之威环绕自身，立即恢复自身30%最大生命值的血量，并进入“天下无双”状态，天下无双状态持续期间，吕布会保留1点血量且不会死亡，
--并使自身增加50%攻击速度和攻击力，释放该技能不会消耗内力，但会在天下无双状态持续期间每秒消耗150点内力，当内力消耗完时，状态结束，
--且天下无双状态期间，吕布无法通过任何手段恢复内力

---@class W_LvB_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LvB_skill3_1_Model", SkillFeatures_Model)
--
--function M:init(ply, skill,className)
--    M.super.init(self, ply, skill,className)
--    self.buffId = self:getParam(1)  -- buffId
--    self.costAngerUnit = self:getParam(2)  -- 每秒扣的怒气
--    self.buffId2 = self:getParam(3)  -- buffId
--    self.start = false
--    self.canUseSkill = true
--    self.player.skill3ClearAnger = false
--    self.alreadyAdd = false
--    self.costAngerUnit2 = 0 --天命化星每秒扣的怒气
--    self.buffId3 = 0 --天命化星的buff
--    --EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
--end
--
--function M:spawn()
--    M.super.spawn(self)
--    self.skill1 = nil
--    ---@type PlayerSkillItem
--    local skill1 = self.player.plySkill:getSkillByName("skill1")
--    if skill1 ~= nil then
--        ---@type SkillDataConfig
--        self.skill1 = skill1.cur_skill_config.feature
--    end
--end

--function M:spawnFinish()
--    M.super.spawnFinish(self)
--    if self.player.skyStar ~= nil then
--        self.player.skyStar:triggerStart(self)
--    end
--end
--


--function M:canUse()
--    return self.canUseSkill
--end
--
--function M:update(dt)
--    if self.start then
--        if self.player.data:get_curAnger() > GlobalTools.base0 then
--            self.timer = self.timer - dt
--            if self.timer <= GlobalTools.base0 then
--                local ang_value = GlobalTools:Mul( self.costAngerUnit, -GlobalTools.base1 )
--                self.player.data:addAnger( ang_value )
--                self.player.bufMgr:addBufById(self.buffId3, self.player)
--                self.timer = GlobalTools.base1
--            end
--        elseif self.player.data:get_curAnger() <= GlobalTools.base0 then
--            self.player.bufMgr:removeBufById(self.buffId)
--            self.player.bufMgr:removeBufById(self.buffId2)
--            self.start = false
--            self.canUseSkill = true
--            if self.skill1 then
--                self.skill1.lost_hp_num = self.player.totalLostHp
--            end
--            self.alreadyAdd = false
--            self.player.data:setAngerLockAdd(false) --锁定怒气
--        end
--    end
--end
--
--技能释放
function M:skillStart(data)
    TimeTools:delayTime( GlobalTools.base0_1_5,
            function()
                if self.skill.level >= 4 then
                    self.player:useSkill("skill0", true)
                end
            end)
    if self.player.skyStar ~= nil then
        self.player.skyStar:triggerStart(self)
    end
end
--
--
----技能结束
--function M:skillEnd(data)
--    if data == nil or type(data) ~= "table" or data.normalEnd == true or self.alreadyAdd == true then
--        self.timer = GlobalTools.base1
--        self.start = true
--    else
--        self.timer = GlobalTools.base0
--        self.start = false
--        self.canUseSkill = true
--    end
--end
--
----增加时长
--function M:addTimer(time)
--    if self.timer > 0 then
--        self.timer = self.timer + time
--    end
--end
----死亡
--function M:dead(data)
--    M.super.dead(self)
--    if self.start == true then
--        local hp = GlobalTools:Mul(self.player.data:get_hp(), GlobalTools.base0_0_1)
--        self.player.data:set_curHp(hp)
--        return false
--    end
--    return true
--end
--
--function M:destroy()
--    M.super.destroy(self)
--end

return M