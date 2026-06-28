--战斗中，年兽身边近战范围内会环绕结界，处于结界外的侠客造成的伤害会减少50%，战斗每过去20秒，年兽周围的结界会消失5秒，之后会重新出现

---@class B_NianS_skill0_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("B_NianS_skill0_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.outRadius = self:getParam(1) -- 范围以外
    self.effectBuff = self:getParam(2) -- 加一个减少伤害的buff
    self.addBufTime = self:getParam(3) -- 重新加buf时间
    self.effectBuff2 = self:getParam(4) -- 给boss加的一个特效buff
    self.bufTime = self:getParam(5) -- buff实际持续时间
    self.heroList = {}
end

--角色出生结束
function M:spawnFinish()
    self.timer = GlobalTools.base0_5 -- 每0.5秒检测一次是否在范围内
    self.timerAddBuf = self.addBufTime -- 每25秒加一次buff
    self.duration = 0 -- buff持续时间
    self.player.bufMgr:addBufById(self.effectBuff2, self.player) -- 开局加个buff特效
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    if self.timer > 0 then
        self.timer = self.timer - dt
        self.duration = self.duration + dt
        if self.duration <= self.bufTime then -- 开局检测加buff，直到持续到buff生效的配置时间
            if self.timer <= 0 then
                self.timer = GlobalTools.base0_5
                self:checkArea()
            end
        end
    end
    if self.timerAddBuf > 0 then
        self.timerAddBuf = self.timerAddBuf - dt
        if self.timerAddBuf <= 0 then
            self.timerAddBuf = self.addBufTime
            self.duration = 0 -- 25秒后重置buff生效
            self.timer = GlobalTools.base0_5
            self.heroList = {}
            self.player.bufMgr:addBufById(self.effectBuff2, self.player)
        end
    end
end

function M:checkArea()
    local heroList = SceneManager.curScene.plyMgr:getPlayers(1) -- 获得所有玩家方英雄
    for i = 1, heroList.Count do
        local hero = heroList:get(i - 1)
        if hero:equal(self.player) == false and GlobalTools:Distance(hero.position, self.player.position) > GlobalTools:ToFix2(self.outRadius) then
            if self.heroList[hero.playerInstanceId] == nil then
                hero.bufMgr:addBufById(self.effectBuff, self.player)
            end
            self.heroList[hero.playerInstanceId] = self.effectBuff
        else
            if self.heroList[hero.playerInstanceId] ~= nil then
                self.heroList[hero.playerInstanceId] = nil
                hero.bufMgr:removeBufById(self.effectBuff)
            end
        end
    end
    
end

function M:destroy()
    M.super.destroy(self)
end

return M