-- 当护盾到达持续时间或因敌人的攻击而被破坏，则护盾会爆炸并对周围的敌人造成10%白驼最大生命值的伤害。
local W_BaiT_skill2_1_Model = require("Battle.Ply.SkillFeatures.W_BaiT_skill2_1_Model")
---@class W_BaiT_skill2_2 : W_BaiT_skill2_1_Model @
---@field super W_BaiT_skill2_1_Model @W_BaiT_skill2_1_Model
local M = class("W_BaiT_skill2_2", W_BaiT_skill2_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.radius =self:getParam(2)
    self.atk = self:getParam(3)
end

function M:spawn()
	 M.super.spawn(self)
end

function M:removeBuffHandler(eventName, data)
    M.super.removeBuffHandler(self, eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.player) then
        local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp())
        for i = enemys.Count, 1, -1 do
            local enemy_player = enemys:get(i-1)
            if enemy_player and enemy_player:isLive() then
                local distance = GlobalTools:Distance(self.player.position, enemy_player.position)
                if distance <= GlobalTools:ToFix2(self.radius)  then
                    local attackData = BattleTool:getBaseAttackData()
                    attackData["damage"] = GlobalTools:Mul( self.player.data:get_hp(), self.atk )
                    attackData["player"] = self.player
                    attackData["skillConfig"] = self.skill
                    attackData["damageFront"] = GlobalTools.base1
                    attackData["damageLast"] = GlobalTools.base1
                    attackData["angerAir"] = GlobalTools.base0
                    attackData["type"] = 3
                    attackData["injureBuf"] = 0
                    attackData["damageType"] = self.skill.atk_type

                    enemy_player:injure(attackData)
                end
            end

        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M