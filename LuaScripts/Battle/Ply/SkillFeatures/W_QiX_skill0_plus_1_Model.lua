--等级1：花间每次释放普攻时，自身会损失5%的最大生命值，同时治疗全队，治疗量相当于自身损失生命的2倍
--等级2：每次普攻自身损失7%的最大生命值
--等级3：与花间同一阵营的侠客，得到的恢复效果，相当于花间损失生命值4倍
--等级4：花间如果阵亡，会立即恢复全队40%的最大生命值。
---@class W_QiX_skill0_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_QiX_skill0_plus_1_Model", SkillFeatures_Model)

local table_data = require("Battle.Ply.SkillFeaturesData.W_QiX_skill0_Data")


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.selfBuffId = self:getParam(1) --损失5%的最大生命值
    self.cureRate = self:getParam(2) --治疗量相当于自身损失生命的2倍
    self.cureRate2 = self:getParam(3) --治疗量相当于自身损失生命的4倍
    self.cureBuff = self:getParam(4) --恢复全队40%的最大生命值

    if self.cureBuff > 0 then
        EventDispatcher:registerEvent("PlayerDead", {self, self.playerDeadHandle})
    end
end

function M:skillDispatch(data)
    if data.eventName == "attack1_shoot" then
        local hp_cha = self.player.data:get_hp() - self.player.data:get_curHp()
        self.player.bufMgr:addBufById(self.selfBuffId,self.player,self.skill)
        local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
        if friends.Count > 0 then
            for i = 0, friends.Count-1 do
                ---@type PlayerModel
                local player = friends:get(i)
                if not self.player:equal(player) then
                    if player:isLive() then
                        if self.cureRate2 > 0 and player.plyData.race == self.player.plyData.race then
                            local cureHp = GlobalTools:Mul(hp_cha, self.cureRate2)
                            player:cure("fix", self.player, cureHp, self.skill)
                        else
                            local cureHp = GlobalTools:Mul(hp_cha, self.cureRate)
                            player:cure("fix", self.player, cureHp, self.skill)
                        end
                    end
                end
            end
        end
    end
end

--死亡回调
function M:PlayerDeadHandler( eventName, data )
    local player = data["data"]
    if player ~= nil and player:equal(self.player)  then
        local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
        if friends.Count > 0 then
            for i = 0, friends.Count-1 do
                ---@type PlayerModel
                local player = friends:get(i)
                if not self.player:equal(player) then
                    if player:isLive() then
                        player.bufMgr:addBufById(self.cureBuff,self.player,self.skill)
                    end
                end
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
    if self.cureBuff > 0 then
        EventDispatcher:unRegisterEvent("PlayerDead", {self, self.playerDeadHandle})
    end
end

return M