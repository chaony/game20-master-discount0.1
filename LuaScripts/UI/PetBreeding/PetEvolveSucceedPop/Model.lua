---@class PetEvolveSucceedModel: OODataBase
local M = class("PetEvolveSucceedPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_old_skills = self.m_params.old_skills or {}
	self.m_old_variation = self.m_params.old_variation or {}
	self.m_pet_id = self.m_params.new_oid
	self.m_callback = self.m_params.callback 
	self.m_variation_skills = self.m_params.variation_skills or {}
end


function M:getPetData()
	return UserDataManager.pet_data:getPetDataById(self.m_pet_id)
end

function M:getPetDataById()
	local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_pet_id)
	return pet_hero,pet_cfg
end

function M:getMinLvByEvo(skill_rid)
    local skill_random_tab = ConfigManager:getCfgByName("pet_skill_random")
	if skill_random_tab[skill_rid] then
		local skill_tab = ConfigManager:getCfgByName("skill_detail")
		local skill_id = skill_random_tab[skill_rid].skill_id
		local skill_cfg = skill_tab[skill_id]
		return skill_random_tab[skill_rid], skill_cfg
	end
	return nil
end


--变异详情、技能列表
function M:getSkills()
	local show_list = {}
	local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_pet_id)
	if self:checkVariationAttr() == true then -- 变异
		for k,v in pairs(pet_hero.variation) do
			if self:checkIsNewVariation(v) == true then
				local cfg = self:getVariationCfgById(v)
				if cfg.type ~= 2 then
					table.insert(show_list, {type = 1 ,id = v})
				end
			end
		end
	end
	if self:checkVariationSkill() == true then -- 变异技能
		for k,v in pairs(self.m_variation_skills) do
			table.insert(show_list, {type = 2 ,id = v})
		end
	end
	for k,v in pairs(pet_hero.skills) do -- 常规技能
		table.insert(show_list, {type = 3 ,id = v})
	end
    local function sortFunc(id_one, id_two)
        if id_one.type == id_two.type then
			if id_one.type ~= 1 then 
				local new_1 = self:checkIsNewSkill(id_one.id) == true and 1 or 0
				local new_2 = self:checkIsNewSkill(id_two.id) == true and 1 or 0 
				if new_1 == new_2 then
					local random_cfg1, _ = self:getMinLvByEvo(id_one.id)
					local random_cfg2, _ = self:getMinLvByEvo(id_two.id)
					return random_cfg1.skill_jump > random_cfg2.skill_jump
				else
					return new_1 > new_2
				end
			else
				return id_one.id < id_two.id
			end
        else
            return id_one.type < id_two.type
        end
    end
    table.sort(show_list, sortFunc)
	return show_list
end


--检查宠物是否有发生变异
function M:checkVariation()
	if self:checkVariationSkill() == true then
		return true
	end
	if self:checkVariationAttr() == true then
		return true
	end
	return false
end

--检查是否有变异技能
function M:checkVariationSkill()
	return next(self.m_variation_skills) ~= nil
end

--检查是否有其他变异
function M:checkVariationAttr()
	local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_pet_id)
	if next(pet_hero.variation) ~= nil then
		return true
	end
	return false
end


function M:getVariationCfgById(id)
	local pet_variation_tab = ConfigManager:getCfgByName("pet_variation")
	return pet_variation_tab[id]
end

function M:checkIsNewSkill(id)
	for k,v in pairs(self.m_old_skills) do
		if v == id then
			return false
		end
	end
	return true
end


function M:checkIsNewVariation(id)
	for k,v in pairs(self.m_old_variation) do
		if v == id then
			return false
		end
	end
	return true
end
return M
