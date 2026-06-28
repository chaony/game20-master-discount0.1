---@class G_FuW_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("G_FuW_skill2_1_Model", SkillFeatures_Model)
local table_data = require("Battle.Ply.SkillFeaturesData.G_FuW_skill2_1_Data")
M.friendData = table_data.friendData
M.friendData2 = table_data.friendData2

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.bufId = self:getParam(1)
    self.bufId2 = self:getParam(2)
    self.radius = self:getParam(3)

    self.friendData["count"]["areaRadius"] = self.radius
    self.friendData2["count"]["areaRadius"] = self.radius
    self.summonList = Battle.ListMap.new()
end

function M:spawn()
    M.super.spawn(self)
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil then
        self.skill1 = skill1.cur_skill_config.feature
    end
    EventDispatcher:registerEvent("PlayerDead", {self,self.PlayerDeadHandler})
    EventDispatcher:registerEvent("spawn", {self,self.SpawnHandler})
end

--技能释放
function M:skillStart()
    if self.skill1 ~= nil and self.player.medCount > 0 then
        self.skill1:setMed(self.player.medCount - 1)
        self.skill.extra_anim_name = "skill2_1"
    else
        self.skill.extra_anim_name = "skill2_2"
    end
end

function M:SpawnHandler( eventName, data )
    local player = data["player"]
    --对自己生效
    if player ~= nil and self.player:equal(player.master) and player.summonData["id"] == GlobalTools.base2 then
        --self.summonList[player] = GlobalTools.base1;
        self.summonList:add(player, GlobalTools.base1)
    end
end

function M:update(dt)
    for i = 1, self.summonList.list.Count do
        local key = self.summonList.list:get(i-1)
        if key ~= nil and key:isLive() then
            local value = self.summonList:get(key)
            value = value - dt;
            if value <= 0 then
                value =  GlobalTools.base1;
                self.summonList:set(key, value)
                local enemys = SelectTargetTool:findPlayerByType(self.friendData2["count"], key)
                for i = 1,enemys.Count do
                    local ply = enemys:get(i-1)
                    if ply:equal(key) == false then
                        ply.bufMgr:addBufById(self.bufId2, self.player)
                    end
                end
            end
        end
    end
end


--死亡回调
function M:PlayerDeadHandler( eventName, data )
    local player = data["data"]
    if player ~= nil and player:equal(self.player) == false then
        if player.master ~= nil and player.master:equal(self.player) and player.summonData["id"] == GlobalTools.base2 then
            local enemys = SelectTargetTool:findPlayerByType(self.friendData["count"],player)
            for i = 1,enemys.Count do
                local ply = enemys:get(i-1)
                ply.bufMgr:addBufById(self.bufId, self.player)
               
            end
            self.summonList:remove(player)
        end
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.PlayerDeadHandler})
    EventDispatcher:unRegisterEvent("spawn", {self,self.SpawnHandler})
end
return M