--战斗开始时，若太极内家拳位于4号位置（后排中央）则会在战场上布下太阴阵图，且战斗过程中不会再切换，
--太阴阵图会为所有敌方侠客施加“太阴之力”使其受到的伤害增加30%；太阴阵图也会被视为极阴阵图，太阴之力也会被视为“极阴之力”；
--若太极内家拳位于4号以外的位置，则会在战场上布下太阳阵图，且战斗过程中不会再切换，
--太阳阵图会为我方侠客施加“太阳之力”，使其受到的伤害减少30%，最大血量提升30%；太阳阵图也会被视为“极阳阵图”，太阳之力也会被视为“极阳之力”
--当太极内家拳死亡时，阵图便会消失
---@class W_TaiJNJQ_skill1_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TaiJNJQ_skill1_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.yinPos = self:getParam(1, 0) -- 阴阵图的位置
    self.disapearTime = self:getParam(2)--死亡后残留的时间
    self.curTime = self.changeTime
    EventDispatcher:registerEvent("killPlayer", {self,self.killerPlayerHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    if self.player.index == (self.yinPos - 1) then --配置的站位12345对应的是01234
        self.curStatus = 2
    else
        self.curStatus = 1
    end
end

function M:skillStart(data)
    if self.player.index == (self.yinPos - 1) then
        self.skill.extra_anim_name = "skill1_plus_1"
    else
        self.skill.extra_anim_name = "skill1_plus"
    end
end

---@param data Battle_HandleData_KillPlayer
function M:killerPlayerHandler(eventName, data)
    if self.player:equal(data.victim) and self.player.master == nil then
        local disappearTime = self.disapearTime > 0 and self.disapearTime or GlobalTools.base0_1
        TimeTools:delayTime(disappearTime,function()
            local enemies = self.player.plyMgr:getPlayers(-self.player:get_camp())
            enemies:safeWalkInverted(function(ply)
                ply.bufMgr:removeBufByTag("W_TaiJNJQ_yin_power")
            end)
            local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
            friends:safeWalkInverted(function(ply)
                ply.bufMgr:removeBufByTag("W_TaiJNJQ_yang_power")
            end)
        end)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killerPlayerHandler})
    M.super.destroy(self)
end

return M