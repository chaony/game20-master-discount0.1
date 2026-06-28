--全体宠物单位回复猫自身攻击力100%的血量，并且之后的3S，每秒持续回血攻击力的30%的血量。若在斗气阶段胜出，技能效果强化为：回复150%血量，并且持续回血比例提升至45%
---@class P_Cat_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Cat_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffData1 = self:getParam(1) -- buff1
    self.buffData2 = self:getParam(2) -- buff2
    self.killFlag = false -- 是否击杀地方宠物
    self.battleWin = self.player.power_win == 1 -- 比斗气是否胜出
end


function M:spawn()
    M.super.spawn(self)
    self.skill0 = nil
    self.skill1 = nil
    self.skill2 = nil
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil and skill0.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill0 = skill0.cur_skill_config.feature
    end
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil and skill1.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill1 = skill1.cur_skill_config.feature
    end
    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil and skill2.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill2 = skill2.cur_skill_config.feature
    end
end

function M:skillStart(data)
    M.super.skillStart(self,data)
    local skill0State = false -- 进入skill1状态
    if self.skill0 and self.skill0.buffRate then
        if self:checkSkill0(self.skill0.buffRate) then
            skill0State = true 
        end
    end
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp()) -- 获取全体我方宠物
    for i = friends.Count, 1, -1 do
        local player = friends:get(i-1)
        local buffData = nil
        if self.skill2 then
            if self.battleWin then -- 比气势胜利
                buffData = skill0State == true and self.skill2.buffData5 or self.skill2.buffData4
            else
                buffData = skill0State == true and self.skill2.buffData3 or self.skill2.buffData2
            end
        else
            buffData = self.battleWin == true and self.buffData2 or self.buffData1
        end
        if player then
            player.bufMgr:addBufById( buffData, self.player );
            if skill0State then
                player.bufMgr:addBufById( self.skill0.buffData, self.player ); -- skill0 效果额外增加回血效果
            end
            if self.skill1 then
                local r = WRandom:randomNum(1, 4,true)
                local buffData2 = self.skill1["buffData"..r]
                if buffData2 then
                    player.bufMgr:addBufById(buffData2, self.player ); -- skill1 该局获得持续全局的（伤害加深，暴击， 3选一 看着给）随机增益效果1%
                end
            end
        end
    end
    
end

function M:checkSkill0(rate)
    if rate < GlobalTools.base100 then
        local r = WRandom:randomNum(0, 100)
        return r < rate
    end
    return true
end

function M:playerDeadHandler(eventName, data)
    local ply = data["data"]
    if ply ~= nil and ply:equal(self.player) == false then
        if ply.killer ~= nil and ply.killer:equal(self.player) and ply.playerType == "pet" then
            self.killFlag = true
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M