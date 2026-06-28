--自身近战范围内每存在一个敌人，就获得20%的防御提升，最多提升80%

---@class W_CangY_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_CangY_skill0_1_Model", SkillFeatures_Model)

M.curCount = 0

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.enemyRadius = self:getParam(1)
    self.def = self:getParam(2)
    self.maxCount = self:getParam(3)
    self.effectBuff = self:getParam(4)
    self.interval = GlobalTools.base0_5
    self.timer = 0
    self.curCount = 0
end

--角色出生结束
function M:spawnFinish()
    self.timer = self.interval
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)

    if self.timer > 0 then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.timer = self.interval
            self:checkArea()
        end
    end
end

function M:checkArea()
    local count = 0
    local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player.camp)
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        if GlobalTools:Distance(enemy.position, self.player.position) <= GlobalTools:ToFix2(self.enemyRadius) then
            count = count + 1
        end
    end
    count = GlobalTools:Clamp(count, 0, self.maxCount)
    --层数改变，先移除原有加成，再加新的加成
    if count ~= self.curCount then
        local fix_count = GlobalTools:ToFix(self.curCount)
        if self.curCount == 0 and count > 0 then
            self.player.bufMgr:addBufById(self.effectBuff, self.player)
        elseif self.curCount > 0 and count == 0 then
            self.player.bufMgr:removeBufById(self.effectBuff)
        end
        local count_def = GlobalTools:Mul( fix_count,self.def)
        self.player.data.def:removeFromMulList(count_def)
        self.curCount = count
        self.player.data.def:addToMulList(GlobalTools:Mul(self.def, fix_count))
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M