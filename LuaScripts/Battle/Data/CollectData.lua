--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-19 15:24:37
]]

---@class CollectData 收集数据
local M = class("CollectData")

function M:ctor()
    SceneManager:setData("battle_log", {})
    self.frameTag = "nil"
end

---@param source PlayerModel
---@param target PlayerModel
---@param sourceSkill SkillDataConfig
function M:causeCure(source, target, sourceSkill, value, overflow)
    local list = self:getLogData()
    local data = {}
    data.dataType = "cure"
    data.killer = self:getPlayerKey(source)
    data.victim = self:getPlayerKey(target)
    data.skill = self:getSkillKey(sourceSkill)
    data.cure = value or 0
    data.overflow = overflow
    data.frame = self.frameTag
    table.insert(list, data)
end

---@param target PlayerModel
---@param attackData Battle_AttackData
---@param wantdata Battle_BeHitDirectData_WantData
function M:causeDamage(target, attackData, wantdata)
    local list = self:getLogData()
    local data = {}
    data.dataType = "damage"
    data.killer = self:getPlayerKey(attackData.player)
    data.victim = self:getPlayerKey(target)
    local skill = self:getSkillKey(attackData.skillConfig, attackData.sourceBuff) 
    data.attackerAnger = attackData.attackerAnger or 0
    data.defenderAnger = attackData.defenderAnger or 0
    data.isCrit = attackData.isCrit or false
    data.isDodge = attackData.isDodge or false
    data.isGod = attackData.isGod or false
    data.skill = string.format("%s|%s", skill, tostring(attackData.injureType))
    data.damage = wantdata.damage
    data.frame = self.frameTag
    table.insert(list, data)
end

---@param source PlayerModel
---@param target PlayerModel
---@param sourceSkill SkillDataConfig
---@param data Battle_AddBuff_Data
function M:causeBuff(source, target, sourceSkill, buffData, id)
    local list = self:getLogData()
    local data = {}
    data.dataType = "buff"
    data.killer = self:getPlayerKey(source)
    data.victim = self:getPlayerKey(target)
    data.skill = self:getSkillKey(sourceSkill)
    data.buff = buffData.buff_id or id or 0
    data.frame = self.frameTag
    table.insert(list, data)
end

---@param playerBuf PlayerBuf_Model
function M:causeShield(playerBuf)
    local list = self:getLogData()
    local data = {}
    data.dataType = "shield"
    data.killer = self:getPlayerKey(playerBuf.source)
    data.victim = self:getPlayerKey(playerBuf.player)
    data.skill = self:getSkillKey(playerBuf.sourceSkill, playerBuf)
    data.data = Mathf.Floor(GlobalTools:ToFloat(tonumber(playerBuf.bufWork.value) or 0))
    data.frame = self.frameTag
    table.insert(list, data)
end

---怒气变化
---@param player PlayerModel 
function M:causeAnger(player, anger)
    local list = self:getLogData()
    local data = {}
    data.dataType = "anger"
    data.killer = self:getPlayerKey(player)
    data.victim = "addAnger"
    data.skill = ""
    data.data = Mathf.Floor(GlobalTools:ToFloat(tonumber(anger) or 0))
    data.frame = self.frameTag
    table.insert(list, data)
end

---@param player PlayerModel
---@param buff PlayerBuf_Model
function M:dispelBuff(player, buff)
    local list = self:getLogData()
    local data = {}
    data.dataType = "dispel_buff"
    data.killer = self:getPlayerKey(player)
    data.victim = self:getPlayerKey(player.player)
    data.skill = ""
    data.buff = buff.buffId or ""
    data.frame = self.frameTag
    table.insert(list, data)
end

---@param player PlayerModel
function M:markPlayerFrame(player)
    local frame = SceneManager.curScene:get_loopTimeNormal()
    self.frameTag = string.format("%s_%s", self:getPlayerKey(player), tostring(Mathf.Floor(frame)))
end

---@param player PlayerModel
function M:getPlayerKey(player)
    if player then
        return string.format("%s_%s_%s", player.plyType, player.camp, tostring(player.index + 1))
    end
    return ""
end

---@param skillData SkillDataConfig
---@param buffData PlayerBuf_Model
function M:getSkillKey(skillData, buffData)
    local skill = skillData and skillData.anim_name or ""
    local buff = ""
    if buffData then
        buff = string.format("%s:%s", buffData.bufWork.name, buffData.id)
    end
    if buff == "" and skill == "" then
        local x = 1
        x = x + 1
    end
    return string.format("%s|%s", skill, buff)    
end

function M:getLogData()
    local list = SceneManager:getData("battle_log")
    if not list then
        SceneManager:setData("battle_log", {})
    end
    return SceneManager:getData("battle_log")
end

function M:clear()
    SceneManager:setData("battle_log", nil)
end

function M:destroy()
    self:clear()
end

return M;
