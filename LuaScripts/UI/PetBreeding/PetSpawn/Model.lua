---@class PetSpawnModel: OODataBase
local M = class("PetSpawnModel", LikeOO.OODataBase)


function M:onCreate()
    M.super.onCreate(self)
    self:getData("")
end

function M:onEnter()
    self.lock_skill = {}
    local select_oid = self.m_params.pet_oid or 0
    self:InitData()
    if select_oid then
        self.index_oid = select_oid
    end
    local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.index_oid)
    if pet_data and pet_data.egg_ets then
        self.egg_oid = self.index_oid
        self.egg_data = pet_data
    end
    self.m_select_oid = 0
    self.m_buy_lv = 1
    self.m_pet_change = false -- 奇兽发生变化（）
end

function M:InitData()
	self.m_pets = UserDataManager.pet_data:getPetsId()
    if next(self.m_pets) ~= nil then
        self.index_oid = self.m_pets[1]
    else
        self.index_oid = 0
    end
end

function M:getReturnCons()
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
    local pet_pet_upgrade = ConfigManager:getCfgByName("pet_upgrade")
    local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.index_oid)
    local evo_cfg = pet_evolution[pet_data.evo]
    local upgrade_cfg = pet_pet_upgrade[pet_data.lv]
    local cons_data = {}
    cons_data = table.copy(evo_cfg.disband)
    for k,v in pairs(cons_data) do
        if v[1]== 104 then
            cons_data[k] = {v[1], v[2], v[3]+(upgrade_cfg.disband_gold or 0)}
        end
    end
    table.insert(cons_data, {162,0,(upgrade_cfg.disband_exp or 0)} )
    return cons_data
end

function M:getTalentData(oid)
    local data, cfg = UserDataManager.pet_data:getPetDataById(oid)
    local hero_enumeration_cfg = ConfigManager:getCfgByName("hero_enumeration")
    local attr_id
    local num
    local attr_text
    local talentData = {}
    for k, v in pairs(data.quality) do
        attr_id = v.base[1]
        num = v.param[2]
        if hero_enumeration_cfg[attr_id] then
            attr_text = Language:getTextByKey(hero_enumeration_cfg[attr_id].name)
            talentData[tonumber(k)] = { num = num, attr_text = attr_text }
        end
    end
    return talentData
end

function M:getAttrs(oid)
    local data, cfg = UserDataManager.pet_data:getPetDataById(oid)
    return data.attrs
end

function M:getSkillList(oid)
    local data, cfg = UserDataManager.pet_data:getPetDataById(oid)
    local show_skills = table.copy(data.skills)
    local killer_skill_id = cfg.skill3
    local help_skill_id = cfg.xiezhanskill1
    --不显示必杀技和协战技
    --for i = #show_skills, 1, -1 do
    --    if show_skills[i] == killer_skill_id then
    --        table.remove(show_skills, i)
    --    elseif show_skills[i] == help_skill_id then
    --        table.remove(show_skills, i)
    --    end
    --end

    local function sortFunc(skill_one, skill_two)
        return skill_one > skill_two
    end
    table.sort(show_skills, sortFunc)
    return show_skills
end

function M:getSkillDataByPetSkill(petSkillId)
    local skill_cfg = ConfigManager:getCfgByName("pet_skill_random")
    if skill_cfg[petSkillId] then
        local type_text = self:getSkillTypeText(skill_cfg[petSkillId].type)
        local desc_text = ""
        local name_text = ""
        local type = skill_cfg.type
        local quality = skill_cfg[petSkillId].quality
        if skill_cfg[petSkillId].skill_jump == 1 then
            local img
            local des
            img, des, name_text = self:getSkillDataBySkillId(skill_cfg[petSkillId].skill_id)
            desc_text = "<Color=#af6c40>" .. name_text .. "</Color>" .. "\n"
        end
        desc_text = desc_text .. Language:getTextByKey(skill_cfg[petSkillId].skill_des)
        return { type = type, desc_text = desc_text, name_text = name_text, quality = quality, type_text = type_text }
    end
    return nil
end

function M:getSkillDataBySkillId(skillId)
    local img = ""
    local des = ""
    local name = ""
    local skill_cfg = ConfigManager:getCfgByName("skill_detail")
    if skill_cfg[skillId] then
        img = skill_cfg[skillId].icon
        des = Language:getTextByKey(skill_cfg[skillId].des)
        name = Language:getTextByKey(skill_cfg[skillId].name)
    end
    return img, des, name
