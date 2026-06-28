--召唤飞雪到场上
---@class W_JiuL_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuL_attack1_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.attr = GlobalTools.base0_5
    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil then
        self.attr = skill2.cur_skill_config.feature.attr
    end
    if self.player.skyStar then
        self.player.skyStar:triggerStart(self)
    end
    self.player.evtMgr:commonEventWork("Sendfor", 1)
    self.player.evtMgr:commonEventWork("Sendfor", 2)
    self.isActive = false
    self.isChange = false
end

--召唤成功
---@param data Battle_HandleData_SendForFinish
function M:sendForHandler( eventName, data )
    local player = data["player"]
    if self.player:equal(player.master) == true then
        player.data:copyData(self.player, true, self.attr)
        player.data:set_curHp(player.data:get_hp())
        if player.playerId == 3101 then
            self.summoned_cat = player
            self.summoned_cat:ShowHpBar(false)
        elseif player.playerId == 3102 then
            self.summoned_tiger = player
            self.summoned_tiger:ShowHpBar(false)
            self.player.plyMgr:removePlayerFromList(self.summoned_tiger)
            self:showObj(self.summoned_tiger, false)
        end
    end
end

function M:hasBuf()
    --local buff = self.player.bufMgr:findBufByTag("W_JiuL_skill3")
    --return #buff > 0
    return true
end

--激活飞雪
function M:active()
    if self.isActive == false then
        self.isActive = true

        self.summoned_cat.data:set_curHp(self.summoned_cat.data:get_hp())
        if self:hasBuf() == false then
            self.summoned_cat:ShowHpBar(true)
            self.player.plyMgr.summon_list:remove(self.summoned_cat)
            if self.summoned_cat.camp == 1 then
                self.player.plyMgr.hero_list:add(self.summoned_cat)
            else
                self.player.plyMgr.enemy_list:add(self.summoned_cat)
            end
            self.summoned_tiger:lockEnemy(self.summoned_cat:get_enemy())
            local players = self.player.plyMgr:getPlayers(-self.summoned_cat:get_camp())
            for i=players.Count,1,-1 do
                local p = players:get(i-1)
                p:lockEnemy(nil);
            end
        end
    end
    
    self:changeToTiger()
end

--变成虎状态
function M:changeToTiger()
    if self.isActive == true then
        
        if self:hasBuf() == true then
            if self.isChange == false then
                self.isChange = true

                self.summoned_tiger.data:set_curHp(self.summoned_cat.data:get_curHp())
                if self.summoned_tiger.camp == 1 then
                    self.player.plyMgr.hero_list:add(self.summoned_tiger)
                else
                    self.player.plyMgr.enemy_list:add(self.summoned_tiger)
                end
                self.summoned_tiger:setPos(self.summoned_cat:get_position(), true)
                if self.summoned_tiger.aiEngine then
                    self.summoned_tiger.aiEngine:changeState("idle")
                end
                self:showObj(self.summoned_cat, false)
                self:showObj(self.summoned_tiger, true)
                self.summoned_cat.bufMgr:destroy()

                self.summoned_cat:ShowHpBar(false)
                self.summoned_tiger:ShowHpBar(true)
                --self:dispatchEvent_Local(Battle.SkillEventType.W_JiuL_attack1_1_Model_ChangeState, {player = self.summoned_cat})
            end
        end
    end
end

--关闭飞雪
function M:deactive()
    if self.isActive == true then
        self:changeToCat()

        self.player.plyMgr:removePlayerFromList(self.summoned_cat)
        self.player.plyMgr.summon_list:add(self.summoned_cat)

        self.summoned_cat.summonData.follow = true
        self.summoned_cat:ShowHpBar(false)

        local players = self.player.plyMgr:getPlayers(-self.summoned_cat:get_camp())
        for i=players.Count,1,-1 do
            local p = players:get(i-1)
            if self.summoned_cat:equal(p.enemy) == true or self.summoned_tiger:equal(p.enemy) == true then
                p:lockEnemy(nil);
            end
        end
        self.isActive = false
    end
end

--变成猫状态
function M:changeToCat()
    if self.isActive == true then
        if self.isChange == true then
            self.isChange = false
            self.summoned_cat.data:set_curHp(self.summoned_tiger.data:get_curHp())

            self.player.plyMgr:removePlayerFromList(self.summoned_tiger)
            self.summoned_cat:setPos(self.summoned_tiger:get_position(), true)
            self.summoned_cat.aiEngine:changeState("idle")

            self:dispatchEvent_Local(Battle.SkillEventType.W_JiuL_attack1_1_Model_ChangeState, {player = self.summoned_tiger})

            self.summoned_tiger:ShowHpBar(false)
            self.summoned_cat:ShowHpBar(true)
            self:showObj(self.summoned_cat, true)
            self:showObj(self.summoned_tiger, false)
            self.summoned_tiger.bufMgr:destroy()

            local players = self.player.plyMgr:getPlayers(-self.summoned_cat:get_camp())
            for i=players.Count,1,-1 do
                local p = players:get(i-1)
                if self.summoned_cat:equal(p.enemy) == true or self.summoned_tiger:equal(p.enemy) == true then
                    p:lockEnemy(nil);
                end
            end
        end
        self.isChange = false
    end
end

function M:showObj(player, show)
    local data = {}
    data.player = player
    data.show = show
    self:dispatchEvent_Local(Battle.SkillEventType.W_JiuL_attack1_1_Model_ShowObj, data)
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SendForFinish", {self,self.sendForHandler})
    M.super.destroy(self)
end

return M