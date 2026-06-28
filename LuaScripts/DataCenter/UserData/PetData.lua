------------ PetData 宠物
local M = {
	m_pets = {},
    m_ids = {},--id对应表
    m_type_name = "default",-- 排序类型
    new_pet_ids = {}, --首次获得
    pet_collect = {}, --图鉴解锁记录
    pet_factory = {}, --宠物工坊派遣记录 
}

--[[--
    更新宠物数据
]]
function M:updatePetData(data)
    if data == nil then return end
    for k,v in pairs(data) do
        self:updateOnePetData(v)
    end
    self:PetSortByTypeName()
end

--[[--
    更新单个宠物数据
]]
function M:updateOnePetData(data)
    if data == nil then return end
    local oid = tostring(data.oid)
    if self.m_pets[oid] == nil then
        self.m_ids[#self.m_ids + 1] = oid
    end
    self.m_pets[oid] = data
end

--[[--
    通过id表格移出宠物数据
]]
function M:removeMorePetDataById(ids)
    if ids == nil then return end
    for k,v in pairs(ids) do
        self:removeOnePetDataById(v)
    end
end

--[[--
    通过id移除宠物数据
]]
function M:removeOnePetDataById(oid)
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
        self.m_pets[oid] = nil
    end
end

--[[
    宠物排序
]]
function M:PetSortByTypeName(type_name)
    self.m_type_name = type_name or self.m_type_name
    self:equipIdsSort(self.m_ids, self.m_type_name)
end

--[[
    宠物排序
]]
function M:equipIdsSort(ids, type_name)
    ids = ids or {}
    type_name = type_name or "default";
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = self:getPetDataById(id_one)
        local data2, cfg2 = self:getPetDataById(id_two)
        local cid1, cid2 = data1.id, data2.id
        local lv1, lv2 = data1.lv, data2.lv
        if type_name == "default" then                           -- 默认排序
            if lv1 == lv2 then
                return cid1 > cid2
            else
                return lv1 > lv2
            end
        else
            return cid1 > cid2
        end
    end
    table.sort(ids, sortFunc)
end

--[[
    获取宠物id列表
]]
function M:getPetsId()
    return self.m_ids
end

--[[--
    获得宠物的数量
]]
function M:getPetsCount()
    return #self.m_ids
end

--[[--
    获取宠物数据
]]
function M:getPetsData()
    return self.m_pets
end

--[[--
    通过id获得宠物数据
]]
function M:getPetDataById(oid)
    oid = tostring(oid)
    local data = self.m_pets[oid]
    local cfg = nil
    if data then
        cfg = self:getPetConfigByCid(data.id)
    end
    return data, cfg
end

--[[
    通过配置id获得宠物配置
]]
function M:getPetConfigByCid(cid)
    cid = tonumber(cid)
    local Pet_detail = ConfigManager:getCfgByName("pet_detail")
    return Pet_detail[cid]
end

-----宠物工坊相关--------------------------------------------------------------------

function M:updatePetFactoryData(data) 
    if data == nil then 
        self.pet_factory = {}
        return
    end
    
    self.pet_factory = data
end

function M:checkPetDispatch() 
    local res = false
    for i, v in pairs(self.pet_factory) do
        if v ~= "" then 
            res = true
        end
    end
    
    return res
end

-----图鉴相关-----------------------------------------------------------------------------------------------------------------------------

function M:updateCollectPetData(data)
    if data == nil then return end
    self.pet_collect = data
end

function M:updateMorePetCollect(data)
    if data == nil then
        return
    end
    for k, v in pairs(data) do
        local cid = tostring(k)
        if self.pet_collect[cid] == nil then
            self.new_pet_ids[#self.new_pet_ids + 1] = tonumber(cid)
        end
        self.pet_collect[cid] = v
    end
end

--[[--
    通过id移除英雄数据
]]
function M:removePetDataById(oid)
    oid = tostring(oid)
    local removeIndex = nil
    for k, v in pairs(self.pet_collect) do
        if v == oid then
            removeIndex = k
            break
        end
    end
    if removeIndex ~= nil then
        table.remove(self.pet_collect, removeIndex)
        -- self.m_ids[oid] = nil
        self.pet_collect[oid] = nil
    end
end

function M:cleanNewHero()
    self.new_pet_ids = {}
end

function M:isNewHero(cid)
    for i, v in ipairs(self.new_pet_ids) do
        if v == tonumber(cid) then
            return true
        end
    end
    return false
end

function M:removeNewHero(cid)
    for i, v in ipairs(self.new_pet_ids) do
        if v == tonumber(cid) then
            table.remove(self.new_pet_ids, i)
            return
        end
    end
end


-- 获取同id的宠物
function M:getPetIdsByCid(cid)
    local pet_ids = {}
    for k, v in pairs(self.m_pets) do
        if v.id == cid then
            table.insert(pet_ids, k)
        end
    end
    return pet_ids
end

function M:getPetPrefebByOid(oid)
    local data = self:getPetDataById(oid)
    if data then
        return self:getPetPrefebByCid(data.id)
    end
end

function M:getPetPrefebByCid(cid)
    local cfg = self:getPetConfigByCid(cid)
    return cid, cfg.prefab
end

return M