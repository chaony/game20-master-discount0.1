--战斗中，若战场上存在除展昭以外的友方侠客，则展昭会获得40%的伤害减免
--lv2 若“护卫”目标存活，则展昭还会额外获得10%的伤害减免
--lv3战斗中，若战场上存在除展昭以外的友方侠客，则展昭会获得50%的伤害减免
--lv4 若场上只剩余展昭1人，则展昭会获得90%的伤害减免和100%的攻速和攻击力加成，持续5秒
---@class W_ZhanZ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ZhanZ_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId1 = self:getParam(1)  --伤害减免
    self.buffId2 = self:getParam(2)  --伤害减免
    self.buffId3 = self:getParam(3)  --90%的伤害减免和100%的攻速和攻击力加成
    self.targetPly = nil --护卫的目标
    EventDispatcher:registerEvent("killPlayer", {self,self.killPlayerHandler})
    EventDispatcher:registerEvent("add_W_ZhanZ_skill1", {self,self.addBuffHandler})
end

function M:spawn()
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        self.skill1 = skill1.cur_skill_config.feature
    end
    local friends = SelectTargetUtil:findFriendsExceptSelf(self.player)
    if friends.Count > 0 then
        self.player.bufMgr:addBufById(self.buffId1, self.player, self.skill)
    end
    if self.buffId3 > 0 and friends.Count == 0 then
        self.player.bufMgr:addBufById(self.buffId3, self.player, self.skill)
    end
end

---@param eventData Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, eventData)
    if eventData.buff and self.player:equal(eventData.buff.source) then
        self.targetPly = eventData.buff.player
        if self.buffId2 > 0 then
            self.player.bufMgr:addBufById(self.buffId2, self.player, self.skill)
        end
    end
end

function M:killPlayerHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    local personCount = 0
    if victim ~= nil and ( victim.camp == self.player.camp) then
        if self.targetPly and victim:equal(self.targetPly) then
            self.player.bufMgr:removeBufById(self.buffId2)
            if self.skill1 and self.skill1.skill.level >= 4 then
                self.player.bufMgr:removeBufById(self.skill1.buffId2)
            end
        end
        if victim:equal(self.player) and self.targetPly and self.targetPly:isLive() then
            self.targetPly.bufMgr:removeBufById(self.skill1.buffId1)
        end
        local friends = SelectTargetUtil:findFriendsExceptSelf(self.player)
        personCount = friends.Count
        if personCount == 0 then
            self.player.bufMgr:removeBufById(self.buffId1)
            if self.buffId3 > 0 then
                self.player.bufMgr:addBufById(self.buffId3, self.player, self.skill)
            end
        end
    end
end


function M:getTarget(target,count)
    local targets = Battle.List.new()
    local player = self.player.plyMgr:getPlayers(self.player.camp):get(0)
    if player == nil and self.player:isLive() then
        player = self.player
    end
    if player ~= nil then
        local data =
        {
            ["count"] = "all",
            ["camp"] = "all",
            ["posIndex"] = "all",
            ["priority"] = false,
            ["ignoreSummon"] = false,
            ["targetNoRepeat"] = false,
            ["campRace"] = "not",
            ["gender"] = "all",
            ["pos"] = "not",
            ["profession"] = "all",
            ["area"] = "all",
            ["areaWidth"] = 0,
            ["areaHeight"] = 0,
            ["areaAngle"] = 0,
            ["areaRadius"] = 0,
            ["forceSelect"] = false,
            ["selectLast"] = false,
            ["isFixPoint"] = false,
            ["useSelf"] = false,
            ["fixpoint"] = "enemyBackCenter"
        }
        if count ~= nil then
            data["posIndex"] = count
        end
        --无敌人
        if target == "not" then
            targets = Battle.List.new()
        elseif target == "self" then
            --我方全体
            data["camp"] = "friend"
            targets = SelectTargetTool:findPlayerByType(data, player)
        elseif target == "enemy" then
            --敌方全体
            data["camp"] = "enemy"
            targets = SelectTargetTool:findPlayerByType(data, player)
        else
            --id为target的人
            data["camp"] = "friend"
            targets = Battle.List.new()
            local temp = SelectTargetTool:findPlayerByType(data, player)
            for i = 1, temp.Count do
                if temp:get(i - 1):equal(player) == false then
                    targets:add(temp:get(i - 1))
                end
            end
        end
    end
    return targets
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_ZhanZ_skill1", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("killPlayer", {self,self.killPlayerHandler})
    M.super.destroy(self)
end

return M