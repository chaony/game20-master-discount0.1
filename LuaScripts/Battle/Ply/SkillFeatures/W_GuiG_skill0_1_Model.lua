--鬼谷被动
--战斗开始时，鬼谷会在我方半场布下阵法。处于阵法中的我方友军，攻击力会提升15%，敌方角色的攻击会减少15%.
---@class W_GuiG_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuiG_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffId = self:getParam(1)
    self.buffId2 = self:getParam(2)
    self.canUseSkill = true;
    self.areaIn = Battle.List.new()
    self.areaOut = Battle.List.new()
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self.center = SelectTargetTool:findFixPoint(self.player, "sceneCenter")
    --SelectTargetTool:findFixPoint(self.player, "sceneCenter")
    local friendList = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    local index = self.player.index
    for i = 1, friendList.Count do
        local friend = friendList:get(i - 1)
        if friend.plyType == self.player.plyType and index > friend.index then
            index = friend.index
        end
    end
    self.canUseSkill = (index == self.player.index)
    for i = 1, friendList.Count do
        self.areaOut:add(friendList:get(i - 1))
    end

    local enemy = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
    for i = 1, enemy.Count do
        self.areaOut:add(enemy:get(i - 1))
    end
end

function M:canUse()
    return self.canUseSkill
end

function M:update(dt,unsdt)
    for i = 1, self.areaOut.Count do
        local ply = self.areaOut:get(i - 1)
        if ply ~= nil  then
            if self.player.camp == 1 and ply.position.x < self.center.x then
                self:addBuff(ply)
            elseif self.player.camp == -1 and ply.position.x > self.center.x then
                self:addBuff(ply)
            end
        end
        
    end

    for i = 1, self.areaIn.Count do
        local ply = self.areaIn:get(i - 1)
        if ply ~= nil  then
            if self.player.camp == 1 and ply.position.x >= self.center.x then
                self:removeBuff(ply)
            elseif self.player.camp == -1 and ply.position.x <= self.center.x then
                self:removeBuff(ply)
            end
        end
        
    end
end

function M:addBuff(ply)
    self.areaIn:add(ply)
    self.areaOut:remove(ply)
    if self.player.camp == ply.camp then
        ply.bufMgr:addBufById(self.buffId, self.player)
    else
        ply.bufMgr:addBufById(self.buffId2, self.player)
    end
end

function M:removeBuff(ply)
    self.areaIn:remove(ply)
    self.areaOut:add(ply)
    if self.player.camp == ply.camp then
        ply.bufMgr:removeBufByTag("W_GuiG_skill0_friend")
    else
        ply.bufMgr:removeBufByTag("W_GuiG_skill0_enemy")
    end
end


function M:destroy()
    M.super.destroy(self)
end

   

return M