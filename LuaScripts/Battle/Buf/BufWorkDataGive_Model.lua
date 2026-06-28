---@class BufWorkDataGive : BufWork_Model @--属性改变 将source的属性给player
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkDataGive", BufWork_Model)

---@class BufWorkDataGive_AddData
---@field key string
---@field type number
---@field value number
---@field add number

function M:work()
    M.super.work(self)
    self:addData(self.playerBuf.param)
end

function M:stop()
    M.super.stop(self)
    self:removeData(self.playerBuf.param)
end

function M:getValue(data)
    local key,paramType,value = nil,nil,nil
    if type(data) == "table" then
        for k,v in ipairs(data) do
            if v[1] == "heroEnum" then
                key = v[2]
            elseif v[1] == "dataCalType" then
                paramType = v[2]
            elseif v[1] == "param" then
                value = v[2]
            end
        end
        local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
        key = hero_enumeration[key].user_key
    end
    return key,paramType,value
end

function M:addData(param)
    self.currentAdd = {}
    local source = self.playerBuf.source
    local player = self.playerBuf.player
    for k,v in pairs(param) do
        local key,type,value = self:getValue(v)
        ---@type PlayerDataItem
        local playerDataItem = player.data[key]
        ---@type PlayerDataItem
        local sourceDataItem = source.data[key]

        if sourceDataItem ~= nil and playerDataItem ~= nil then
            local hpRate = player.data:get_hpRate();
            local addValue = GlobalTools:Mul(sourceDataItem:getValue(), value)
            if type == 1 then
                playerDataItem:addToAddList(addValue)
            elseif type == 2 then
                playerDataItem:addToMulList(addValue)
            elseif type == 3 then
                playerDataItem:addToMAAList(addValue, "skill")
            elseif type == 4 then
                playerDataItem:addToMAAList(addValue, tostring(self.playerBuf.groupId))
            end
            table.insert(self.currentAdd, {key = key, type = type, value = value, add = addValue})

            -- 最大生命变化时，需要同步更新当前血量保持相同的血量百分比
            if key == "hp" then
                self:updatePlayerCurHp(hpRate)
            end
        end
    end
end

function M:removeData(param)
    local player = self.playerBuf.player
    ---@param lastAdd BufWorkDataGive_AddData
    for i, lastAdd in ipairs(self.currentAdd) do
        ---@type PlayerDataItem
        local playerDataItem = player.data[lastAdd.key]
        if playerDataItem ~= nil then
            local hpRate = player.data:get_hpRate();
            if lastAdd.type == 1 then
                playerDataItem:removeFromAddList(lastAdd.add)
            elseif lastAdd.type == 2 then
                playerDataItem:removeFromMulList(lastAdd.add)
            elseif lastAdd.type == 3 then
                playerDataItem:removeFromMAAList(lastAdd.add, "skill")
            elseif lastAdd.type == 4 then
                playerDataItem:removeFromMAAList(lastAdd.add, tostring(self.playerBuf.groupId))
            end

            -- 最大生命变化时，需要同步更新当前血量保持相同的血量百分比
            if lastAdd.key == "hp" then
                self:updatePlayerCurHp(hpRate)
            end
        end
    end
end

function M:updatePlayerCurHp(lastHpRate)
    local playerData = self.playerBuf.player.data
    local hp_rate_value = GlobalTools:Mul(playerData:get_hp(), lastHpRate)
    if hp_rate_value <= 0 then
        hp_rate_value = GlobalTools.base1
    end
    playerData:set_curHp(hp_rate_value)
    self.playerBuf.player.data:maxHpChanged()
end

function M:upgrade(param)
    self:removeData(self.playerBuf.param)
    self:addData(param)
end

return M