-- 戰鬥中，當海殤君死亡時，會在10秒之後復活，並恢復60%最大生命值的血量，之後每次復活，恢復的血量都會減少減半，（最少恢復1%最大生命值的血量），死亡時或復活期間，我方隊友全部陣亡，則海殤君將無法復活（霹雳效果：每多上阵一个霹雳联动角色，复活时恢复的血量就提升10%）
-- 每次復活時，海殤君會免疫所有控制效果和傷害1秒

---@class W_HaiSJ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HaiSJ_skill0_1_Model", SkillFeatures_Model)

---@class 海殤君
local EHaiSJStatus = {
    Alive = 0,
    WillNirvana = 1,
    Nirvana = 2,
}

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.reenterTime = self:getParam(1)  -- Fix[0-100] 重新进入战场时间
    self.hpBaseRate = self:getParam(2) -- 复活基础血量
    self.hpUpRate = self:getParam(3) -- 联动血量提升效果
    self.buffId = self:getParam(4)  -- Buff 复活后免疫buff
    self.buffId2 = self:getParam(5)  -- Buff 死亡时特效buff
    self.reliveCount = 0 -- 复活次数
    self.curLeaveTime = 0
    self.isLeaveField = false   -- 离开战场
    self.selfStatus = EHaiSJStatus.Alive
    self.curHpRate = self.hpBaseRate -- 实际复活是恢复血量
    EventDispatcher:registerEvent("relive", {self,self.reliveHandler})
    EventDispatcher:registerEvent("leave_battlefield", {self,self.leaveHandler})
end


function M:spawn()
    M.super.spawn(self)
    local hpRate = self.hpBaseRate + GlobalTools:Mul(self:checkSeriesHeroCount(), self.hpUpRate)
    self.curHpRate = math.min(GlobalTools.base1, hpRate)
    self.selfStatus = EHaiSJStatus.Alive
    ---@type PlayerSkillItem
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil and skill1.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill1 = skill1.cur_skill_config.feature
    end
    
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
    return GlobalTools:ToFix(count)
end

function M:dead(data)
    if self:haveLiveFriend() then
        if self.selfStatus == EHaiSJStatus.Alive or self.selfStatus == EHaiSJStatus.Nirvana then -- 可以一直复活
            self:willNirvana(data)
        end
    else
        self.player.canRelive = false
        self.player:realDead()
    end
    return M.super:dead(self,data)
end

function M:update(dt, unsdt)
    if self.selfStatus == EHaiSJStatus.WillNirvana then
        self.curLeaveTime = self.curLeaveTime + dt
        if self.isLeaveField then
            if self.curLeaveTime >= self.reenterTime and self:haveLiveFriend() then -- 计时结束或没有队友
                self:intoNirvana()
            end
            if not self:haveLiveFriend() then
                self.player.canRelive = false
                self.player:realDead()
            end
        end
    end
end

-- 进入涅槃
function M:intoNirvana()
    self.player.canRelive = true
    self.selfStatus = EHaiSJStatus.Nirvana
    self.player.data:set_curHp(GlobalTools:Mul(self.player.data:get_hp(), self.curHpRate))   -- 复活生命恢复
    self.player.aiEngine:changeState("relive")
end

-- 进入涅槃状态
function M:willNirvana(data)
    self.selfStatus = EHaiSJStatus.WillNirvana
    self.curLeaveTime = 0
    local rate = GlobalTools.base1
    for i = 1, self.reliveCount do
        rate = GlobalTools:Mul(rate, GlobalTools.base0_5) -- 每复活一次血量减伤一半
    end
    self.curHpRate = math.max(GlobalTools:Mul(self.curHpRate,rate), GlobalTools.base0_0_1) -- 每复活一次复活血量减半, 最少1%
    self.reliveCount = self.reliveCount + 1
    self.player.canRelive = true
    self.player.bufMgr:addBufById(self.buffId2, self.player) 
    --self.player.disappearTime = GlobalTools.base1
    -- 设置死亡动画
    local dieState = self.player.aiEngine:getStateByName("die_into")
    --dieState.extra_anim_name = "hit2_spin"
    dieState.disappearTime = GlobalTools.base1
    -- 设置复活动画
    local dieState = self.player.aiEngine:getStateByName("relive")
    dieState.extra_anim_name = "jumpin2"
    dieState.reliveTime = GlobalTools.base1
    --self.player.data:set_curHp(GlobalTools.base1)
    --self.player.aiEngine:changeState("die_into")
end

---@return boolean 是否处于涅槃状态
function M:isInNirvana()
    return self.selfStatus == EHaiSJStatus.Nirvana
end

---@param data Battle_HandleData_Relive
function M:reliveHandler(eventName, data)
    if self.player:equal(data.player) then
        self.isLeaveField = false
        self:onRelive()
        self.player:removeDelayTimeBufEffect()
    end
end

-- 复活后

function M:onRelive()
    self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
    if self.skill1 and self.skill1.buffId ~= 0 then
        self.player.bufMgr:addBufById(self.skill1.buffId, self.player) -- 復活後5秒內，技能2的冷卻時間減少50%
        self.selfStatus = EHaiSJStatus.Alive
    end
end

---@param data Battle_HandleData_LeaveField
function M:leaveHandler(eventName, data)
    if self.player:equal(data.player) then
        self.isLeaveField = true
    end
end

---获取存活队友数量
function M:haveLiveFriend()
    ---@type Battle_List
    local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    local hide_players = SceneManager.curScene.plyMgr:getHidePlayers()
    if friends.Count > 0 then
        for i = 0, friends.Count-1 do
            ---@type PlayerModel
            local player = friends:get(i)
            if not self.player:equal(player) and player.followTarget == nil and player.master == nil then
                if player:isLive() then
                    return true
                end
            end
        end
    end
    for i = 1, hide_players.list.Count do
        local plyInstanceId = hide_players.list:get(i-1)
        local hide_player = self.player.plyMgr:getPlayerByInstanceId(plyInstanceId)
        if hide_player and not self.player:equal(hide_player) and hide_player.followTarget == nil and self.player.camp == hide_player.camp then
            if hide_player:isLive() then
                return true
            end
        end
    end
    return false
end

function M:destroy()
    EventDispatcher:unRegisterEvent("relive", {self,self.reliveHandler})
    EventDispatcher:registerEvent("leave_battlefield", {self,self.leaveHandler})
    M.super.destroy(self)
end

return M