--战斗开始后2秒，天山会飞上天空，期间无法被选为攻击和技能目标。当天山击杀了一位敌方侠客后，会落会地面5秒，之后会重新飞回天上。
--当我方侠客仅剩天山一人时，天山会落会地面，并不再飞回天上。当天山处于天上时，普通攻击会变为召唤飞剑，对小范围内的敌人造成110%攻击力的伤害
---@class W_TianS_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianS_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.startTime = self:getParam(1) --开始时间
    self.landTime = self:getParam(2) --落地停留时间
    self.start = false
    self.startTimer = 0
    self.landTimer = 0
    self.flyState = false
    self.landIfKillOne = true       -- 击杀敌人后自己落地
    EventDispatcher:registerEvent("ChangeAiState", {self,self.ChangeAiStateHandler})
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.start = true
    local attack1 = self.player.plySkill:getSkillByName("attack1")
    if attack1 ~= nil then
        self.attack1 = attack1.cur_skill_config
    end
end
--更新
function M:update(dt,unsdt)
    M.super.update(self, dt,unsdt)
    if self.start == true then
        if self.startTimer <= self.startTime then
            self.startTimer = self.startTimer + dt
        else
            if self:canFly() then
                self:changeState(true)
            end
            self.start = false
        end
    end

    if self.landTimer > 0 then
        self.landTimer = self.landTimer - dt
        if self.landTimer <= 0 then
            self:changeState(true)
        end
    end
    
    if self.flyState == true then
        if not self:canFly() then
            self:changeState(false)
            self.landTimer = 0
        end
    end
end

---纯阳是否飞天，检查存活的队友
function M:canFly()
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
            if hide_player:isLive() and hide_player.playerId ~= 714 then
                return true
            end
        end
    end
    return false
end

function M:changeState(state)
    self.flyState = state
    --self:dispatchEvent_Local(Battle.SkillEventType.W_TianS_skill2_1_Model_ChangeState, {state = self.flyState})

    if state == true then
        self.player.aiEngine.skillConfig = self.skill
        self.player.aiEngine.skillConfig.extra_anim_name = "skill2_start"
        self.player.aiEngine:changeState("attack")
        SceneManager.curScene.plyMgr:addHide(self.player)
        self.attack1.skill_dis_temp = GlobalTools.base10
        self.player.data.atkRange = GlobalTools.base10
    else
        self.player.aiEngine.skillConfig = self.skill
        self.player.aiEngine.skillConfig.extra_anim_name = "skill2_end"
        self.player.aiEngine:changeState("attack")
        SceneManager.curScene.plyMgr:removeHide(self.player)
        self.attack1.skill_dis_temp = nil
        self.player.data.atkRange = self.attack1.skill_dis
    end
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    if self.flyState == true then
        local ply = data["player"]
        local config = data["skillConfig"]
        if self.player:equal(ply) and config ~= self.skill then
            config.extra_anim_name = "skill2_" .. config.anim_name
        end
    end
end

--ai状态切换
function M:ChangeAiStateHandler( eventName, data )
    local player = data.player
    local curState = data.curState
    local targetState = data.targetState

    if self.player:equal(player) == true and self.flyState == true then
        if targetState.anim_name == "idle" or targetState.anim_name == "battle_idle" or targetState.anim_name == "run"then
            targetState.extra_anim_name = "skill2_loop"
        end
    end
end

--杀死敌人
function M:killPlayer(data)
    if self.landIfKillOne then
        if self.flyState == true then
            self:changeState(false)
            self.landTimer = self.landTime
        else
            if self.landTimer > 0 then
                self.landTimer = self.landTime
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("ChangeAiState", {self,self.ChangeAiStateHandler})
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    M.super.destroy(self)
end

return M