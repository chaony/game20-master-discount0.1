--持续掉血buff（基于攻击力）
---@class BufWorkBleed : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkBleed", BufWork_Model)

function M:initFinish()
    self.type = self.playerBuf:checkParam("type", 2)
    local param = self.playerBuf:checkParam("param", GlobalTools.base1)
    --范围流血的半径（0时只本角色流血）
    self.radius = self.playerBuf:checkParam("radius", 0)
    self.anger = self.playerBuf:checkParam("angerAir", 0)

    self.damage = param;
    --固定值
    if self.type == 1 then
        self.damage = param
    --基于攻击力
    elseif self.type == 2 then
        local atk = self.playerBuf:getBaseAtk()
        self.damage = GlobalTools:Mul( atk,param )
    --基于最大血量
    elseif self.type == 3 then
        self.damage = GlobalTools:Mul( self.playerBuf.player.data:get_hp(), param)
    --基于当前血量
    elseif self.type == 4 then
        self.damage = GlobalTools:Mul(self.playerBuf.player.data:get_curHp(), param)
    end
    if self.type == 3 or self.type == 4 then
        self.damage = self.playerBuf.player.data:dotCal(self.playerBuf.sourceSkill, self.playerBuf.source, self.damage)
    end
end

function M:upgrade(param)

end

function M:work()
    M.super.work(self)
    if self.radius > 0 then
        local players = SceneManager:getCurSceneModel().plyMgr:getPlayers(self.playerBuf.player:get_camp())
        for i = 1, players.Count do
            local player = players:get(i - 1)
            if player ~= nil and GlobalTools:Distance(player.position, self.playerBuf.player.position) <= GlobalTools:ToFix2(self.radius) then
                self:injure(player)
            end
        end
    else
        self:injure(self.playerBuf.player)
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
        local attackData = BattleTool:getBaseAttackData()

        attackData["damage"] = self.damage
        attackData["player"] = self.playerBuf.source
        attackData["skillConfig"] = self.playerBuf.sourceSkill
        attackData["injureType"] = "buff"
        attackData["sourceBuff"] = self.playerBuf
        attackData["damageFront"] = GlobalTools.base1
        attackData["damageLast"] = GlobalTools.base1
        attackData["angerAir"] = self.anger
        attackData["type"] = 0
        attackData["injureBuf"] = 0
        attackData["damageType"] = 1
        if self.playerBuf.sourceSkill ~= nil then
            attackData["damageType"] = self.playerBuf.sourceSkill.atk_type
        end

        local wantdata = {}
        wantdata["damage"] = attackData["damage"]
        wantdata["suck_value"]  = 0

        if self.type == 3 or self.type == 4 then
            player:beHitDirect(self.playerBuf.source, attackData, wantdata, false, true)
        else
            player:injure(attackData)
        end
    end
end

return M