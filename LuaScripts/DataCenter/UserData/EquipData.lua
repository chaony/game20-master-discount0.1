------------ EquipData
local M = {
	m_equips = {},
    m_ids = {},--装备id对应表
    m_type_name = "default",-- 排序类型
}

--[[--
    更新装备数据
]]
function M:updateMoreEquipData(data)
    if data == nil then return end
    for k,v in pairs(data) do
        self:updateOneEquipData(v)
    end
    self:equipsSortByTypeName()
end

--[[--
    更新单个装备数据
]]
function M:updateOneEquipData(data)
    if data == nil then return end
    local oid = tostring(data.oid)
    if self.m_equips[oid] == nil then
        self.m_ids[#self.m_ids + 1] = oid
    end
    self.m_equips[oid] = data
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
function M:removeOneEquipDataById(oid)
    oid = tostring(oid)
    local removeIndex = nil
    for k,v in pairs(self.m_ids) do
        if v == oid then
            removeIndex = k
            break
        end
    end
    if removeIndex ~= nil then
        table.remove(self.m_ids,removeIndex)
        self.m_equips[oid] = nil
    end
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
    获取equips数据
]]
function M:getEquipsData()
    return self.m_equips
end

--[[--
    通过id获得equip数据
    TODO ：之后添加配置的读取
]]
function M:getEquipDataById(oid)
    oid = tostring(oid)
    local data = self.m_equips[oid]
    local cfg = nil
    if data then
        cfg = self:getEquipConfigByCid(data.id)
    end
    return data, cfg
end

--[[
    通过配置id获得装备配置
]]
function M:getEquipConfigByCid(cid)
    local equip_detail = ConfigManager:getCfgByName("equip_detail")
    return equip_detail[cid]
end


--[[
    通过配置id获得装备配置
]]
function M:getEquipGoodsConfigByCid(cid)
    local equip_detail = ConfigManager:getCfgByName("equip_goods")
    return equip_detail[cid]
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
    self.m_equips = {}
    self.m_ids = {}--装备id对应表
end

function M:getEquipNumByCid(cid)
    local num = 0 
    for k,v in pairs(self.m_equips) do
        if v.id == cid then
            num = num + 1
        end
    end
    return num
end


return M