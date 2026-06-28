---@class BattleTool @目标选择工具
local M = class("BattleTool")

---@param player PlayerModel
---@return SkillFeatures_Model
function M:getSkillFeatureByName(player, animName)
    local skillItem = player.plySkill:getSkillByName(animName)
    if skillItem ~= nil then
        return skillItem.cur_skill_config and skillItem.cur_skill_config.feature
    end
    return nil
end


--- 技能结束 判断是否可以适用attack状态技能(attack1,skill0,skill1,skill2)
---@param player PlayerModel
function M:skillEndCanUseAttack(player)
    if player.aiEngine.skillConfig and (player.aiEngine.skillConfig.anim_name ~= "skill3" and player.aiEngine.skillConfig.anim_name ~= "skill3_plus") then -- 排除放大招的情况
        return true
    end
end

---@param buff PlayerBuf_Model
function M:isBuff(buff)
    for k,v in ipairs(buff.tag) do
        if v == "buff" then
            return true
        end
    end
    return false
end

---@param buff PlayerBuf_Model
function M:isDeBuff(buff)
    for k,v in ipairs(buff.tag) do
        if v == "debuff" then
            return true
        end
    end
    return false
end

---@param player2 PlayerModel
function M:isSameRaceOrYuan(race, player2)
    return player2.plyData.race == 7 or player2.plyData.race == race
end

---@param buff PlayerBuf_Model
function M:isCureShield(buff)
    if(buff.type == "AddBlood" or buff.type == "Shield") then
        return true
    end
end

---@param buff PlayerBuf_Model
function M:isShieldBuff(buff)
    if buff.type == "Shield" then
        return true
    end
    for i, v in ipairs(buff.tagExtra) do
        if v == "shield" then
            return true
        end
    end
    return false
end

---@param buff PlayerBuf_Model
function M:isCureShieldOrBuff(buff)
    if self:isCureShield(buff) then
        return true
    end
    
    if self:isBuff(buff) then
        return true
    end
    return false
end

--- 战斗数据是否有透传参数
---@param attackData Battle_AttackData
function M:attackDataHaveExtraParam(attackData, param)
    if attackData and attackData.extraParam then
        return table.indexof(attackData.extraParam, param)
    end
    return false
end

--- 是否是助攻角色
---@param killer PlayerModel
---@param victim PlayerModel
function M:isKillerAssistance(killer, victim)
    if victim then
        local playerInstanceId = killer:get_playerInstanceId()
        return playerInstanceId and victim.assistsKiller[playerInstanceId] ~= nil
    end
    return false
end

---@param feature SkillFeatures_Model
---@param attackData Battle_AttackData
---@param buffTag string 
function M:isMySkillBuff(feature, attackData, buffTag)
    if attackData and feature.skill == attackData.skillConfig then
        if attackData.sourceBuff and attackData.sourceBuff:checkTag(buffTag) then
            return true
        end
    end
    return false
end

---@param player PlayerModel
---@param attackData Battle_AttackData
---@param buffTag string
function M:isMySkillBuffByPlayer(player, attackData, killer, buffTag)
    if attackData and player:equal(killer) then
        if attackData.sourceBuff and attackData.sourceBuff:checkTag(buffTag) then
            return true
        end
    end
    return false
end

--- 是否是我的技能
---@param player PlayerModel
---@param attackData Battle_AttackData
---@param anim_name string
function M:isMySkillWithPlayer(player, attackData, anim_name)
    if player:equal(attackData.player) and attackData.injureType == "skill" then
        if anim_name then
            return attackData.skillConfig and attackData.skillConfig.anim_name == anim_name
        end
        return true
    end
    return false
end


--- 是否是我的技能3
---@param player PlayerModel
---@param attackData Battle_AttackData
function M:isMySkill3(player, attackData)
    return self:isMySkillWithPlayer(player, attackData, "skill3")
end

--- 是否是我的技能0
---@param player PlayerModel
---@param attackData Battle_AttackData
function M:isMySkill0(player, attackData)
    return self:isMySkillWithPlayer(player, attackData, "skill0")
end

