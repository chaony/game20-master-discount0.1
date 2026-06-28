---@class PetShowSetModel: OODataBase
local M = class("PetShowSetModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_show_num = 4
    self.m_data = self.m_params
    self.m_temp_show = table.copy(self.m_data.pet_view)
    self.m_Pet_detail = ConfigManager:getCfgByName("pet_detail")
end

function M:getList()
    local list = {}
    if self.m_Pet_detail then
        for k,m in pairs(self.m_Pet_detail) do
            local oids = UserDataManager.pet_data:getPetIdsByCid(k)
            if next(oids) ~= nil then
                local oid = nil
                local combat = 0
                for i,v in ipairs(oids) do
                    local pet = UserDataManager.pet_data:getPetDataById(v)
                    if not pet.egg_ets then
                        if combat < pet.combat then
                            oid = v
                            combat = pet.combat
                        end
                    end
                end
                if oid then
                    local is_view = false
                    for i,v in pairs(self.m_temp_show) do
                        if v ~= "" then
                            local pet = UserDataManager.pet_data:getPetDataById(v)
                            if pet and k == pet.id then
                                is_view = true
                                break
                            end
                        end
                    end
                    table.insert(list, { id = k, oid = oid, is_view = is_view })
                end
            end
        end
    end
    
    table.sort(list, function(a, b) 
        local pet_a = UserDataManager.pet_data:getPetDataById(a.oid)
        local pet_b = UserDataManager.pet_data:getPetDataById(b.oid)
        if pet_a.evo == pet_b.evo then
            return pet_a.id < pet_b.id
        else
            return pet_a.evo > pet_b.evo
        end
    end)
    return list
end

function M:getViewPetByIndex(index)
    return self.m_temp_show[index]
end

function M:setShow(data)
    for k,v in pairs(self.m_temp_show) do
        if v ~= "" then
            local pet, cfg = UserDataManager.pet_data:getPetDataById(v)
            if pet and pet.id == data.id then
                self.m_temp_show[k] = nil
                return 1
            end
        end
    end

    for i=1, self.m_show_num do
        local oid = self:getViewPetByIndex(i)
        if oid == nil or oid == "" then
            self.m_temp_show[i] = data.oid
            return 1
        end
    end
    return 0
end

function M:checkNeedSetData()
    for i=1, self.m_show_num do
        if self.m_data.pet_view[i] ~= self.m_temp_show[i] then
            return true
        end
    end
end

function M:getPetSetData()
    local data = {}
    for i=1,4 do
        data[i] = self.m_temp_show[i] or ""
    end
    return data
end

function M:setDownPet(index)
    self.m_temp_show[index] = nil
end

return M