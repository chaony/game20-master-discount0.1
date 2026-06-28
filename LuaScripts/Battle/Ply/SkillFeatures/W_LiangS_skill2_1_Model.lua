--等级2:若攻击范围内存在敌人，则梁山还会获得20点吸血等级

--改
--
---@class W_LiangS_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LiangS_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --攻击力buff 等级 1 10%  等级 3 15%
    self.atkBuffId = self:getParam(1)
    --吸血buff 等级 2
    self.leechingBuffId = self:getParam(2)
    --是否一开始就生效 N 层
    self.startAddFloor = self:getParam(3)

    self.enemyCount = 0 -- 赋值一个默认值（挂机界面没有赋值）
end


function M:spawnFinish()
    M.super.spawnFinish(self)
    --等级4 一开始立刻获取了一层效果
    if self.startAddFloor > 0 then
        for i = 1, self.startAddFloor do
            self.player.bufMgr:addBufById(self.atkBuffId,self.player)
            self.player.bufMgr:addBufById(self.leechingBuffId,self.player)
        end
    end
    --出生时候敌人的数量
    self.enemyCount = self:getEnemyCount();
end


function M:getEnemyCount()
    local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp());
    local count = 0;
    for i = enemys.Count, 1, -1 do
        local enemy_player = enemys:get(i-1)
        if enemy_player.master == nil then
            count = count + 1;
        end
    end
    return count;
end


function M:update(dt,unsdt)
    M.super.update(self, dt,unsdt)
    if self.player ~= nil and self.player.data:get_curHp() > 0 then
        local curEnemyCount = self:getEnemyCount();
        if curEnemyCount < self.enemyCount then
            self.player.bufMgr:addBufById(self.atkBuffId,self.player)
            self.player.bufMgr:addBufById(self.leechingBuffId,self.player)
            self.enemyCount = curEnemyCount;
        end
    end
    
    --local count = 0
    --if  self.player ~= nil and self.player.data:get_curHp() > 0 then
    --    local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp())
    --    for i = enemys.Count, 1, -1 do
    --        local enemy_player = enemys:get(i-1)
    --        local distance = GlobalTools:Distance(self.player.position, enemy_player.position)
    --        if distance <= self.radius2 then
    --            count = count + 1
    --        end
    --    end
    --    if count ~= self.count then
    --        if self.count > 0 then
    --            self.player.bufMgr:removeBufById(self.atkBuffId)
    --            if count <= 0 then
    --                self.player.bufMgr:removeBufById(self.leechingBuffId)
    --            end
    --        end
    --        if count > 0 then
    --            for i = 1, count do
    --                self.player.bufMgr:addBufById(self.atkBuffId,self.player)
    --            end
    --            if self.count <= 0 then
    --                self.player.bufMgr:addBufById(self.leechingBuffId,self.player)
    --            end
    --        end
    --        self.count = count
    --    end
    --end
end

return M