--- 是否是技能伤害(排除attack1 和 其他伤害
---@param attackData Battle_AttackData
function M:isSkillInjure(attackData)
    if attackData.skillConfig and attackData.skillConfig.anim_name ~= "attack1" then	-- 普攻不增伤
        -- 技能伤害或技能buff伤害
        if attackData.injureType == "skill" or (attackData.sourceBuff and attackData.sourceBuff.sourceType == 1) then	
            return true
        end
    end
    return false
end

--- 是否是技能伤害(排除attack1 和 其他伤害
---@param attackData Battle_AttackData
function M:isInjureByName(attackData, anim_name)
    if attackData.skillConfig and attackData.skillConfig.anim_name == anim_name  then	-- 普攻不增伤
        -- 技能伤害或技能buff伤害
        if attackData.injureType == "skill" or (attackData.sourceBuff and attackData.sourceBuff.sourceType == 1) then
            return true
        end
    end
    return false
end


---统一创建的战斗数据 基础数据
---@return Battle_AttackData
function M:getBaseAttackData()
    local attackData = {
        damageFront = GlobalTools.base1,
        damageLast = GlobalTools.base1,
        damageExtra = GlobalTools.base0,
    }
    return attackData
end

---@return Battle_AttackData
---@return Battle_BeHitDirectData_WantData
function M:getHitDirectAttackData(killer, damage, skill)
    local attackData = self:getBaseAttackData()
    attackData["damage"] = damage
    attackData["player"] = killer
    attackData["skillConfig"] = skill
    attackData["injureType"] = skill and "skill" or ""
    attackData["damageFront"] = GlobalTools.base1
    attackData["damageLast"] = GlobalTools.base1
    attackData["angerAir"] = 0
    attackData["type"] = 0
    attackData["injureBuf"] = 0
    attackData["damageType"] = 1
    attackData["ignoreGuard"] = false

    local wantdata = {}
    wantdata["damage"] = attackData["damage"]
    wantdata["suck_value"]  = 0
    return attackData, wantdata
end
-- 检查控制类buff
function M:checkImmunityBuff(buffs, player)
    for k, v in ipairs(buffs) do
        if v.bufWork:checkTag("control", player) == true then
            return false
        end
    end
    return true
end

--------------------------- 随机 --------------------------
---随机数组中的一个元素
function M:randomArrayOneCommon(list)
    return list[WRandom:randomNum(1, #list, true)]
end

---随机数组中的一个元素
function M:randomArrayZeroCommon(list)
    return list[WRandom:randomNum(0, #list-1, true)]
end

-- 检查英雄和目标是否是是变对面
function M:checkPlayerAndTargetForward(player, target)
    local isForward = nil
    if player ~= nil and target ~= nil then
        local dir = target.position - player.position
        if FixVector3.Dot(dir, target:getForward()) > 0 then
            isForward = false -- 背对敌人
        else
            isForward = true -- 面向敌人
        end
    end
    return isForward
end

--- 安全触发动作事件
---@param player PlayerModel
function M:safeTriggerActionEventWork(player, action, event, key)
    if player and player.evtMgr then
        player.evtMgr:triggerActionEventWorkByKey(action, event, key)
    end
end

--- 安全触发common事件
---@param player PlayerModel
function M:safeTriggerCommonEventWork(player, event, key)
    if player and player.evtMgr then
        player.evtMgr:commonEventWorkByKey(event, key)
    end
end

--- 安全触发common事件
---@param player PlayerModel
---@param target PlayerModel
function M:killerIsMe(player, target)
    if target and player ~= target then
        return player:equal(target.killer)
    end
    return false
end

--- 按照是否有buff排序，无buff的排在前面
---@param players Battle_List
---@param priority boolean 是否是优先(如果优先，有buff的会排在后面返回）
function M:findNoBuffPlayers(players, tag, priority)
    local haveBuff = {}
    players:safeWalkInverted(function(ply)
        if ply.bufMgr:hasBufByTag(tag) then
            players:remove(ply)
            table.insert(haveBuff, ply)
        end
    end)
    if priority then
        for i, v in ipairs(haveBuff) do
            players:add(v)
        end
    end
    return players
end

---添加一个转化固定值的伤害
---@param player PlayerModel
---@param target PlayerModel
function M:addFixedBleed(player, target, buffData, value, sourceSkill, buffId, sourceBuff)
    for k,v in ipairs(buffData.param[1]) do
        if v[1] == "param" then
            buffData.param[1][k][2] = value
        elseif v[1] == "type" then
            buffData.param[1][k][2] = 1
        end
    end
    target.bufMgr:addBufByData(buffData, player, sourceSkill, buffId, sourceBuff)
end

---添加一个转化固定值的护盾
---@param player PlayerModel
---@param target PlayerModel
function M:addFixedShield(player, target, buffData, value, sourceSkill, buffId, sourceBuff)
    for k,v in ipairs(buffData.param[1]) do
        if v[1] == "shieldParam" then
            buffData.param[1][k][2] = value
        elseif v[1] == "type" then
            buffData.param[1][k][2] = 3
        end
    end
    target.bufMgr:addBufByData(buffData, player, sourceSkill, buffId, sourceBuff)
end

---转化战斗版本号
function M:convertBattleVersion(ver)
    local ver1_tab = string.split(ver, ".")
    local first = tonumber(string.sub(ver1_tab[1], 2)) or 0
    local second = tonumber(ver1_tab[2]) or 0
    local third = tonumber(ver1_tab[3]) or 0
    return {first, second, third}
end

---@return number @0:相等 -1小于，1大于
function M:compareBattleVersion(ver1, ver2)
    local ver1_info = self:convertBattleVersion(ver1)
    local ver2_info = self:convertBattleVersion(ver2)
    for i, v in ipairs(ver1_info) do
        if ver2_info[i] > v then
            return -1
        elseif ver2_info[i] < v then
            return 1
        end
    end
    return 0
end

return M
