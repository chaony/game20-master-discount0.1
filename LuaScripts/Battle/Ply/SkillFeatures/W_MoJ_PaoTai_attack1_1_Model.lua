--战斗开始时，墨家会在自身所在位置建造一个机关塔，机关塔拥有墨家70%的血量和60%的攻击力，机关塔存在期间会持续攻击范围内的敌人，机关塔被破坏时，会在原地留下一个残骸
---@class W_MoJ1_attack1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_MoJ1_attack1_1_Model", SkillFeatures_Model)

M.isDead = false

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.isDead = false
end

--出生
function M:spawn()
    M.super.spawn(self)
    local skill0 = self.player.master.plySkill:getSkillByName("skill0")
    if skill0 ~= nil then
        self.skill0 = skill0.cur_skill_config.feature
    end
end

--角色死亡
function M:dead(data)
    if self.player.master ~= nil and self.player.master:isLive() == true then
        if self.isDead == false then
            self.isDead = true
            self.player.aiEngine:changeState("die")
            self.player.data:set_curHp(GlobalTools.base1)
            TimeTools:delayTime(GlobalTools.base0_1, function()
                self.player:ShowHpBar(false)
            end)
            self.player.plyMgr:removePlayerFromList(self.player)
            self.player.plyMgr.summon_list:add(self.player)
            local player = self.player.plyMgr:getPlayers(-self.player:get_camp())
            for i=player.Count,1,-1 do
                local player = player:get(i-1)
                if self.player:equal(player.enemy) == true then
                    player:lockEnemy(nil);
                end
            end
            if self.skill0 ~= nil then
                self.skill0:removeBuff()
            end
        end
        return false
    else
        return true
    end
end

--机关塔复活
function M:reSpawn(hpRate)
    if self.isDead == true then
        self.isDead = false
        self.player.data:set_curHp(GlobalTools:Mul(self.player.data:get_hp(), hpRate))
        self.player:ShowHpBar(true)
        
        self.player.plyMgr.summon_list:remove(self.player)
        if self.player.camp == 1 then
            self.player.plyMgr.hero_list:add(self.player)
        else
            self.player.plyMgr.enemy_list:add(self.player)
        end
        if self.skill0 ~= nil then
            self.skill0:addBuff()
        end
        self.player.aiEngine:changeState("reSpawn")
    end
end

--攻击结束处理
function M:afterAttack(data)
    if self.isDead == true then
        data.damage = 0
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M