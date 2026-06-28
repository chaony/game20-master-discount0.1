---@class PetEvolvePopModel: OODataBase
local M = class("PetEvolvePopModel", LikeOO.OODataBase)

local tab_exp = { RewardUtil.REWARD_TYPE_KEYS.PET_EXP, 0, 0 } --经验
local tab_money = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } --金币

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_slot = {} -- 进化选中槽位
	self.lock_skill = {}
	self.m_comprehead_id = "" -- 领悟选中槽位
	self.m_type = self.m_params.type --进化 or 领悟
	local select_oid = self.m_params.pet_oid
	local material_oid = self.m_params.material_oid
	if select_oid then
		self.m_slot[1] = select_oid
		self.m_comprehead_id = select_oid
	end
	if material_oid and material_oid ~= 0 and material_oid ~= "" then
		self.m_slot[2] = material_oid
	end
	self.m_select_evo1 = 0-- 筛选代数-进化
	self.m_select_evo2 = 0-- 筛选代数-领悟
	self:InitData()
	--if next(self.m_evo_lv_pets) ~= nil and select_oid == nil then
	--	self.m_slot[1] = self.m_evo_lv_pets[1]
	--end
	--if next(self.m_evo_lv_pets) ~= nil and select_oid == nil then
	--	self.m_comprehead_id = self.m_evo_lv_pets[1]
	--end
	self.m_upgradeCfg = ConfigManager:getCfgByName("pet_upgrade")
	self.pet_material_lv_up_list = {}	--等级不够置可升级列表
	self.pet_material_no_res_list = {}	--等级不够资源不足升级列表
end

function M:InitData()
	self.m_pets = UserDataManager.pet_data:getPetsId()
	self.m_evo_lv_pets = {} --可进化的宠物
	for k,v in pairs(self.m_pets) do
		local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(v)
		if pet_cfg.max_evolution > pet_hero.evo then
			local min_lv = self:getMinLvByEvo(pet_hero.evo)
			if pet_hero.lv >= min_lv then
				table.insert(self.m_evo_lv_pets, v)
			end
		end
	end
	self.m_comprehead_ids = table.copy(self.m_evo_lv_pets) --领悟列表
	self:getSoltByComprehead(self.m_comprehead_ids) -- 排序
end

function M:refreshData()
	self:InitData()
	if next(self.m_evo_lv_pets) ~= nil then
		self.m_slot[1] = self.m_evo_lv_pets[1]
	else
		self.m_slot[1] = ""
	end
	if next(self.m_evo_lv_pets) ~= nil then
		self.m_comprehead_id = self.m_evo_lv_pets[1]
	else
		self.m_comprehead_id = ""
	end
end

function M:refreshFilterEvolvList()
	if self.m_slot[1] and self.m_slot[1] ~= "" and self.m_slot[1] ~= 0 and self.m_select_evo1 > 0 then
		local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_slot[1])
		if pet_hero.evo ~= self.m_select_evo1  then
			self.m_slot[1] = ""
		end
	end
	if self.m_slot[2] and self.m_slot[2] ~= "" and self.m_slot[2] ~= 0 and self.m_select_evo1 > 0 then
		local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_slot[2])
		if pet_hero.evo ~= self.m_select_evo1  then
			self.m_slot[2] = ""
		end
	end
end

function M:refreshFilterCompreheadList()
	if self.m_comprehead_id and self.m_comprehead_id ~= "" and self.m_select_evo2 > 0 then
		local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_comprehead_id)
		if pet_hero.evo ~= self.m_select_evo2 then
			self.m_comprehead_id = ""
		end
	end
end

function M:checkInSlot(oid)
	for k,v in pairs(self.m_slot) do
		if oid == v then
			return true
		end
	end
	return false
end

function M:removeSlot(oid)
	for k,v in pairs(self.m_slot) do
		if v == oid then
			self.m_slot[k] = ""
			if k == 1 then
				self.m_slot[2] = ""
			end
			break
		end
	end
end

function M:addSlot(oid)
	if self.m_slot[1] == nil or self.m_slot[1] == "" or self.m_slot[1] == 0 then
		self.m_slot[1] = oid
		return
	end
	if self.m_slot[2] == nil or self.m_slot[2] == "" or self.m_slot[1] == 0 then
		self.m_slot[2] = oid
		return
	end
end


function M:checkInCompSlot(oid)
	if self.m_comprehead_id == oid then
		return true
	end
	return false
end

function M:removeCompSlot(oid)
	self.m_comprehead_id = ""
end

function M:addCompSlot(oid)
	self.m_comprehead_id = oid
end

--进化下一阶段展示的宠物
function M:getEvolvPet()
	if next(self.m_slot) == nil then
		return 0
	end
	if self.m_slot[1] and self.m_slot[1]~= "" and self.m_slot[1] ~= 0 and self.m_slot[2] and self.m_slot[2]~= "" and self.m_slot[2]~= 0 then
		return 2
	end
	return 0
end


function M:getMinLvByEvo(evo)
    local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	if pet_evolution[evo] then
		return pet_evolution[evo].min_condition or 5
	end
	return 0
