---@class PetSkillDetailPopModel: OODataBase
local M = class("PetSkillDetailPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_own_skill_list = self.m_params.own_skill_list
    self.m_pet_name = self.m_params.pet_name
    self.m_pet_id = self.m_params.pet_id
    self.m_curIndex = 1
    self:initSkillData()
end

function M:initSkillData()
    local skill_cfg = ConfigManager:getCfgByName("pet_skill_random")
    local cur_skill_cfg = {}
    local is_find_killer_skill_img = false
    local is_find_help_skill_img = false
    for k, v in pairs(skill_cfg) do
        if v.pet_id == self.m_pet_id then
            if not cur_skill_cfg[v.skill_group] then
                cur_skill_cfg[v.skill_group] = {}
            end
            table.insert(cur_skill_cfg[v.skill_group], v)
            if not is_find_help_skill_img and v.type == 2 then
                local skill_detail_cfg = ConfigManager:getCfgByName("skill_detail")
                if skill_detail_cfg[v.skill_id] then
                    self.m_help_skill_img = skill_detail_cfg[v.skill_id].icon
                    is_find_help_skill_img = true
                end
            end
            if not is_find_killer_skill_img and v.skill3 == 1 then
                local skill_detail_cfg = ConfigManager:getCfgByName("skill_detail")
                if skill_detail_cfg[v.skill_id] then
                    self.m_killer_skill_img = skill_detail_cfg[v.skill_id].icon
                    is_find_killer_skill_img = true
                end
            end
        end
    end
    for k, v in pairs(cur_skill_cfg) do
        table.sort(v, function(cfg1, cfg2)
            return cfg1.quality > cfg2.quality
        end
        )
    end
    self.m_skill_data = cur_skill_cfg
end

function M:getGroupList()
    local group_ids = {}
    for k, v in pairs(self.m_skill_data) do
        table.insert(group_ids, k)
    end
    table.sort(group_ids, function(id1, id2)
        local cfg1 = self.m_skill_data[id1][1]
        local cfg2 = self.m_skill_data[id2][1]
        --协战在前 > id
        if cfg1.type ~= cfg2.type then
            return cfg1.type > cfg2.type
        else
            return cfg1.skill_group < cfg2.skill_group
        end
    end)
    return group_ids
end

function M:getCurIndex()
    return self.m_curIndex
end

function M:setCurIndex(index)
    self.m_curIndex = index
end

function M:getSkillDataByGroupId(groupId)
    return self.m_skill_data[groupId]
end

function M:getLeftSkillDataByGroupId(groupId)
    local data = {}
    local img = ""
    local type = 1
    local strengthen_text = ""
    local type_text = ""
    local isOwn = false
    local isKillerSkill = false
    local group_list = self.m_skill_data[groupId]
    for i = 1, #group_list do
        if i == 1 then
            type = group_list[i].type
            if type == 1 then
                strengthen_text = group_list[i].name_dictionary
                img = self.m_killer_skill_img
                type_text = Language:getTextByKey("pet_bag_text_0019")
                isKillerSkill = group_list[i].skill3 == 1
            elseif type == 2 then
                img = self.m_help_skill_img
                type_text = Language:getTextByKey("pet_bag_text_0020")
            end
        end
        if table.indexof(self.m_own_skill_list, group_list[i].skill_id) then
            isOwn = true
            break
        end
    end
    data = { img = img, isOwn = isOwn, strengthen_text = strengthen_text, type_text = type_text, type = type, isKillerSkill = isKillerSkill }
    return data
end

function M:getPetName()
    return self.m_pet_name
end

function M:getSkillQualityBg(quality)
    if quality == 1 then
        return "a_cwyc_qsjn_jb06"
    elseif quality == 2 then
        return "a_cwyc_qsjn_jb05"
    elseif quality == 3 then
        return "a_cwyc_qsjn_jb"
    else
        return ""
    end
end


return M
