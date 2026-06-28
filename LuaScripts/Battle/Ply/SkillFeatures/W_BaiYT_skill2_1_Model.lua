--战斗中，白玉堂会一直处于“xx”状态，期间无法被选为攻击和技能目标，造成的伤害增加30%，
--且会缓慢恢复血量，当白玉堂击杀任意一名敌人后，会退出“xx”状态5秒，只有会重新回到“xx”状态，等我方侠客只剩白玉堂一人是，白玉堂会退出“xx”状态。
---@class W_BaiYT_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiYT_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1) --无法选中buff
    self.landTime = self:getParam(2) --落地停留时间
    self.landTimer = 0
    self.flyState = false
    self.landIfKillOne = true       -- 击杀敌人后自己落地
    self.startFlag = true 
    self.changeFlag = true -- 在切换状态时加buff
end


--更新
function M:update(dt,unsdt)
    M.super.update(self, dt,unsdt)
    if self.startFlag and self:canFly() then
        self.startFlag = false
        self:changeState(true)
        self.player.bufMgr:addBufById(self.buffId, self.player)
    end
    if self.landTimer > 0 then
        self.landTimer = self.landTimer - dt
        if self.landTimer <= 0 then
            self:changeState(true)
            if self.changeFlag then
                self.player.bufMgr:addBufById(self.buffId, self.player)
                self.changeFlag = false
            end
        end
    end

    if self.flyState == true then
        if not self:canFly() then
            self:changeState(false)
            self.landTimer = 0
            self.player.bufMgr:removeBufById(self.buffId, true)
        end
    end
end

---白玉堂是否飞天，检查存活的队友
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
            if hide_player:isLive() then
                return true
            end
        end
    end
    return false
end

function M:changeState(state)
    self.flyState = state
    if state == true then
        --self.player.aiEngine:changeState("attack")
        SceneManager.curScene.plyMgr:addHide(self.player)
    else
        --self.player.aiEngine:changeState("attack")
        SceneManager.curScene.plyMgr:removeHide(self.player)
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
        self.player.bufMgr:removeBufById(self.buffId, true) -- 白玉堂杀人后移除buff修改
        self.changeFlag = true
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M