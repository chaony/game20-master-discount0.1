--战斗开始时，太极内家拳会在战场上布下阵图，阵图有“极阳”和“极阴”两种状态，战斗时间每过10秒会转换一次，
--当阵图处于“极阳”状态时，我方所有侠客都会获得一个“极阳之力”的效果，使自身受到的伤害减少20%，最大血量提升20%；
--当阵图处于“极阴”状态时，敌方所有侠客都会获得一个“极阴之力”的效果，使其受到的伤害增加20%，当太极内家拳死亡时，阵图便会消失
---@class W_TaiJNJQ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaiJNJQ_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.initStatus = self:getParam(1, 1) -- 1阳 2阴
    self.changeTime = self:getParam(2)--转换时间
    self.disapearTime = self:getParam(3)--死亡后残留的时间
    self.curStatus = self.initStatus
    self.curTime = self.changeTime
    self.isFirst = true
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.player:useSkill("skill1", true)
end

function M:skillStart(data)
    if self.isFirst then
        self.isFirst = false
    else
        self:changeSkillStatus()
    end
   
    if self.curStatus == 1 then
        self.skill.extra_anim_name = "skill1"
    else
        self.skill.extra_anim_name = "skill1_1"
    end
end

function M:skillEnd(data)
    --self.curTime = self.changeTime
    local enemies = self.player.plyMgr:getPlayers(-self.player:get_camp())
    enemies:safeWalkInverted(function(ply)
        if self.curStatus == 1 then
            ply.bufMgr:removeBufByTag("W_TaiJNJQ_yin_power")
        end
    end)
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    friends:safeWalkInverted(function(ply)
        if self.curStatus == 2 then
            ply.bufMgr:removeBufByTag("W_TaiJNJQ_yang_power")
        end
    end)
end

--function M:update(dt)
    --M.super.update(self, dt)
    --if self.startTimeDown then
    --    if self.curTime <= 0 then
    --        self:changeSkillStatus()
    --        self.curTime = self.changeTime
    --        local enemies = self.player.plyMgr:getPlayers(-self.player:get_camp())
    --        enemies:safeWalkInverted(function(ply)
    --            if self.curStatus == 1 then
    --                ply.bufMgr:removeBufByTag("W_TaiJNJQ_yin_power")
    --            end
    --        end)
    --        local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    --        friends:safeWalkInverted(function(ply)
    --            if self.curStatus == 2 then
    --                ply.bufMgr:removeBufByTag("W_TaiJNJQ_yang_power")
    --            end
    --        end)
    --    else
    --        self.curTime = self.curTime - dt
    --    end
    --end
--end

function M:changeSkillStatus()
    if self.curStatus == 1 then
        self.curStatus = 2
    else
        self.curStatus =1
    end
end

---@param data Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, data)
    if self.player:equal(data.victim) and self.player.master == nil then
        local disappearTime = self.disapearTime > 0 and self.disapearTime or GlobalTools.base0_1
        TimeTools:delayTime(disappearTime,function()
            local enemies = self.player.plyMgr:getPlayers(-self.player:get_camp())
            enemies:safeWalkInverted(function(ply)
                ply.bufMgr:removeBufByTag("W_TaiJNJQ_Skill1_2")
            end)
            local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
            friends:safeWalkInverted(function(ply)
                ply.bufMgr:removeBufByTag("W_TaiJNJQ_Skill1_1")
            end)
        end)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    M.super.destroy(self)
end

return M