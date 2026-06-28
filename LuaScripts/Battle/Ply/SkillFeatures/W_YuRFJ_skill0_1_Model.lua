--戰鬥開始時，羽人非獍會獲得2層“六翼”效果每層六翼效果會使自身的暴擊率和暴擊效果提升10%，之後戰鬥每過去10秒，便會增加一層“六翼”效果，“六翼”效果會一直持續到戰鬥結束，
--最多可疊加6層（霹雳效果：每多上阵一个霹雳联动角色，戰鬥開始會便會額外獲得一層“六翼”效果）
---@class W_YuRFJ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_YuRFJ_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffCount = self:getParam(1) -- 战斗开始获得层数
    self.buffData = self:getParam(2) -- buffid
    self.intervalTime = self:getParam(3) -- 间隔时间
    self.timer = TimeTools:startOneLoopTask(self.intervalTime, handler(self, self.onResetTrigger))
    self.flyCount = 0 -- 翅膀个数
end

local EffectList = {
    "Fx_YuRFJ_Skill0_001","Fx_YuRFJ_Skill0_002","Fx_YuRFJ_Skill0_003","Fx_YuRFJ_Skill0_004","Fx_YuRFJ_Skill0_005",
    "Fx_YuRFJ_Skill0_006","Fx_YuRFJ_Skill0_Sf04","Fx_YuRFJ_Skill0_Sf05"
}

function M:spawnFinish()
    M.super.spawnFinish(self)
    local count = self:checkSeriesHeroCount() + self.buffCount
    for i = 1, count do
        self.player.bufMgr:addBufById(self.buffData, self.player)
    end
    self.flyCount = count
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_YuRFJ_skill0_1_Model_CreateFootEffect,EffectList)
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_YuRFJ_skill0_1_Model_ShowEffect,{showFlag = true, index = count})
end

function M:update(time)
    if self.timer then
        self.timer:update_dt(time)
    end
end

-- 戰鬥每過去10秒，便會增加一層“六翼”效果
function M:onResetTrigger()
    self.player.bufMgr:addBufById(self.buffData, self.player)
    self.flyCount = self.flyCount + 1
    self:dispatchEvent_Local(Battle.SkillEventType.MV_W_YuRFJ_skill0_1_Model_ShowEffect,{showFlag = true, index = self.flyCount})
end

--- 我方系列英雄个数
function M:checkSeriesHeroCount()
    local count = 0 -- 联动角色个数
    local heroes = self.player.plyMgr:getPlayers(self.player.camp)
    for i = heroes.Count, 1, -1 do
        local hero = heroes:get(i-1)
        if hero.plyData.id ~= self.player.plyData.id and
                table.indexof(Battle.EnumData.BATTLE_PLBDX_HERO_ID, tonumber(hero.plyData.id))  then
            count = count + 1
        end
    end
    return count
end

function M:destroy()
    self.timer = nil
    M.super.destroy(self)
end

return M