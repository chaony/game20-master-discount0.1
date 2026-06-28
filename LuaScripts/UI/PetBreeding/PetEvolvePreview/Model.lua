---@class PetEvolvePreviewModel: OODataBase
local M = class("PetEvolvePreviewModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_main_id = self.m_params.m_id
	self.m_sec_id = self.m_params.sec_id
	self.m_lock_skill = self.m_params.lock_skill or {}
	self.m_lock_skill_nums = self:getNextlockSkillNums()
	self.can_lock_skill_nums = self:getlockSkillNums()
end

function M:getPetDataById(oid)
	local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(oid)
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

function M:getNextlockSkillNums()
	local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_main_id)
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	local cur_evo = pet_evolution[pet_hero.evo+1]
	return cur_evo.skill_limit
end

function M:getlockSkillNums()
	local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.m_main_id)
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	local cur_evo = pet_evolution[pet_hero.evo]
	return cur_evo.lock_skills
end

function M:addLockSkill(skill_id)
	table.insert(self.m_lock_skill,skill_id)	
end

function M:checkIsLick(skill_id)
	for k,v in pairs(self.m_lock_skill) do
		if v == skill_id then
			return true
		end
	end
	return false
end

function M:removeLockSkill(skill_id)
	for k,v in pairs(self.m_lock_skill) do
		if v == skill_id then
			table.remove(self.m_lock_skill, k)
			return
		end
	end
end

function M:checkLockFull()
	return table.nums(self.m_lock_skill) >= self.can_lock_skill_nums
end

return M
