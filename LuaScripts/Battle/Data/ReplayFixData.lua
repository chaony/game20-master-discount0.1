--- 回放拓展
---@class ReplayFixData
local M = class("ReplayFixData")

---
function M:init(isReplay, data)
    self.isReplay = false
    self.data = {}
    self.data.players = {}
end

function M:setFixData(data)
    --local data = require("Battle.BattleData.FixData")
    data = data and Json.decode(data)
    if data then
        self.isReplay = true
        self.data = data
        for i, v in pairs(self.data.players) do
            v.index = 0
        end
    end
end


function M:isReplay()
    return self.isReplay
end

---@param player PlayerModel
function M:isDeadFix(player)
    local data = self:getPlayerData(player)
    if data then
        local frame = SceneManager.curScene:get_loopTimeNormal()
        if data.death and data.death <= frame then
            return true
        else   
            -- 被控制，没有死亡
            return false
        end
    end
    -- 不被控制
    return true
end

---@param player PlayerModel
function M:registerPlayer(player)
    if self.isReplay then
        return
    end
    local id = player:get_playerInstanceId()
    self.data.players[id] = {
        hp = {}, 
        death = nil,
    }
end

---@param player PlayerModel
function M:getPlayerData(player)
    local id = player:get_playerInstanceId()
    return id and  self.data.players[id]
end

---@param player PlayerModel
function M:fixPlayerInfo(frame, player)
    if self.isReplay then
        local data = self:getPlayerData(player)
        if player.plyType == "W_BeiMSZ" and frame > 39 then
            local x = 1
            x = x + 1
        end
        if data then
            local hpData = data.hp
            local fixHp = nil
            if #hpData > data.index then -- 有下面帧的数据
                if frame < hpData[data.index+1] then
                    fixHp = hpData[data.index]
                elseif frame == hpData[data.index+1] then
                    data.index = data.index + 2
                    fixHp = hpData[data.index]
                end
                fixHp = hpData[data.index]
            else
                fixHp = hpData[data.index]
            end
            if fixHp then
                local rhp = player.data:get_curHp()
                --if fixHp ~= rhp then
                --    Logger.logError(Json.encode({ frame, player:get_playerInstanceId(), fixHp, rhp}), "血量不相等======")
                --end
                player.data:set_curHp(fixHp)
            end
        end
    else
        --frame = SceneManager.curScene:get_loopTimeNormal()
        if frame % 1 ~= 0 then
            return
        end
        local data = self:getPlayerData(player)
        if data then
            data = data.hp
            local hp = player.data:get_curHp()
            if data[#data] ~= hp then
                data[#data + 1] = frame
                data[#data + 1] = hp
            end
        end
        --table.insert(data, player.data:get_curHp())
    end
end

---@param player PlayerModel
function M:fixDeadInfo(frame, player)
    if self.isReplay then
        local data = self:getPlayerData(player)
        if data then
            if not player:isDead() then
                if frame <= 900 and frame == data.death then
                    player:dead(nil, nil)
                end 
            end
        end
    else
        local data = self:getPlayerData(player)
        if data then
            if not data.death and player:isDead() then
                data.death = frame
            end
        end
    end
end

function M:getFormatData()
    --return table.serialize(self.data)
    return Json.encode(self.data)
end

return M