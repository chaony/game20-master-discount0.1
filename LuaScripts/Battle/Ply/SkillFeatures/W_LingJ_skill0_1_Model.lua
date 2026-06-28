-- 冰犬在攻击目标时会为其附加一个印记，灵鹫的普攻和技能在命中被施加了印记的敌人时，
-- 会引爆该印记，使本次伤害必定暴击，且额外附加100%攻击力的真实伤害，同一侠客的
-- 每10秒可被引爆一次印记

---@class W_LingJ_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_LingJ_skill0_1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    -- 额外增加 100 % 真实伤害
    self.exRealDamage = self:getParam(1)
    -- 同一侠客的每 x 秒可被引爆一次印记
    self.perTime = self:getParam(2)
    -- 印记buf
    self.yinjiBuf = self:getParam(5)
    
    --Logger.logError(" self.exRealDamage "..tostring(self.exRealDamage) )
    
    self.heroBaoPool = {}
    self.heroTimeCheck = {}
    
    self.skill0_start = false;
end


function M:spawnFinish()
    M.super.spawnFinish(self)
    self.skill0_start = true;
end


-- 攻击者攻击之前
function M:killerBeforeAttack( attackData, behitPlayer )
    local bufs = behitPlayer.bufMgr:findBufByTag("dog_hit")
    if table.nums(bufs) > 0 then
        if self.heroBaoPool[behitPlayer:get_playerInstanceId()] == nil then
            -- 使本次伤害必定暴击
            attackData.mustCrit = true;
            -- 额外附加100%攻击力的真实伤害
            local damage = GlobalTools:Mul(attackData.damage, self.exRealDamage)
            --真实伤害
            behitPlayer:beHitRealDamage(damage, self.player, self.skill)
            behitPlayer.bufMgr:removeBufByTag("dog_hit", true)
            table.insert(self.heroTimeCheck, { id = behitPlayer:get_playerInstanceId(),time = self.perTime })
            self.heroBaoPool[behitPlayer:get_playerInstanceId()] = 1

            if self.player.skyStar then
                self.player.skyStar:triggerStart(behitPlayer)
            end
        end
    end
end


function M:setSummonYinJiBuf( ply )
    if self.skill0_start then
        ply:hitExBuf( self.yinjiBuf )
    end
end


function M:update(dt, unsdt)
    for i, v in ipairs(self.heroTimeCheck) do
        if v.time > 0 then
            v.time = v.time - dt;
            if v.time <= 0 then
                self.heroBaoPool[v.id] = nil
                table.remove(self.heroTimeCheck,i)
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
    
end

return M