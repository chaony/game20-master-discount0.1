--属性改变
---@class BufWorkData : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkData", BufWork_Model)

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
        if hero_enumeration[key] == nil then
            Logger.logError(self.playerBuf.id.." key 不存在 "..key )
        end
        key = hero_enumeration[key].user_key
    end
    return key,paramType,value
end

function M:addData(param)
    for k,v in pairs(param) do
        local key,type,value = self:getValue(v)
        if self.playerBuf.player.data[key] ~= nil then
            local hpRate = self.playerBuf.player.data:get_hpRate();
            if type == 1 then
                self.playerBuf.player.data[key]:addToAddList(value)
            elseif type == 2 then
                self.playerBuf.player.data[key]:addToMulList(value)
            elseif type == 3 then
                self.playerBuf.player.data[key]:addToMAAList(value, "skill")
            elseif type == 4 then
                self.playerBuf.player.data[key]:addToMAAList(value, tostring(self.playerBuf.groupId))
            end
            if key == "hp" then
                local hp_rate_value = GlobalTools:Mul( self.playerBuf.player.data:get_hp(), hpRate)
                if hp_rate_value <= 0 then
                    hp_rate_value = GlobalTools.base1
                end
                self.playerBuf.player.data:set_curHp( hp_rate_value )
                self.playerBuf.player.data:maxHpChanged()
            end
        end
    end
end

function M:removeData(param)
    for k,v in pairs(param) do
        local key,type,value = self:getValue(v)
        if self.playerBuf.player ~= nil then
            if self.playerBuf.player.data[key] ~= nil then
                local hpRate = self.playerBuf.player.data:get_hpRate();
                if type == 1 then
                    self.playerBuf.player.data[key]:removeFromAddList(value)
                elseif type == 2 then
                    self.playerBuf.player.data[key]:removeFromMulList(value)
                elseif type == 3 then
                    self.playerBuf.player.data[key]:removeFromMAAList(value, "skill")
                elseif type == 4 then
                    self.playerBuf.player.data[key]:removeFromMAAList(value, tostring(self.playerBuf.groupId))
                end
                if key == "hp" then
                    local hp_rate_value = GlobalTools:Mul( self.playerBuf.player.data:get_hp(), hpRate)
                    if hp_rate_value <= 0 then
                        hp_rate_value = GlobalTools.base1
                    end
                    self.playerBuf.player.data:set_curHp( hp_rate_value )
                    self.playerBuf.player.data:maxHpChanged()
                end
            end
        end
    end
end

function M:upgrade(param)
    self:removeData(self.playerBuf.param)
    self:addData(param)
end

return M