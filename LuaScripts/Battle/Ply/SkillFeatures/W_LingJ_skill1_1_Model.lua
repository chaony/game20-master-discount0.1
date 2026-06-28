-- 战斗开始时，灵鹫会召唤两条冰犬，冰犬拥有灵鹫30%的属性值。之后战斗时间每过去15秒，
-- 灵鹫便会复活一条死去的冰犬，若没有冰犬死亡，则灵鹫会重新召唤一条冰犬代替生命最低
-- 的冰犬(一条狗打灵鹫的目标,一条狗随机选另外的目标,老冰犬被代替算死)

---@class W_LingJ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LingJ_skill1_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    local summonData = require("Battle.Ply.SkillFeaturesData.W_Lingj_skill1_1_Data")
    self.summonData = table.copy(summonData)
    --战斗开始时，灵鹫会召唤两条冰犬，冰犬拥有灵鹫30%的属性值
    self.attrRate = self:getParam(1)
    --之后战斗时间每过去15秒
    self.perTime = self:getParam(2)
    --初始化当前时间
    self.curTime = 0;
    self.curCount = 0;
    self.canCallDog = true
    if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene and self.skill.no_hangup == 0 then
        self.canCallDog = false        
    end
end

--出生
function M:spawn()
    M.super.spawn(self)
    local skill0Item = self.player.plySkill:getSkillByName("skill0")
    if skill0Item ~= nil then
        self.skill0 = skill0Item.cur_skill_config.feature
    end
    self.curLangIndex = 0
    if self.canCallDog then
        --战斗一开始创建 2 条冰犬
        self:createDog(self.curLangIndex);
        -- 间隔1帧召唤第二条冰犬
        self.callDog2Task = TimeTools:startOneDtTask(GlobalTools.base0_1, function()
            self.curLangIndex = self.curLangIndex + 1
            self:createDog(self.curLangIndex);
        end, false)
    end
end


--角色出生结束
function M:spawnFinish()
    self.curTime = self.perTime
    self.curCount = 0;
    M.super.spawnFinish(self)
end

function M:update(dt,unsdt)
    if self.callDog2Task then
        self.callDog2Task:update_dt(dt)
    end
    -- 每隔15秒 检测一次
    if self.canCallDog and self.curTime > 0 then
        self.curTime = self.curTime - dt;
        if self.curTime <= 0 then
            self:checkLangState()
            self.curTime = self.perTime
        end
    end
end


function M:checkLangState()
    if self.player.summonList.Count < 2 then
        --死了冰犬
        self.curLangIndex = self.curLangIndex + 1
        self:createDog(self.curLangIndex)
    else
        local minHp_ply = nil
        --最小血量
        local minHp = GlobalTools:Mul(GlobalTools.base10000, GlobalTools.base10000);
        --遍历我自己的宠物
        for i = 1, self.player.summonList.list.Count do
            local key = self.player.summonList.list:get(i-1)
            local plys = self.player.summonList:get(key)
            for i, v in ipairs(plys) do
                local curHp = v.data:get_curHp()
                if curHp < minHp then
                    minHp_ply = v;
                    minHp = curHp
                end
            end
        end
        -- 找到血量最低的销毁掉
        if minHp_ply ~= nil then
            EventDispatcher:dipatchEvent("PlayerDead",{ data = minHp_ply } )
            minHp_ply:destroy();
        end
        self.curLangIndex = self.curLangIndex + 1
        -- 重新创建 冰犬
        self:createDog(self.curLangIndex)
    end
end


function M:createDog( index )
    self.summonData.id = index;
    local SendForFuncframe = require("Battle.Ply.Fuc.SendForFunc").new()
    SendForFuncframe:init(self.summonData, self.player)
    local ply = SendForFuncframe.player
    if ply ~= nil then
        if self.skill0 ~= nil then
            self.skill0:setSummonYinJiBuf( ply )
        end
        ply.data:set_level( self.player.data:get_level() )
        ply.data:set_evo( self.player.data:get_evo() )
        ply.plySkill:refreshSkill(nil)
        ply.data.hp:setInitialValue(ply.data:getCopyData(self.player.data.hp, true, self.attrRate))
        ply.data.atk:setInitialValue(ply.data:getCopyData(self.player.data.atk, true, self.attrRate))
        ply.data.def:setInitialValue(ply.data:getCopyData(self.player.data.def, true, self.attrRate))
        ply.data:set_curHp(ply.data:get_hp())
        local distance = GlobalTools.base1
        if index == 1 then
            distance = GlobalTools.base2
        end
        ply:setPos(self.player.position + self.player:getForward() * distance);
        --self.summon.aiEngine:changeState("idle")
        ply:ShowHpBar(false)
        TimeTools:delayTime(GlobalTools.base2,function()
            ply:ShowHpBar(true)
            if self.curCount == 0 then
                ply:lockEnemy( self.player.enemy )
            else
                local enemys = self.player.plyMgr:getPlayers(-self.player.camp)
                if enemys.Count >= 2 then
                    for i = 1, enemys.Count do
                        local enemy = enemys:get(i-1)
                        if self:summonHasEnemy(enemy) == false then
                            ply:lockEnemy( enemy )
                        end
                    end
                else
                    ply:lockEnemy( self.player.enemy )
                end
            end
            self.curCount = self.curCount + 1;
        end)
    end
end

-- 宠物的索敌是否有这个敌人 
function M:summonHasEnemy( ply )
    for i = 1, self.player.summonList.list.Count do
        local key = self.player.summonList.list:get(i-1)
        local plys = self.player.summonList:get(key)
        for i, v in ipairs(plys) do
            local enemy = v:get_enemy()
            if enemy ~= nil and enemy:equal(ply) then
                return true;
            end
        end
    end
    return false;
end


function M:destroy()
    self.callDog2Task = nil
    M.super.destroy(self)
end

return M