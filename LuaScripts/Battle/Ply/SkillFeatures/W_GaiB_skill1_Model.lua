--丐帮锁定自身攻击范围内最虚弱的敌人，将其甩到自己背后，造成200%攻击力
--的外功伤害，并使其攻击力减少30%，持续5秒。
--若该敌人落地的位置上有其他敌方角色，则会使命中的所有敌方角色眩晕2秒。
--该技能每释放1次，便为自身附加一层“酒意”效果，最多叠加10层
---@class W_GaiB_skill1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GaiB_skill1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.repeatRate = self:getParam(1)
    --减伤提速
    self.buffId1 = self:getParam(2)
    self.dis = self:getParam(3)
    EventDispatcher:registerEvent("dodge", {self,self.dodgeHandler})
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    self.isExtra = false
    self.dodgeSuccess = false
end

function M:spawn()
    M.super.spawn(self)
end


--技能释放(仅当前技能调用)
function M:skillStart(data)
    M.super.skillStart(self, data)
    local repeatFix = GlobalTools:Mul(self.repeatRate, GlobalTools.base100)
    if WRandom:randomNum(0,100) <= repeatFix then
        self.isExtra = true
        self.skill.extra_anim_name = "skill1_1"
    end
    self.dodgeSuccess = false
end

function M:dodgeHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    if killer ~= nil and killer:equal(self.player) then
        if self.player:get_curSkillConfig() == self.skill then
            self.dodgeSuccess = true
        end
    end
end

function M:killerBeforeAttack(attackData, victim)
    M.super.killerBeforeAttack(self, attackData, victim)
    if attackData.skillConfig == self.skill and self.dodgeSuccess == true then
        attackData.mustDodge = true
    end
end

function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if victim ~= nil then
       if skillConfig ~= nil and skillConfig.anim_name == "skill1" then
            if ply:equal(self.player) then
                --GlobalTools:Div( self.player.animator:get_animSpeed(), self.timeRate);
                local time = GlobalTools:Div(GlobalTools.base1_5,self.player.animator:get_animSpeed() );
                TimeTools:delayTime(time, function()
                    local enemys = victim.plyMgr:getPlayers(victim:get_camp())
                    for i = enemys.Count, 1, -1 do
                        local enemy_player = enemys:get(i-1)
                        local distance = GlobalTools:Distance(victim.position, enemy_player.position)
                        if victim:equal(enemy_player) == false and distance <= GlobalTools:ToFix2(self.dis)  then
                            local buff = enemy_player.bufMgr:findBufById(self.buffId1)
                            if table.nums(buff) <= 0 then
                                enemy_player.bufMgr:addBufById(self.buffId1, self.player)
                            end
                            local buff1 = victim.bufMgr:findBufById(self.buffId1)
                            if table.nums(buff1) <= 0 then
                                victim.bufMgr:addBufById(self.buffId1, self.player)
                            end
                        end
                    end
                end)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("dodge", {self,self.dodgeHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M