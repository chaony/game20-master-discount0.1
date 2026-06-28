--天策选中身前的一名敌人，并强制其与自己决斗5秒、决斗期间 除了选中的敌人外，其余敌人对天策的伤害会减少50%。 --旧
-- 新 天策选中身前的一名敌人，并强制其与自己决斗5秒、决斗期间 天策对决斗目标造成的伤害提升会提升20%，且除了决斗目标外，所有
-- 处于天策周围的敌人每过2秒都会被施加一层“威慑”状态，威慑状态会持续5秒，处于威慑状态下的敌人对天策造成的伤害会减少10% 最多叠加3层 
---@class W_TianC_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_TianC_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    -- self.lastTime = self:getParam(1)
    -- self.atd = self:getParam(2)
    self.buffid = self:getParam(1) --威慑buf
    self.dis = self:getParam(2) --威慑buf 范围
    self.maxCount = self:getParam(3) --威慑buf 最大层数
    self.atd = self:getParam(4) --对天策造成的伤害减少百分比
    self.timer = 0
    self.lastTime = self:getParam(6) --决斗时长
    self.dmg = self:getParam(7) --决斗时长
    self.curtime = self.lastTime
end


function M:spawn( ... )
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil then
        self.skill0_count = skill0.cur_skill_config.feature.maxCount
        if self.skill0_count == nil then
            self.skill0_count = self.maxCount
        end
    else
        self.skill0_count = self.maxCount
    end
    self.targetCount = 0
    EventDispatcher:registerEvent("remove_W_TianC_skill2", {self,self.removeBuffHandler})
    EventDispatcher:registerEvent("add_W_TianC_skill2", {self,self.addBuffHandler})
end

-- --技能释放
function M:skillStart()
    --self:addBufByEnemy(false)
    --self.start = true
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local killer = data["killer"]
    local victim = data["victim"]
    local damage = data["damage"]

    if killer ~= nil and killer:equal(self.player) then
        if victim ~= nil then
            if self:checkSelect(victim) then
                data.damage = data.damage + GlobalTools:Mul(data.damage, self.dmg)
            end
        end
    end
end


--技能结束
--function M:skillEnd(data)
--    if data == nil or type(data) ~= "table" or data.normalEnd == nil or data.normalEnd == false  then
--        self.start = false
--    else
--        self.start = true
--    end
--   
--end

function M:update(dt)

    if self.start then
        self.curtime = self.curtime - dt
        if self.curtime <= 0 then
            self.start = false
            self.curtime = self.lastTime
        end
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self:addBufByEnemy(true)
            self.timer = GlobalTools.base2
        end
    end
end

-- --作为受伤者的属性临时调整
-- function M:victimDataChangeTemp(killer, skill)
--     if killer ~= nil then
--         local buffs = killer.bufMgr:findBufById(self.buffid)
--         killer.data.physicaldamage:addToMulListTemp((self.atd * -1)*#buffs)
--         killer.data.magicdamage:addToMulListTemp((self.atd * -1)*#buffs)
--     end
-- end

--攻击结束处理
function M:afterAttack(data)
    local killer = data.killer
    local victim = data.victim
    local damage = data.damage
    if killer ~= nil and killer:equal(self.player) == false then
        if victim ~= nil and victim:equal(self.player) then
            local buffs = killer.bufMgr:findBufById(self.buffid)
            local atd_num = GlobalTools:Mul(self.atd, GlobalTools:ToFix(#buffs) )
            local out_damge = GlobalTools:Mul(data.damage, atd_num)
            data.damage = data.damage - out_damge
        end
    end
end



function M:addBufByEnemy(isGoon)
    local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player.camp)
    for i = 1, enemys.Count do
        local enemy = enemys:get(i - 1)
        local distance = GlobalTools:Distance(enemy.position, self.player.position )
        if distance < GlobalTools:ToFix2(self.dis) then
            if self:checkSelect(enemy) == false then
                if isGoon then
                    self:isGoonAdd(enemy)
                else
                    enemy.bufMgr:addBufById(self.buffid,self.player)
                end
            end
        end
    end
end

function M:isGoonAdd( enemy )
    local buffs = enemy.bufMgr:findBufById(self.buffid)
    if buffs[1] == nil or buffs[1].bufWork.count < self.skill0_count then
        enemy.bufMgr:addBufById(self.buffid,self.player)
        --else
        --    self.start = false
    end
end


--是否被决斗选中
function M:checkSelect(killer)
    if killer ~= nil then
        if killer.bufMgr ~= nil then
            local buff = killer.bufMgr:findBufByTag("W_TianC_skill2")
            for k,v in ipairs(buff) do
                if self.player:equal(v.source) == true then
                    return true
                end
            end
        end
    end
    return false
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and buff.source ~= nil and buff.source:equal(self.player) then
        self.targetCount = self.targetCount + 1
        self.start = true
    end
end

function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and buff.source ~= nil and buff.source:equal(self.player) then
        self.targetCount = self.targetCount - 1
        if self.targetCount <= 0 then
            self.targetCount = 0
            self.start = false
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("remove_W_TianC_skill2", {self,self.removeBuffHandler})
    EventDispatcher:unRegisterEvent("add_W_TianC_skill2", {self,self.addBuffHandler})
    M.super.destroy(self)
end

return M