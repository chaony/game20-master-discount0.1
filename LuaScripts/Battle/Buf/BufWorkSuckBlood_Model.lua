--吸血
---@class BufWorkSuckBlood : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkSuckBlood", BufWork_Model)


function M:initFinish()
    self.totalDamage = 0
    self.workTime = 0
end

function M:work()
    M.super.work(self)
    local attackData = BattleTool:getBaseAttackData()
    local damage = self.playerBuf:checkParam("damage", GlobalTools.base1)
    local damage_last = self.playerBuf:checkParam("damageLast", GlobalTools.base1)
    local damageRaise = self.playerBuf:checkParam("damageRaise", 0)
    local work_dmg = GlobalTools:Mul(self.workTime, damageRaise)
    damage = damage + work_dmg;
    local atk = self.playerBuf:getBaseAtk()
    
    local anger = self.playerBuf:checkParam("angerAir", 0)

    attackData["damage"] = GlobalTools:Mul(damage, atk)
    attackData["player"] = self.playerBuf.source
    attackData["skillConfig"] = self.playerBuf.sourceSkill
    attackData["injureType"] = "buff"
    attackData["sourceBuff"] = self.playerBuf

    attackData["damageFront"] = GlobalTools.base1
    attackData["damageLast"] = damage_last
    attackData["angerAir"] = anger
    attackData["type"] = 0
    attackData["injureBuf"] = 0
    attackData["damageType"] = 1
    attackData["mustHit"] = true
    attackData["prefabName"] = self.playerBuf:checkParam("hitEffect", "")
    attackData["power"] = self.playerBuf:checkParam("power", 0)

    if self.playerBuf.source ~= nil and self.playerBuf.sourceSkill ~= nil  then
        attackData["damageType"] = self.playerBuf.sourceSkill.atk_type
        if anger > 0 then
            --攻击增怒
            local hit_energy_num = self.playerBuf.source.data:getAtkEnemgy(self.playerBuf.sourceSkill, anger)
            self.playerBuf.source.data:addAnger( hit_energy_num )
        end
    end
    
    local value = self.playerBuf.player.data:get_curHp()
    self.playerBuf.player:injure(attackData)
    
    if self.playerBuf.player ~= nil then
        value = value - self.playerBuf.player.data:get_curHp()
    end

    local hp = GlobalTools:Mul(value, tonumber(self.playerBuf:checkParam("perSuckValue", 0)))
    if hp > 0 then
        self.playerBuf.source:cure("fix", self.playerBuf.source, hp, self.playerBuf.sourceSkill, nil, self.playerBuf)
    end
    self.totalDamage = self.totalDamage + value
    
    self.workTime = self.workTime + 1
end

function M:stop()
    M.super.stop(self)
    local suckValue = tonumber(self.playerBuf:checkParam("suckValue", 0))
    if suckValue > 0 then
        local hp = GlobalTools:Mul( self.totalDamage, suckValue )
        self.playerBuf.source:cure("fix", self.playerBuf.source, hp, self.playerBuf.sourceSkill, nil, self.playerBuf)
    end
end

return M