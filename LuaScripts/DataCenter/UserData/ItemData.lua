------------ ItemData
local M = {
	m_items = {}
}

--[[--
    更新道具数据
]]
function M:updateMoreItemData(data)
    if data == nil then return end
    for k,v in pairs(data) do
        self.m_items[k] = v
    end
end

--[[--
    通过id表格移出道具数据
]]
function M:removeMoreItemDataById(ids)
    if ids == nil then return end
    for k,v in pairs(ids) do
        self.m_items[tostring(v)] = nil
    end
end

--[[--
   获得道具数据
]]
function M:getItemsData()
    return self.m_items
end

--[[
    获得道具的id列表
]]
function M:getItemsId()
    local ids = {}
    local items_data = self:getItemsData()
    for k,v in pairs(items_data) do
        table.insert(ids, k)
    end
    return ids
end

--[[
    获得道具的id列表
]]
function M:getItemsIdByFilterFunc(filter_func)
    local item = ConfigManager:getCfgByName("item")
    local ids = {}
    local items_data = self:getItemsData()
    for k,v in pairs(items_data) do
        local id = tonumber(k)
        local item_cfg = item[id]
        if item_cfg == nil then
            GameUtil:sendLuaError("getItemsIdByFilterFunc", "k = " .. k)
        else
            if filter_func(v, item_cfg) then
                table.insert(ids, k)
            end
        end
    end
    return ids
end

--[[
	获得道具数据
    TODO ：之后添加配置的读取
        "41101": {                              # 道具id
            "value": 0,                         # 值
            "num": 0,                           # 道具数量
        },
]]
function M:getItemDataById(id)
    id = tostring(id)
    local data = self.m_items[id] or {value = 0, num = 0}
    local item = ConfigManager:getCfgByName("item")
    local cfg = item[tonumber(id)]
    return data, cfg
end

function M:resetData()
    self.m_items = {}
end

--[[
    获得背包中的好感道具的id列表
]]
function M:getItemsBySubType(favorite_gift,h_lv)
    local ids = {}
    local h_lv = h_lv or 0
    local item = ConfigManager:getCfgByName("item")
    local items_data = self:getItemsData()
    if next(favorite_gift) == nil then
        return ids
    end
    for k,v in pairs(items_data) do
        local id = tonumber(k)
        local item_cfg = item[id]
        for kk,vv in pairs(favorite_gift) do
            if item_cfg and item_cfg.sub_type == vv then
                for e,f in pairs(item_cfg.effect) do
                    if h_lv == f[1] then
                        table.insert(ids, k)
                    end
                end
            end
        end
    end
    return ids
end

--[[
    获得配置中的好感道具的id列表
]]
function M:getItemsTabBySubType(favorite_gift,h_lv)
    local ids = {}
    local h_lv = h_lv or 0
    local item = ConfigManager:getCfgByName("item")
    if next(favorite_gift) == nil then
        return ids
    end
    for k,v in pairs(item) do
        for kk,vv in pairs(favorite_gift) do
            if v.sub_type == vv then
                for e,f in pairs(v.effect) do
                    if h_lv == f[1] then
                        table.insert(ids, k)
                    end
                end
            end
        end
    end
    return ids
end



return M