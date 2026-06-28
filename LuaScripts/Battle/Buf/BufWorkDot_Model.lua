---@class BufWorkDot_Model : BufWork_Model @持续伤害buff，适用于灼烧，中毒，流血，buff内叠加层数，
local M = class("BufWorkDot_Model", BufWork_Model)

--当前叠加层数
M.count = 0
--最大叠加层数
M.maxCount = 0

M.extraBuffId = nil
M.extraBuff = nil

function M:initFinish()
    self.type = self.playerBuf:checkParam("type", 2)
    self.param = self.playerBuf:checkParam("param", 1)
    --当前叠加层数
    self.count = 0;
    --最大叠加层数
    self.maxCount = self.playerBuf:get_max_times()
    self.extraBuffId = {}
    self.extraBuff = {}
    local buffIndex = 1
    while(true) do
        local buffId = self.playerBuf:checkParam("buff"..buffIndex, 0)
        buffIndex = buffIndex + 1
        if buffId == 0 then
            break
        else
            table.insert(self.extraBuffId, buffId)
            local buff = self.playerBuf.mgr:addBufById(buffId, self.playerBuf.source)
            buff.isDotBuf = true
            table.insert(self.extraBuff, buff)
        end
    end
    --范围流血的半径（0时只本角色流血）
    self.radius = self.playerBuf:checkParam("radius", 0)
    self:refreshDamage()
end

--显示buf图标，子类重写
function M:addBufIcon()
end

--显示buf图标，子类重写
function M:removeBufIcon(count)
end

function M:reset(  )
    M.super.reset(self)
    if self.count < self.maxCount then
        self.count = self.count + 1
        self:showBufIcon(true)
    end
    self:refreshDamage()
end

--- type = 5 :使用百分百的攻击计算伤害后，再乘百分比 外功伤害
--- type = 6 :使用百分百的攻击计算伤害后，再乘百分比 内功伤害
function M:refreshDamage()
    local damage = 0
    --固定值
    if self.type == 1 then
        damage = self.param
        --基于攻击力
    elseif self.type == 2 then
        local atk = self.playerBuf:getBaseAtk()
        damage = GlobalTools:Mul( atk, self.param )
        --基于最大血量
    elseif self.type == 3 then
        local hp = self.playerBuf.player.data:get_hp();
        damage = GlobalTools:Mul( hp, self.param )
        --基于当前血量
    elseif self.type == 4 then
        local curHp = self.playerBuf.player.data:get_curHp();
        damage = GlobalTools:Mul( curHp, self.param )
    elseif self.type == 5 then -- 类型5的伤害类型为后计算百分比（使用百分百的攻击计算伤害）外功伤害
        local atk = self.playerBuf:getBaseAtk()
        local skill = self.playerBuf.sourceSkill
        damage = self.playerBuf.player.data:damageCal(skill, self.playerBuf.source, atk,
                GlobalTools.base1, GlobalTools.base1, 2, GlobalTools.base2, false)
        damage = GlobalTools:Mul(damage, self.param)
    elseif self.type == 6 then -- 类型6的伤害类型为后计算百分比（使用百分百的攻击计算伤害）内功伤害
        local atk = self.playerBuf:getBaseAtk()
        local skill = self.playerBuf.sourceSkill
        damage = self.playerBuf.player.data:damageCal(skill, self.playerBuf.source, atk,
                GlobalTools.base1, GlobalTools.base1, 1, GlobalTools.base2, false)
        damage = GlobalTools:Mul(damage, self.param)
    else
        Logger.logError(self.type, "Dot伤害类型没有处理, 使用了默认值0")
    end
    if self.type == 3 or self.type == 4 then
        damage = self.playerBuf.player.data:dotCal(self.playerBuf.sourceSkill, self.playerBuf.source, damage)
    end
    self.damage = damage
end

function M:work()
    M.super.work(self)
    if self.radius > 0 then
        local players = SceneManager:getCurSceneModel().plyMgr:getPlayers(self.playerBuf.player:get_camp())
        for i = 1, players.Count do
            local player = players:get(i - 1)
            if GlobalTools:Distance(player.position, self.playerBuf.player.position) <= GlobalTools:ToFix2(self.radius) then
                self:injure(player)
            end
        end
    else
        self:injure(self.playerBuf.player)
    end
    for k,v in ipairs(self.extraBuff) do
        if v ~= nil and v.bufWork ~= nil then
            v.bufWork:work()
        end
    end
end

function M:forceTriggerOnce()
    if self.radius <= 0 then    -- 触发非范围流血
        self:injure(self.playerBuf.player)
    end
end

function M:injure(player)
    if self.playerBuf.player.data:checkInvincible(0) == true then
        return
    end

    if player.isBoss and (self.type == 3 or self.type == 4) then
        return
    end

    if player:isLive() then
        ---@type Battle_AttackData
        local attackData = BattleTool:getBaseAttackData()
        attackData["damage"] = self.damage
        attackData["player"] = self.playerBuf.source
        attackData["skillConfig"] = self.playerBuf.sourceSkill
        attackData["injureType"] = "dot"
        attackData["sourceBuff"] = self.playerBuf
        attackData["damageFront"] = GlobalTools.base1
        attackData["damageLast"] = GlobalTools:ToFix(self.count)
        attackData["angerAir"] = 0
        attackData["type"] = 0
        attackData["injureBuf"] = 0
        attackData["damageType"] = 1
        if self.playerBuf.sourceSkill ~= nil then
            attackData["damageType"] = self.playerBuf.sourceSkill.atk_type
        end

        local wantdata = {}
        wantdata["damage"] = attackData["damage"]
        wantdata["suck_value"]  = 0

        -- 伤害类型5,6已经是计算过的伤害，直接造成伤害
        if self.type == 3 or self.type == 4 or self.type == 5 or self.type == 6 then
            player:beHitDirect(self.playerBuf.source, attackData, wantdata, false, true)
        else
            player:injure(attackData)
        end
    end
end

function M:upgrade(param)
    
end

function M:stop()
    self:showBufIcon(false, self.count)
    for k,v in ipairs(self.extraBuff) do
        if v ~= nil then
            self.playerBuf.mgr:removeBuf(v)
        end
    end
    M.super.stop(self)
end

return M