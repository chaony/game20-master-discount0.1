--属性偷取
---@class BufWorkSteal : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkSteal", BufWork_Model)

function M:initFinish()
    self.stealList = {}
    for k,v in ipairs(self.playerBuf.param) do
        local dataName,type,change = self:getValue(v)
        local curValue = self.playerBuf.player.data[dataName]:getValue()
        if type == 1 then
            self.playerBuf.player.data[dataName]:addToAddList( GlobalTools:Mul(-GlobalTools.base1, change))
        elseif type == 2 then
            self.playerBuf.player.data[dataName]:addToMulList( GlobalTools:Mul(-GlobalTools.base1,change))
        elseif type == 3 then
            self.playerBuf.player.data[dataName]:addToMAAList( GlobalTools:Mul(-GlobalTools.base1,change), "buff")
        end
        local stealValue = curValue - self.playerBuf.player.data[dataName]:getValue()
        self.stealList[dataName] = stealValue
        self.playerBuf.source.data[dataName]:addToExtraAddList(stealValue)
    end
end

function M:stop()
    M.super.work(self)
    for k,v in ipairs(self.playerBuf.param) do
        local dataName,type,change = self:getValue(v)

        if type == 1 then
            self.playerBuf.player.data[dataName]:removeFromAddList( GlobalTools:Mul(-GlobalTools.base1, change))
        elseif type == 2 then
            self.playerBuf.player.data[dataName]:removeFromMulList( GlobalTools:Mul(-GlobalTools.base1, change))
        elseif type == 3 then
            self.playerBuf.player.data[dataName]:removeFromMAAList( GlobalTools:Mul(-GlobalTools.base1, change), "buff")
        end
        
        self.playerBuf.source.data[dataName]:removeFromExtraAddList(self.stealList[dataName])
    end
    self.stealList = {}
end

function M:getValue(data)
    local key,type,value = nil,nil,nil
    for k,v in ipairs(data) do
        if v[1] == "heroEnum" then
            key = v[2]
        elseif v[1] == "dataCalType" then
            type = v[2]
        elseif v[1] == "param" then
            value = v[2]
        end
    end
    local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
    key = hero_enumeration[key].user_key
    return key,type,value
end

return M