end

function M:getEvoCfg()
	if self.m_slot[1] == nil or self.m_slot[1] == "" or self.m_slot[1] == 0 then
		return nil
	end
	local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_slot[1])
	local evo = pet_hero.evo
    local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	if pet_evolution[evo] and pet_evolution[evo+1] then
		return pet_evolution[evo],pet_evolution[evo+1]
	elseif pet_evolution[evo] then
		return pet_evolution[evo]
	end
	return nil
end

--进化材料列表
function M:refreshEvolvMaterialList()
	self.pet_material_list = {}
	self.pet_material_lv_up_list = {}	--等级不够置可升级列表
	self.pet_material_no_res_list = {}	--等级不够资源不足升级列表
	if self.m_slot[1] == nil or self.m_slot[1] == "" or self.m_slot[1] == 0 then
		return nil
	end
	local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_slot[1])
	local c_evo = pet_hero.evo
	self.m_evo_min_lv = self:getMaterialEvo(c_evo)
	table.insert(self.pet_material_list, self.m_slot[1])
	for k,v in pairs(self.m_pets) do
		if v ~= self.m_slot[1]  then
			local pet_data2, pet_cfg2 = UserDataManager.pet_data:getPetDataById(v)
			if  c_evo == pet_data2.evo and pet_cfg.pet_type == pet_cfg2.pet_type and not pet_data2.egg_ets then
				table.insert(self.pet_material_list, v)
				if pet_data2.lv < self.m_evo_min_lv then
					local is_enough, shortage_index, need_exp, need_coin = self:checkLvResource(pet_data2.lv, self.m_evo_min_lv)
					if is_enough then
						table.insert(self.pet_material_lv_up_list, {oid = v, need_exp = need_exp, need_coin = need_coin })
					else
						table.insert(self.pet_material_no_res_list, {oid = v, shortage_index = shortage_index})
					end
					
				end
			end
		end
	end
end

	
function M:getEvoMinLv()
	return self.m_evo_min_lv
end

function M:checkIsInNoResList(oid)
	for k,v in ipairs(self.pet_material_no_res_list) do
		if v.oid == oid then
			return true
		end
	end
	return false
end

function M:checkIsInLvList(oid)
	for k,v in ipairs(self.pet_material_lv_up_list) do
		if v.oid == oid then
			return true
		end
	end
	return false
end

function M:checkIsHasLvList()
	if #self.pet_material_lv_up_list > 0 or #self.pet_material_no_res_list > 0 then
		return true
	end
	return false
end

function M:getNeedResourceNum(oid)
	for k,v in ipairs(self.pet_material_lv_up_list) do
		if v.oid == oid then
			return v.need_exp, v.need_coin
		end
	end
	return false
end

function M:getShortageIndex(oid)
	for k,v in ipairs(self.pet_material_no_res_list) do
		if v.oid == oid then
			return v.shortage_index
		end
	end
	return 0
end

--检测资源
function M:checkLvResource(cur_lv, min_evo_lv)
	self.data_exp = RewardUtil:getProcessRewardData(tab_exp)
	self.data_coin = RewardUtil:getProcessRewardData(tab_money)
	local shortage_index = 0
	local is_enough = true
	local cur_exp = self.data_exp.user_num
	local cur_coin = self.data_coin.user_num
	local need_exp = 0
	local need_coin = 0
	if self.m_upgradeCfg[cur_lv] and self.m_upgradeCfg[min_evo_lv] then
		local cur_cfg = self.m_upgradeCfg[cur_lv]
		local target_cfg = self.m_upgradeCfg[min_evo_lv]
		need_exp = target_cfg.totalcost_exp - cur_cfg.totalcost_exp
		need_coin = target_cfg.totalcost_gold - cur_cfg.totalcost_gold
		if cur_coin < need_coin then
			shortage_index = 1
			is_enough = false
		elseif cur_exp < need_exp then
			shortage_index = 2
			is_enough = false
		end
	end
	return is_enough, shortage_index, need_exp, need_coin
end

--根据代数筛选列表
function M:getEvolvListByEvo(pets)
	local filter_pets = {}
	for k,v in pairs(pets) do
		local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(v)
		if  self.m_select_evo1 == pet_data.evo then
			table.insert(filter_pets, v)
		end
	end
	return filter_pets
end

--根据代数筛选列表
function M:getCompreheadListByEvo(pets)
	local filter_pets = {}
	for k,v in pairs(pets) do
		local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(v)
		if  self.m_select_evo2 == pet_data.evo then
			table.insert(filter_pets, v)
		end
	end
	return filter_pets
end

--获取材料的等级
function M:getMaterialEvo(evo)
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	local evo_cfg = pet_evolution[evo]
	local min_lv = 0
	if evo_cfg then
		for k,v in pairs(evo_cfg.evolution_cost) do
			if v[1] == 161 then
				if min_lv == 0 then
					min_lv = v[2]
				else
					if 	min_lv > v[2] then
						min_lv = v[2]
					end
				end
			end
		end
	end
	return min_lv
end

