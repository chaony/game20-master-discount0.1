--为随机一名敌方侠客施加“烈毒印记”，“烈毒印记”会存在5秒，持续时间结束时会引爆，对范围内的敌人造成300%攻击力的内功伤害，并施加一层中毒，若敌人在持续期间死亡，也会立即引爆
---@class W_XingX_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_XingX_skill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --self.buffId = self:getParam(1) --剧毒印记buf传到参数
    --self.dis = self:getParam(2) --范围
    --self.maxTime = self:getParam(3) --存在时长
    --self.atk = self:getParam(4) -- 攻击力
    --self.buffid1 = self:getParam(5) -- 爆炸特效buf
    --self.buffid2 = self:getParam(6) -- 中毒buf
end

function M:spawn()
    M.super.spawn(self)
    --EventDispatcher:registerEvent("PlayerDead", {self,self.deadHandler})
    --
    --EventDispatcher:registerEvent("add_W_XingX_skill1", {self,self.addBuffHandler})
end

--
--function M:addBuffHandler(eventName, data)
--    local buff = data["buff"]
--    if buff ~= nil and buff.player ~= nil and buff.player.camp ~= self.player.camp then
--        if buff.source:equal(self.player) then
--            if self.player:get_curSkillConfig() ~= nil and self.player:get_curSkillConfig() == self.skill then
--                self.skill_Start = true
--                self.time = self.maxTime
--                self.enemy_player = buff.player
--            end
--        end
--    end
--end
--
--function M:update(dt,unsdt)
--    if self.skill_Start then
--        if self.enemy_player ~= nil  then
--            local buffs = self.enemy_player.bufMgr:findBufByTag("W_XingX_skill1")
--            if table.nums(buffs) > 0 then
--                self.time = self.time - dt
--                if self.time <= GlobalTools.base0 or self.enemy_player:isLive() == false then
--                    local enemys = SceneManager.curScene.plyMgr:getPlayers(self.enemy_player:get_camp())
--                    self.enemy_player.bufMgr:addBufById(self.buffid2,self.player) --爆炸特效
--                    for i = 1, enemys.Count do
--                        local enemy = enemys:get(i-1)
--                        local distance = GlobalTools:DistanceOne(enemy.position, self.enemy_player.position )   
--                        self:dmgHandler(distance,enemy)
--                    end
--                    self.enemy_player.bufMgr:removeBufById(self.buffId)
--                    self.skill_Start = false
--                end
--            else
--                self.skill_Start = false
--            end
--        end
--    end
--end
--
--
--
--function M:dmgHandler(distance,enemy)
--    if distance <= self.dis then
--        enemy.bufMgr:addBufById(self.buffid3,self.player) --中毒
--
--        local attackData = {}
--        attackData["damage"] = GlobalTools:Mul( self.player.data.atk:getValue(), self.atk )
--        attackData["player"] = self.player
--        attackData["damageFront"] = GlobalTools.base1;
--        attackData["damageLast"] = GlobalTools.base1
--        attackData["angerAir"] = GlobalTools.base0
--        attackData["skillConfig"] = self.skill
--        attackData["type"] = 0
--        attackData["injureBuf"] = 0
--        attackData["damageType"] = 1
--        attackData["injureType"] = "areaDmg"
--        enemy:injure(attackData)
--    end
--end
--
---- --死亡回调
-- function M:deadHandler( eventName, data )
--     local player = data["data"]
--     if player:equal(self.player) == false then
--         if player.camp ~= self.player.camp then
--             local buff = player.bufMgr:findBufById(self.buffId)
--             if table.nums(buff) > 0  then
--                 player.bufMgr:addBufById(self.buffid3,self.player)
--                 self:dmgHandler(player)
--                 player.bufMgr:removeBufById(self.buffId,false)
--             end
--         end
--     end
-- end


function M:destroy()
    M.super.destroy(self)
    --EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
    --EventDispatcher:unRegisterEvent("PlayerDead", {self,self.deadHandler})
end

return M