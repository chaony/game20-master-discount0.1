--阻止属性改变
---@class BufWorkNoEnumChange : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkNoEnumChange", BufWork_Model)

function M:work()
    M.super.work(self)
    self:addData(self.playerBuf.param)
end

function M:stop()
    M.super.stop(self)
    self:removeData(self.playerBuf.param)
end


function M:addData( param )
    local key,paramType = self:getValue(param)
    if key ~= nil then
        if key == "rage" then
            self.playerBuf.player.data:setAngerLockReduce(true);
        else
            local dataItem = self.playerBuf.player.data[key]
            if dataItem ~= nil then
                dataItem:setProtectedState(paramType);
            end
        end
    end
end


function M:removeData(param)
    local key,paramType = self:getValue(param)
    if key ~= nil then
        local dataItem = self.playerBuf.player.data[key]
        if dataItem ~= nil then
            dataItem:setProtectedState(-1);
        end
    end
    self.playerBuf.player.data:setAngerLockReduce(false);
end


function M:getValue(data)
    local key,paramType = nil,nil
    if type(data) == "table" then
        for k,v in ipairs(data) do
            for k_1,v_1 in ipairs(v) do
                if v_1[1] == "enum" then
                    key = v_1[2]
                elseif v_1[1] == "caltype" then
                    paramType = v_1[2]
                end
            end
        end
       
        if key ~= nil then
            local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
            local hero_enum_item = hero_enumeration[key]
            if hero_enum_item ~= nil then
                key = hero_enum_item.user_key;
            else
                Logger.logError(" 英雄属性没有找到 "..key )
            end
        else
            Logger.logError(" key 没有找到" )
        end
    end
    return key,paramType
end


return M