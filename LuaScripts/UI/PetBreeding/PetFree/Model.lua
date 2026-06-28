---@class PetFreeModel: OODataBase
local M = class("PetFreeModel", LikeOO.OODataBase)


function M:onCreate()
    M.super.onCreate(self)
    self:getData("")
end

function M:onEnter()
    local select_oid = self.m_params.pet_oid
    self.m_is_allSelect = false
    self.m_select_sift = 1
    self:InitData()
    if table.indexof(self.m_pets, select_oid) then
        self.index_oid = select_oid
    end
    self:resetFreePets()
    self.m_pet_change = false
end

function M:checkTips()
    local is_tips = false
    local tips_text = ""
    local tips_args = ""
    local evo_cfg = ConfigManager:getCfgByName("pet_evolution")
    local common_cfg = ConfigManager:getCfgByName("common")
    local max_quality = 1
    local max_evo = 1
    for k,v in ipairs(self.m_free_pets) do
        local data, cfg = UserDataManager.pet_data:getPetDataById(v)
        local quality = GameUtil:getPetQualityByData(data)
        if quality > max_quality then
            max_quality = quality
        end
        if data.evo > max_evo then
            max_evo = data.evo
        end
    end
    --同时满足条件优先提示品质
    if evo_cfg[max_evo].tips == 1 then
        if max_evo == 4 then
            tips_args = Language:getTextByKey("pet_evo_lv_0050")
            tips_text = Language:getTextByKey("pet_evo_lv_0049", tips_args)
        elseif max_evo == 5 then
            tips_args = Language:getTextByKey("pet_evo_lv_0051")
            tips_text = Language:getTextByKey("pet_evo_lv_0049", tips_args)
        end
        is_tips = true
    end
    if max_quality >= tonumber(common_cfg[754].value)  then
        if max_quality == 3 then
            tips_args = Language:getTextByKey("pet_evo_lv_0046")
            tips_text = Language:getTextByKey("pet_evo_lv_0042", tips_args)
        elseif max_quality == 4 then
            tips_args = Language:getTextByKey("pet_evo_lv_0047")
            tips_text = Language:getTextByKey("pet_evo_lv_0042", tips_args)
        elseif max_quality == 5 then
            tips_args = Language:getTextByKey("pet_evo_lv_0052")
            tips_text = Language:getTextByKey("pet_evo_lv_0042", tips_args)
        end
        is_tips = true
    end
    return is_tips, tips_text
end

function M:getAllSelectState()
    return self.m_is_allSelect
end

function M:setAllSelectState()
    if self.m_is_allSelect then
        self.m_is_allSelect = false
        self:cancelAll()
    else
        self.m_is_allSelect = true
        self:selectAll()
    end
end

function M:resetFreePets()
    self.m_free_pets = {}
    if self.index_oid then
        table.insert(self.m_free_pets, self.index_oid)
    end
end

function M:InitData()
    self.m_is_allSelect = false
	self.m_pets = table.copy(UserDataManager.pet_data:getPetsId())
    local sel_quality = self.m_select_sift - 1
    for i=#self.m_pets, 1 ,-1 do
        local oid = self.m_pets[i]
        local data = UserDataManager.pet_data:getPetDataById(oid)
        if data.lock then
            table.remove(self.m_pets, i)
        elseif data.egg_ets then
            table.remove(self.m_pets, i)
        elseif sel_quality > 0 and GameUtil:getPetQualityByData(data) ~= sel_quality then
            table.remove(self.m_pets, i)
        end
    end
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = UserDataManager.pet_data:getPetDataById(id_one)
        local data2, cfg2 =  UserDataManager.pet_data:getPetDataById(id_two)
        local cid1, cid2 = data1.id, data2.id
        local lv1, lv2 = data1.lv, data2.lv
        local egg1 = data1.egg_ets and 1 or 0
        local egg2 = data2.egg_ets and 1 or 0
        if egg1 == egg2 then
            if data1.evo == data2.evo then
                if lv1 == lv2 then
                    return cid1 > cid2
                else
                    return lv1 < lv2
                end
            else
                return data1.evo < data2.evo
            end
            
        else
            return egg1 < egg2
        end
    end
    table.sort(self.m_pets, sortFunc)
    if next(self.m_pets) ~= nil then
        self.index_oid = self.m_pets[1]
    else
        self.index_oid = 0
    end
end

function M:getReturnCons()
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
    local pet_pet_upgrade = ConfigManager:getCfgByName("pet_upgrade")
    local cons_data = {}
    if self.index_oid == 0 then
        return cons_data
    end
    for k,v in pairs(self.m_free_pets) do
        local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(v)
        if pet_data == nil then
            Logger.logError("归林报错-------"..self.index_oid)
            return
        end
        local evo_cfg = pet_evolution[pet_data.evo]
        local upgrade_cfg = pet_pet_upgrade[pet_data.lv]
        
        self:mergeCons(cons_data, evo_cfg.disband)
      
        if upgrade_cfg.disband_exp > 0 then
            self:mergeCons(cons_data, {{162,0,upgrade_cfg.disband_exp}})
        end
        if upgrade_cfg.disband_gold > 0 then
            self:mergeCons(cons_data, {{104,0,upgrade_cfg.disband_gold}})
        end
    end
    
    return cons_data
end

function M:mergeCons(base_reward, add_reward)
    local money_guide = ConfigManager:getCfgByName("money_guide")
    for k,v in pairs(add_reward) do
        local is_new = true
        local info = money_guide[v[1]] or {}
        for i,vv in pairs(base_reward) do
            if v[1] == vv[1] then
                if info.itype == 1 then
                    vv[3] = vv[3] + v[3]
                    is_new = false
                elseif v[2] == v[2] then
                    vv[3] = vv[3] + v[3]
                    is_new = false
                end
            end
        end
        if is_new then
            table.insert(base_reward, table.copy(v))
        end
    end
end

function M:getEggEndTime(oid)
    if self:checkIsEgg(oid) then
        local data, cfg = UserDataManager.pet_data:getPetDataById(oid)
        return data.egg_ets
    end
    return 0
end

function M:getEggIcon(oid)
    local data, cfg = UserDataManager.pet_data:getPetDataById(oid)
    self.m_evolutionCfg = ConfigManager:getCfgByName("pet_evolution")
    if self.m_evolutionCfg[data.evo] then
        return  self.m_evolutionCfg[data.evo].egg_pic
    end
end

function M:checkIsEgg(oid)
    local data, cfg = UserDataManager.pet_data:getPetDataById(oid)
    if data and data.egg_ets then
        return true
    end
    return false
end

function M:selectHandle(oid)
    local has = false
    for k,v in pairs(self.m_free_pets) do
        if v == oid then
            table.remove(self.m_free_pets, k)
            has = true
            break
        end
    end
    if has == false then
        table.insert(self.m_free_pets, oid)
    end
    self.index_oid = self.m_free_pets[1] or 0
end

function M:selectAll()
    table.merge(self.m_free_pets, self.m_pets)
    if self.index_oid == 0 and next(self.m_pets) ~= nil then
        self.index_oid = self.m_pets[1]
    end
end

function M:cancelAll()
    self.m_free_pets = {}
    self.index_oid = 0
end

function M:getInitIndex()
    local index = table.indexof(self.m_pets, self.index_oid)
    if index then
        return index
    else
        return 0
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M