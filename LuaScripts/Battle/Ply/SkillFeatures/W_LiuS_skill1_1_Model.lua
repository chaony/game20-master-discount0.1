--战斗开始时，六扇会随机为一名敌军施加“悬赏”标记，持续20秒，之后每过15秒，该技能会额外释放一次。
--悬赏优先标记后排
--当被施加了“悬赏”标记的目标死亡时，我方侠客会在5秒内快速回复100点内力
---@class W_LiuS_skill1_1_Model : SkillFeatures_Model
local M = class("W_LiuS_skill1_1_Model", SkillFeatures_Model)

M.targetSelect = require("Battle.Ply.SkillFeaturesData.W_LiuS_skill1_1_Data")

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.killBuf = self:getParam(1)
    --self.killBufDouble = self:getParam(2)
    self.buffContent = {}
    --击杀后不立即释放技能，完全死亡后重新检测
    self.killWait = nil
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("add_W_LiuS_skill1", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_LiuS_skill1", {self,self.removeBuffHandler})
    EventDispatcher:registerEvent("killPlayer", {self, self.killPlayerHandler})
end


function M:canUse()
    local enemy = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
    if enemy.Count > #self.buffContent and self.killWait == nil then
        return true
    end
    return false
end


function M:update(dt)
    if self.killWait ~= nil then
        if self.killWait:isDestroy() then
            self.killWait = nil
        end
    end
end


function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and buff.source ~= nil and self.player.camp == buff.source.camp then
        if table.indexof(self.buffContent, buff.player:get_playerInstanceId()) == false then
            table.insert(self.buffContent, buff.player:get_playerInstanceId())
        end
    end
end


function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and buff.source ~= nil and self.player.camp == buff.source.camp then
        table.removebyvalue(self.buffContent, buff.player:get_playerInstanceId(), true)
    end
end

---@param targets Battle_List
---@return PlayerModel 从列表中获取一个随机无悬赏buff目标
function M:getRandomOneNoBuffTarget(targets)
    if(targets.Count == 0)then
        return
    end
    local rightTargets = {}
    for i = 1, targets.Count do
        local target = targets:get(i - 1)
        if target ~= nil then
            local buffs = target.bufMgr:findBufByTag("W_LiuS_skill1")
            if #buffs == 0 then
                table.insert(rightTargets, target)
            end
        end
    end

    if(#rightTargets > 0)then
        return rightTargets[WRandom:randomNum(1, #rightTargets + 1, true)]
    end
end

--查找敌人
function M:findPlayer(data)
    if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then
        data:clear()
        -- 按照表查找目标
        SelectTargetTool:findPlayerByType(self.targetSelect, self.player)
        local target = self:getRandomOneNoBuffTarget(SelectTargetTool.priorityList) or self:getRandomOneNoBuffTarget(SelectTargetTool.notPriorityList)
        if(target ~= nil)then
            data:add(target)
        end
    end
    return data
end


function M:killPlayerHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    --击杀或者助攻
    if victim.camp ~= self.player.camp then
        local buffs = victim.bufMgr:findBufByTag("W_LiuS_skill1")
        if #buffs > 0 then
            self.killWait = victim
            local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
            for i = 1, friends.Count do
                local friend = friends:get(i - 1)
                --if self.killBufDouble > 0 and friend:equal(killer) then
                --    friend.bufMgr:addBufById(self.killBufDouble, self.player)
                --else
                    friend.bufMgr:addBufById(self.killBuf, self.player)
                --end
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("add_W_LiuS_skill1", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_LiuS_skill1", {self,self.removeBuffHandler})
    EventDispatcher:unRegisterEvent("killPlayer", {self, self.killPlayerHandler})
end


return M