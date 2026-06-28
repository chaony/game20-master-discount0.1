------------ EquipData
local M = {
	m_talis = {},
    m_ids = {},--装备id对应表
    m_type_name = "default",-- 排序类型
}

--[[--
    更新装备数据
]]
function M:updateMoreTalisData(data)
    if data == nil then return end
    --self.m_talis= {}
    for k,v in pairs(data) do
        self:updateOneTalisData(k,v)
    end
    table.sort(self.m_talis,function(a,b)
        return a.id > b.id  
    end)
    --self:equipsSortByTypeName()
    local aa = 1
end

--[[--
    更新单个装备数据
]]
function M:updateOneTalisData(id,data)
    if data == nil then return end
    local reward = {170,tonumber(id),tonumber(data.num)}
    local ptem= {}
    ptem.reward = reward
    ptem.id = tonumber(id)
    ptem.number = tonumber(data.num)
    --for i,v in ipairs(self.m_ids) do 
    --    if v == tonumber(id) then 
    --        
    --    end
    --end
    --if self.m_talis[id] == nil then
    --    self.m_ids[#self.m_ids + 1] = id
    --end
    --table.insert(self.m_talis,ptem)
    local flag = false
    for i,v in ipairs(self.m_talis) do 
        if v.id == tonumber(id) then
            self.m_talis[i] = ptem
            flag = true
        end
    end
    if flag == false then
        self.m_talis[#self.m_talis + 1] = ptem
    end
end

--[[--
    通过id表格移出装备数据
]]
function M:removeMoreEquipDataById(ids)
    if ids == nil then return end
    for k,v in pairs(ids) do
        self:removeOneEquipDataById(v)
    end
end

--[[--
    通过id移除装备数据
]]
function M:removeOneEquipDataById(id)
    id = tonumber(id)
    --local removeIndex = nil
    --for k,v in pairs(self.m_ids) do
    --    if v == oid then
    --        removeIndex = k
    --        break
    --    end
    --end
    for i,v in ipairs(self.m_talis) do
        if v.id == tonumber(id) then
            table.remove(self.m_talis,i)
        end
    end
    --if removeIndex ~= nil then
    --    table.remove(self.m_ids,removeIndex)
    --    table.remove(self.m_talis,removeIndex)
    --    self.m_talis[removeIndex] = nil
    --end
end

--[[
    装备排序
]]
function M:equipsSortByTypeName(type_name)
    self.m_type_name = type_name or self.m_type_name
    self:equipIdsSort(self.m_ids, self.m_type_name)
end

--[[
    装备排序
]]
function M:equipIdsSort(ids, type_name)
    ids = ids or {}
    type_name = type_name or "default";
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = self:getEquipDataById(id_one)
        local data2, cfg2 = self:getEquipDataById(id_two)
        local cid1, cid2 = data1.id, data2.id
        local lv1, lv2 = data1.lv, data2.lv
        local quality1, quality2 = cfg1.quality, cfg2.quality
        if type_name == "default" then                           -- 默认排序
            if quality1 == quality2 then
                if lv1 == lv2 then
                    return cid1 > cid2
                else
                    return lv1 > lv2
                end
            else
                return quality1 > quality2
            end
        else
            return cid1 > cid2
        end
    end
    table.sort(ids, sortFunc)
end

--[[
    获取装备列表
]]
function M:getEquipsId()
    return self.m_ids
end

--[[--
    获得装备的数量
]]
function M:getEquipsCount()
    return #self.m_ids
end

--[[--
    获取talins数据
]]
function M:getTalisData()
    return self.m_talis
end

--[[--
    通过id获得equip数据
    TODO ：之后添加配置的读取
]]
function M:getTalisDataById(oid)
    local data = nil
    for i,v in ipairs(self.m_talis) do
        if v.id == tonumber(oid) then
            data = v
        end
    end
    local cfg = nil
    if data then
        cfg = self:getTalisSuitConfigByCid(data.id)
    end
    return data, cfg
end

--[[
    通过配置id获得符篆基础配置
]]
function M:getTalisSuitConfigByCid(cid)
    local talins_detail = ConfigManager:getCfgByName("seal_character_suit") 
    return talins_detail and talins_detail[cid] or {} 
end


--[[
    通过配置id获得符篆配置
]]
function M:getTalisConfigByCid(cid)
    local talins_detail = ConfigManager:getCfgByName("seal_character")
    return talins_detail and talins_detail[cid] or {}
end

--[[
    通过 品阶 属性id 位置   获得符篆配置
]]
function M:getTalisConfigLimitByMember(quaily_id,id,pos)
    local currentValue = 0
    local AllValue = 1
    local cfg = ConfigManager:getCfgByName("seal_character")
    if cfg then
        local qusliyData = cfg[quaily_id]
        if qusliyData then
            local posData = qusliyData[pos]
            currentValue =posData[id][1] or 0
            AllValue =posData[id][2] or 0
            return currentValue,AllValue
        end
    end
    return 0,0
end

--[[
    获得装备的id列表
]]
function M:getEquipsIdByFilterFunc(filter_func)
    local ids = {}
    for k,v in pairs(self.m_ids) do
        local data, cfg = self:getEquipDataById(v)
        if filter_func(data, cfg) then
            table.insert(ids, v)
        end
    end
    return ids
end

function M:resetData()
    self.m_talis = {}
    self.m_ids = {}--装备id对应表
end

function M:getEquipNumByCid(cid)
    local num = 0 
    for k,v in pairs(self.m_talis) do
        if v.id == cid then
            num = num + 1
        end
    end
    return num
end


return M