---@class PetFactorySendPopModel: OODataBase
local M = class("PetFactorySendPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_show_num = 4
    self.m_data = self.m_params
    self.m_curPos = self.m_data.pos
    self.m_temp_show = table.copy(self.m_data.excludeList)
    self.m_Pet_detail = ConfigManager:getCfgByName("pet_detail")
    self.m_all_pet_list = self:initAllPetIds()
    self.m_selected_oid = ""
end

---================================================================

--宠物列表
function M:initAllPetIds()
    local ids = table.copy(UserDataManager.pet_data:getPetsId())

    --[[排序规则:
        1. 宠物类型
        2. 代数
        3. 等级
        4. 战力
        5. id
    --]]
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = self:getPetDataById(id_one)
        local data2, cfg2 = self:getPetDataById(id_two)
        if cfg1.pet_type ~= cfg2.pet_type then
            return cfg1.pet_type < cfg2.pet_type
        elseif data1.evo ~= data2.evo then
            return data1.evo > data2.evo
        elseif data1.lv ~= data2.lv then
            return data1.lv > data2.lv
        elseif data1.combat ~= data2.combat then
            return data1.combat > data2.combat
        else
            return data1.oid > data2.oid
        end
    end
    table.sort(ids, sortFunc)
    return ids
end

function M:setExcludePetList(msgData)
    self.m_temp_show = msgData.pets
end

function M:getPetDataById(oid)
    local data, cfg = UserDataManager.pet_data:getPetDataById(oid)
    return data, cfg
end

function M:getList()
    local list = {}

    local allPetList = table.copy(self.m_all_pet_list)
    for _, petOid in ipairs(allPetList) do
        local isDispatch = false
        local curPos = 0
        for i, v in ipairs(self.m_temp_show) do
            if v.oid ~= nil and v.oid == petOid then
                isDispatch = true
                curPos = i
                break
            end
        end


        -- 已派遣的宠物需要设置为已选择
        local petData, _ = self:getPetDataById(petOid)

        -- 判断是否在孵化中
        local isHatch = false
        local curTime = UserDataManager:getServerTime()
        if petData.egg_ets and curTime < petData.egg_ets then 
            isHatch = true
        end
        
        -- 孵化中的宠物不出现在列表中
        if not isHatch then
            local data = {
                oid = petOid,
                id = petData.id,
                isSelect = isDispatch or self.m_selected_oid == petOid,
                pos = curPos,
                tempData = petData
            }
            table.insert(list, data) 
        end
    end

    table.sort(list, function(a, b)
        if a.tempData.evo == a.tempData.evo then
            return a.tempData.id < a.tempData.id
        else
            return a.tempData.evo > a.tempData.evo
        end
    end)
    return list
end

function M:setSelectID(oid)
    self.m_selected_oid = oid
end

function M:getViewPetByIndex(index)
    return self.m_temp_show[index]
end

return M