function M:getCompreheadNums()
	if self.m_comprehead_id == nil or self.m_comprehead_id == "" then
		return 0
	end
	local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_comprehead_id)
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	local evo_cfg = pet_evolution[pet_data.evo]
	return evo_cfg.limit - pet_data.lv
end

function M:getCompreheadRate()
	local pet_upgrade = ConfigManager:getCfgByName("pet_upgrade")
	local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_comprehead_id)
	if pet_upgrade[pet_data.lv] then
		return pet_upgrade[pet_data.lv].variation_rate_add, pet_upgrade[pet_data.lv+1].variation_rate_add
	end
	return 0,0
end

function M:getCompreheadRateByOid(oid)
	local pet_upgrade = ConfigManager:getCfgByName("pet_upgrade")
	local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(oid)
	if pet_upgrade[pet_data.lv] then
		return pet_upgrade[pet_data.lv].variation_rate_add
	end
	return 0,0
end

function M:getCompreheadNumsByOid(oid)
	local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(oid)
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	local evo_cfg = pet_evolution[pet_data.evo]
	return evo_cfg.limit - pet_data.lv
end

function M:getCompreheadCons()
	local pet_upgrade = ConfigManager:getCfgByName("pet_upgrade")
	local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_comprehead_id)
	if pet_upgrade[pet_data.lv] then
		local exp_num = pet_upgrade[pet_data.lv].exp
		local coin_num = pet_upgrade[pet_data.lv].coin
		return RewardUtil:getProcessRewardData({104,0,coin_num}),  RewardUtil:getProcessRewardData({162,0,exp_num})
	end
end

function M:getNetCompreheadLv(quick)
	local level = 0
	local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_comprehead_id)
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	local cur_evo = pet_evolution[pet_data.evo]
	if cur_evo then
		if quick and quick == true then
			level = cur_evo.limit 
		else
			level = pet_data.lv + 1
		end
	end
	if level > cur_evo.limit  then
		level = cur_evo.limit
	end
	return level
end

function M:getlockSkillNums()
	if self.m_slot[1] == nil or self.m_slot[1] == "" or self.m_slot[1] == 0 then
		return 0
	end
	local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_slot[1])
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	local cur_evo = pet_evolution[pet_hero.evo]
	return cur_evo.lock_skills
end

--领悟排序  选中>可领悟>概率
function M:getSoltByComprehead(ids)
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = UserDataManager.pet_data:getPetDataById(id_one)
        local data2, cfg2 = UserDataManager.pet_data:getPetDataById(id_two)
        local cid1, cid2 = data1.id, data2.id
        local lv1, lv2 = data1.lv, data2.lv
		local xuanzhong_1 = id_one == self.m_slot[1] and 1 or 0
		local xuanzhong_2 = id_two == self.m_slot[1] and 1 or 0
		local lw_num_1 = self:getCompreheadNumsByOid(id_one)
		local lw_num_2 = self:getCompreheadNumsByOid(id_two)
		local rate_1 = self:getCompreheadRateByOid(id_one)
		local rate_2 = self:getCompreheadRateByOid(id_two)
		if xuanzhong_1 == xuanzhong_2 then
			if lw_num_1 == lw_num_2 then
				if rate_1 == rate_2 then
					return lv1 > lv2
				else
					return rate_1 > rate_2
				end
			else
				return lw_num_1 >lw_num_2
			end
		else
			return xuanzhong_1 >xuanzhong_2
		end
    end
    table.sort(ids, sortFunc)
end

--[[
    宠物排序
]]
function M:equipIdsSort(ids, type_name)
    ids = ids or {}
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = UserDataManager.pet_data:getPetDataById(id_one)
        local data2, cfg2 = UserDataManager.pet_data:getPetDataById(id_two)
		local quality1 = self:calcTotalQuality(data1.quality)
        local quality2 = self:calcTotalQuality(data2.quality)
		local isEvo1 = self:checkIsCanEvoForSort(data1.lv)
		local isEvo2 = self:checkIsCanEvoForSort(data2.lv)
		if isEvo1 == isEvo2 then
			if data1.combat == data2.combat then
				if quality1 == quality2 then
					if data1.evo == data2.evo then
						if data1.lv == data2.lv then
							return data1.id > data2.id
						else
							return data1.lv > data2.lv
						end
					else
						return data1.evo > data2.evo
					end
				else
					return quality1 > quality2
				end
			else
				return data1.combat > data2.combat
			end
		else
			return isEvo1 > isEvo2
		end
		
    end
    table.sort(ids, sortFunc)
end

function M:checkIsCanEvoForSort(lv)
	if self.m_evo_min_lv and lv >= self.m_evo_min_lv then
		return 2
	end
	return 1
end

function M:calcTotalQuality(quality)
    local total_quality = 0
    local hero_enumeration_cfg = ConfigManager:getCfgByName("hero_enumeration")
    local attr_id
    for k, v in pairs(quality) do
        attr_id = v.base[1]
        if hero_enumeration_cfg[attr_id] then
            total_quality = total_quality + v.param[2]
        end
    end
    return total_quality
end

return M