end

function M:getSkillTypeText(type)
    if type == 1 then
        return Language:getTextByKey("pet_bag_text_0019")
    elseif type == 2 then
        return Language:getTextByKey("pet_bag_text_0020")
    elseif type == 3 then
        return Language:getTextByKey("pet_bag_text_0021")
    end
    return ""
end

function M:getDescByPetSkillId(petSkillId)
    local desc = ""
    local skill_cfg = ConfigManager:getCfgByName("pet_skill_random")
    if skill_cfg[petSkillId] then
        if skill_cfg[petSkillId].skill_id and skill_cfg[petSkillId].skill_jump == 1 then
            local skill_id = skill_cfg[petSkillId].skill_id
            local skill_detail_cfg = ConfigManager:getCfgByName("skill_detail")
            if skill_detail_cfg[skill_id] then
                desc = Language:getTextByKey(skill_detail_cfg[skill_id].name) .. "\n"
            end
        end
        desc = desc .. Language:getTextByKey(skill_cfg[petSkillId].skill_des)
    end
    return desc
end

function M:getCompreheadRate()
	local pet_upgrade = ConfigManager:getCfgByName("pet_upgrade")
	local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.index_oid)
	if pet_upgrade[pet_data.lv] then
		return pet_upgrade[pet_data.lv].variation_rate_add, pet_upgrade[pet_data.lv+self.m_buy_lv].variation_rate_add
	end
	return 0,0
end

function M:getCompreheadNums()
	if self.index_oid == nil or self.index_oid == "" then
		return 0
	end
	local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.index_oid)
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	local evo_cfg = pet_evolution[pet_data.evo]
	return evo_cfg.limit - pet_data.lv
end

function M:addLv()
    self.m_buy_lv = self.m_buy_lv + 1
    local max_num = self:getCompreheadNums()
    if self.m_buy_lv > max_num then
        self.m_buy_lv = max_num
    end
end

function M:subLv()
    self.m_buy_lv = self.m_buy_lv - 1
    if self.m_buy_lv < 0 then
        self.m_buy_lv = 0
    end
end

function M:MaxLv()
    local max_num = self:getCompreheadNums()
    self.m_buy_lv = max_num
end

function M:MinLv()
    self.m_buy_lv = 0
end

function M:getCompreheadCons()
	local pet_upgrade = ConfigManager:getCfgByName("pet_upgrade")
	local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.index_oid)
    local cons = {}
    cons["exp"] = 0
    cons["coin"] = 0
    if self.m_buy_lv > 0 then
        for i = pet_data.lv, (pet_data.lv+(self.m_buy_lv-1))  do
            if pet_upgrade[i] then
                cons["exp"] = (cons["exp"] and cons["exp"] or 0) + pet_upgrade[i].exp
                cons["coin"] = (cons["coin"] and cons["coin"] or 0) + pet_upgrade[i].coin
            end
        end
    end
    return RewardUtil:getProcessRewardData({104,0,(cons["coin"]*2)}),  RewardUtil:getProcessRewardData({162,0,(cons["exp"]*2)})
end

function M:getlockSkillNums()
	if self.index_oid == nil or self.index_oid == "" or self.index_oid == 0 then
		return 0
	end
	local pet_hero, pet_cfg = UserDataManager.pet_data:getPetDataById(self.index_oid)
	local pet_evolution = ConfigManager:getCfgByName("pet_evolution")
	local cur_evo = pet_evolution[pet_hero.evo]
	return cur_evo.lock_skills
end

function M:checkIsEgg()
    local pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(self.index_oid)
    if pet_data and pet_data.egg_ets and pet_data.egg_ets > UserDataManager:getServerTime() then
        return true
    end
    return false
end

function M:getEvolvePopData()
    local evolvePopData = {}
    if self.egg_data then
        if self.egg_data.old_skills and self.egg_data.old_variation and self.egg_data.variation_skills then
            evolvePopData.old_skills = self.egg_data.old_skills
            evolvePopData.old_variation = self.egg_data.old_variation
            evolvePopData.oid = self.egg_oid
            evolvePopData.variation_skills = self.egg_data.variation_skills
        end
    end
    return evolvePopData
end

return M