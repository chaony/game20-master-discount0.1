---@class PetBagModel: OODataBase
local M = class("PetBagModel", LikeOO.OODataBase)

local tab_exp = { RewardUtil.REWARD_TYPE_KEYS.PET_EXP, 0, 0 } --经验
local tab_money = { RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0 } --金币


function M:onCreate()
    M.super.onCreate(self)
    self:getData("pet_check_egg")
end

function M:onEnter()
    RedPointUtil:checkPetEvoRedPoint()
    
    self.m_is_quick_lv = false --快速升级展示
    self.m_show_quick_lv_time = 0 --快速升级剩余显示时间
    self.m_panel_type = 1 --界面类型 (1 列表界面 2详情界面)
    self.m_sel_tab_index = 0 --详情界面页签索引(1 描述 2技能)
    self.m_mode = self.m_params.mode or 1 --模式 (1进自己 2进别人)
    self.m_sel_pet_oid = nil --当前宠物oid
    self.m_sel_pet_data = {} --当前宠物数据
    self.m_egg_list = {}   --当前孵蛋的宠物
    self.m_sel_pet_index = 0 --当前宠物列表index
    self.m_pet_list = {}     --宠物列表
    self.m_egg_ok_list = self.m_data.egg_ok or {}
    self.m_egg_red_list = {} --红点列表
    
    self.m_list_sort_type = 1
    
    self:initRedList()
    self:initCfgData()
    self:refreshData(true)
end

function M:initCfgData()
    self.m_evolutionCfg = ConfigManager:getCfgByName("pet_evolution")
    self.m_upgradeCfg = ConfigManager:getCfgByName("pet_upgrade")
    self.m_skillCfg = ConfigManager:getCfgByName("pet_skill_random")
    self.m_qualityCfg = ConfigManager:getCfgByName("pet_quality")
end

function M:initRedList()
    for k, v in ipairs(self.m_egg_ok_list) do
        table.insert(self.m_egg_red_list, v.oid)
    end
end

function M:checkIsHaveRed(oid)
    for k, v in ipairs(self.m_egg_red_list) do
        if v == oid then
            return true
        end
    end
    return false
end

function M:insertRedList(oid)
    if not self.m_egg_red_list[oid] then
        table.insert(self.m_egg_red_list, oid)
    end
end

function M:removeRedList(oid)
    for k, v in ipairs(self.m_egg_red_list) do
        if v == oid then
            table.remove(self.m_egg_red_list, k)
        end
    end
end

function M:insertRedList(oid)
    if not self.m_egg_red_list[oid] then
        table.insert(self.m_egg_red_list, oid)
    end
end

--isGotoFirst刷新排序并跳转到第一个 升级不会重新排序
function M:refreshData(isGotoFirst)
    self:refreshEggList()
    self:refreshTeamList()
    if isGotoFirst then
        self.m_pet_list = self:getAllPetIds()
    end
    if table.nums(self.m_pet_list) == 0 then
        self.m_sel_pet_oid = nil
        self.m_sel_pet_index = 0
        return
    end
    self:updateCurPetInfo(isGotoFirst)
    self:updateResourceData()
end

function M:refreshEggList()
    local pet_lists = table.copy(UserDataManager.pet_data:getPetsId())
    self.m_egg_list = {}
    local curTime = UserDataManager:getServerTime()
    for k, v in ipairs(pet_lists) do
        local data = self:getPetDataById(v)
        if data.egg_ets and curTime < data.egg_ets then
            table.insert(self.m_egg_list, v)
        end
    end
end

function M:getEggList()
    return self.m_egg_list
end

function M:getEggEndTime(oid)
    if self:checkIsEgg(oid) then
        local data, cfg = self:getPetDataById(oid)
        if data.egg_ets then
            return data.egg_ets
        end
    end
    return 0
end

function M:checkMaxCanLv()
    local isQuick = false
    local lv = 0
    local sel_pet_evo = self.m_sel_pet_data.data.evo
    if self.m_evolutionCfg[sel_pet_evo] then
        if self.m_sel_pet_sever_lv < self.m_evolutionCfg[sel_pet_evo].min_condition then
            lv = self.m_evolutionCfg[sel_pet_evo].min_condition
            self:updateResourceData()
            if self.m_upgradeCfg[self.m_sel_pet_sever_lv] and self.m_upgradeCfg[lv] then
                local cur_exp = self.data_exp.user_num
                local cur_coin = self.data_coin.user_num
                local target_cfg = self.m_upgradeCfg[lv]
                local cur_cfg = self.m_upgradeCfg[self.m_sel_pet_sever_lv]
                local need_exp = target_cfg.totalcost_exp - cur_cfg.totalcost_exp
                local need_coin = target_cfg.totalcost_gold - cur_cfg.totalcost_gold
                if cur_coin >= need_coin and cur_exp >= need_exp then
                    isQuick = true
                end
            end
        end
    end
    return lv, isQuick
end

function M:checkLvResource(lv)
    self:updateResourceData()
    local shortage_index = 0
    local is_enough = true
    local cur_exp = self.data_exp.user_num
    local cur_coin = self.data_coin.user_num
    if self.m_upgradeCfg[self.m_sel_pet_sever_lv] and self.m_upgradeCfg[lv] then
        local cur_cfg = self.m_upgradeCfg[self.m_sel_pet_sever_lv]
        local target_cfg = self.m_upgradeCfg[lv]
        local need_exp = target_cfg.totalcost_exp - cur_cfg.totalcost_exp
        local need_coin = target_cfg.totalcost_gold - cur_cfg.totalcost_gold
        if cur_coin < need_coin then
            shortage_index = 1
            is_enough = false
        elseif cur_exp < need_exp then
            shortage_index = 2
            is_enough = false
        end
    end
    return is_enough, shortage_index
end

function M:updateCurPetInfo(isGotoFirst)
    self.m_sel_pet_data = {}
    if isGotoFirst then
        --首次进入或者可能选中的归林或升阶消耗了
        self.m_sel_pet_index = 1
        self.m_sel_pet_oid = self.m_pet_list[self.m_sel_pet_index]
    else
        for i = 1, #self.m_pet_list do
            if self.m_pet_list[i] == self.m_sel_pet_oid then
                self.m_sel_pet_index = i
                break
            end
        end
    end
    local data, cfg = self:getPetDataById(self.m_sel_pet_oid)
    self.m_sel_pet_data = { cfg = cfg, data = data }
    self.m_sel_pet_sever_lv = self.m_sel_pet_data.data.lv
    self.m_help_skill_ids = self.m_sel_pet_data.cfg.xiezhanskill1
    self.m_killer_skill_id = self.m_sel_pet_data.cfg.skill3
    self.m_help_skill_id = nil
    for k, v in ipairs(self.m_sel_pet_data.data.skills) do
        if self.m_skillCfg[v].type == 2 then
            self.m_help_skill_id = v
            break
        end
    end
end

function M:getCurPetInfo()
    return self.m_sel_pet_data
end

function M:checkIsEgg(oid)
    for k, v in ipairs(self.m_egg_list) do
        if v == oid then
            return true
        end
    end
    return false
end

function M:checkIsEggForSort(oid)
    for k, v in ipairs(self.m_egg_list) do
        if v == oid then
            return 2
        end
    end
    return 1
end
function M:getCurShowLevel()
    if self.m_upgradeCfg[self.m_sel_pet_sever_lv] then
        return self.m_upgradeCfg[self.m_sel_pet_sever_lv].display_level
    end
    return 1
end

function M:revertToShowLevel(lv)
    if self.m_upgradeCfg[lv] then
        return self.m_upgradeCfg[lv].display_level
    end
    return 1
end

function M:getCurCombat()
    return self.m_sel_pet_data.data.combat
end

function M:updateResourceData()
    self.data_exp = table.copy(RewardUtil:getProcessRewardData(tab_exp))
    self.data_coin = table.copy(RewardUtil:getProcessRewardData(tab_money))
end

function M:checkMaxLv()
    --进化表的最后一阶段
    local max_evo = #self.m_evolutionCfg
    local max_lv = self.m_evolutionCfg[max_evo].min_condition
    local sel_pet_evo = self.m_sel_pet_data.data.evo
    if self.m_sel_pet_sever_lv >= max_lv and sel_pet_evo >= max_evo then
        return true
    end
    return false
end

function M:checkCanLv()
    local sel_pet_evo = self.m_sel_pet_data.data.evo
    if self.m_evolutionCfg[sel_pet_evo] then
        if self.m_sel_pet_sever_lv < self.m_evolutionCfg[sel_pet_evo].min_condition then
            return true
        end
    end
    return false
end

function M:getNextLevelNeedMoney()
    local coin = 0
    local exp = 0
    if self.m_upgradeCfg[self.m_sel_pet_sever_lv] then
        coin = self.m_upgradeCfg[self.m_sel_pet_sever_lv].coin
        exp = self.m_upgradeCfg[self.m_sel_pet_sever_lv].exp
    end
    return coin, exp
end

function M:updateResourceData()
    self.data_exp = table.copy(RewardUtil:getProcessRewardData(tab_exp))
    self.data_coin = table.copy(RewardUtil:getProcessRewardData(tab_money))
end

function M:getRightPet()
    for i = 1, table.nums(self.m_pet_list) do
        if self.m_sel_pet_oid == self.m_pet_list[i] and i < table.nums(self.m_pet_list) then
            return self.m_pet_list[i + 1], true
        end
    end
    return self.m_sel_pet_oid, false
end

function M:getLeftPet()
    for i = 1, table.nums(self.m_pet_list) do
        if self.m_sel_pet_oid == self.m_pet_list[i] and i ~= 1 then
            return self.m_pet_list[i - 1], true
        end
    end
    return self.m_sel_pet_oid, false
end

function M:getAllPetIds()
    local ids = table.copy(UserDataManager.pet_data:getPetsId())
    local function sortFunc(id_one, id_two)
        local data1, cfg1 = self:getPetDataById(id_one)
        local data2, cfg2 = self:getPetDataById(id_two)
        local quality1 = self:calcTotalQuality(data1.quality)
        local quality2 = self:calcTotalQuality(data2.quality)
        --蛋 >宠物，蛋(代数、时间)，宠物(战力、品阶、代数、等级)
        if self:checkIsEgg(id_one) and self:checkIsEgg(id_two) then
            if data1.evo ~= data2.evo then 
                return data1.evo > data2.evo
            else
                return data1.egg_ets < data2.egg_ets
            end
        elseif self:checkIsEgg(id_one) or self:checkIsEgg(id_two) then
            return self:checkIsEggForSort(id_one) > self:checkIsEggForSort(id_two)
        elseif data1.combat ~= data2.combat then
            return data1.combat > data2.combat
        elseif quality1 ~= quality2 then
            return quality1 > quality2
        elseif data1.evo ~= data2.evo then
            return data1.evo > data2.evo
        elseif data1.lv ~= data2.lv then
            return data1.lv > data2.lv
        else
            return data1.oid > data2.oid
        end
    end
    table.sort(ids, sortFunc)
    return ids
end

function M:turnPetList()
    if #self.m_pet_list <= 0 then
        return
    end
    
    local tmp = {}
    for i = 1, #self.m_pet_list do
        local key = #self.m_pet_list + 1 - i
        tmp[i] = self.m_pet_list[key]
    end
    self.m_pet_list = tmp
end

function M:sortPetListByType()
    if #self.m_pet_list <= 0 then
        return
    end
    
    local sortFunc = function(id_one, id_two)
        local data1, _ = self:getPetDataById(id_one)
        local data2, _ = self:getPetDataById(id_two)
        
        local quality1 = GameUtil:getPetQualityByData(data1)
        local quality2 = GameUtil:getPetQualityByData(data2)
        
        local combat1 = self:checkIsEgg(id_one) and 0 or data1.combat
        local combat2 = self:checkIsEgg(id_two) and 0 or data2.combat
        
        --战力
        if self.m_list_sort_type == 1 then
            if combat1 ~= combat2 then
                return combat1 > combat2
            else
                return quality1 > quality2
            end
        --品阶
        elseif self.m_list_sort_type == 2 then
            if quality1 ~= quality2 then
                return quality1 > quality2
            else
                return combat1 > combat2
            end
        --代数    
        elseif self.m_list_sort_type == 3 then
            if data1.evo ~= data2.evo then
                return data1.evo > data2.evo    
            else
                return combat1 > combat2
            end
        end
    end
    table.sort(self.m_pet_list, sortFunc)
    
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
--宠物列表
--function M:getAllPetIds()
--    local ids = table.copy(UserDataManager.pet_data:getPetsId())
--    local sort_ids = {}
--    local record_ids = {}
--    for i = #ids, 1, -1 do
--        local data, cfg = self:getPetDataById(ids[i])
--        if not record_ids[cfg.pet_type] and not data.egg_ets then
--            record_ids[cfg.pet_type] = data
--        elseif record_ids[cfg.pet_type] and data.combat > record_ids[cfg.pet_type].combat and not data.egg_ets then
--            record_ids[cfg.pet_type] = data
--        end
--    end
--    for i = #ids, 1, -1 do
--        for k, v in pairs(record_ids) do
--            if v.oid == ids[i] then
--                table.remove(ids, i)
--            end
--        end
--    end
--    local function sortFunc(id_one, id_two)
--        local data1, cfg1 = self:getPetDataById(id_one)
--        local data2, cfg2 = self:getPetDataById(id_two)
--        --孵化中（剩余时间）>类型 >代数 >等级 >剩余战力
--        if self:checkIsEgg(id_one) and self:checkIsEgg(id_two) then
--            return data1.egg_ets < data2.egg_ets
--        elseif self:checkIsEgg(id_one) or self:checkIsEgg(id_two) then
--            return self:checkIsEggForSort(id_one) > self:checkIsEggForSort(id_two)
--        elseif cfg1.pet_type ~= cfg2.pet_type then
--            return cfg1.pet_type < cfg2.pet_type
--        elseif data1.evo ~= data2.evo then
--            return data1.evo > data2.evo
--        elseif data1.lv ~= data2.lv then
--            return data1.lv > data2.lv
--        elseif data1.combat ~= data2.combat then
--            return data1.combat > data2.combat
--        else
--            return data1.oid > data2.oid
--        end
--    end
--    table.sort(ids, sortFunc)
--    --四个战力最高优先
--    for k, v in pairs(record_ids) do
--        table.insert(sort_ids, v.oid)
--        table.sort(sort_ids, function(id_one, id_two)
--            local data1, cfg1 = self:getPetDataById(id_one)
--            local data2, cfg2 = self:getPetDataById(id_two)
--            if cfg1.pet_type ~= cfg2.pet_type then
--                return cfg1.pet_type < cfg2.pet_type
--            else
--                return data1.oid > data2.oid
--            end
--        end)
--    end
--    for i = 1, #ids, 1 do
--        table.insert(sort_ids, ids[i])
--    end
--    return sort_ids
--end



function M:getPetDataById(oid)
    local data, cfg = UserDataManager.pet_data:getPetDataById(oid)
    return data, cfg
end

function M:getPetDataByIndex(index)
    return self.m_pet_list[index]
end

function M:getPetNum()
    local vip = ConfigManager:getCfgByName("vip")
    local vip_lv = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    local num = vip[vip_lv].pet_max
    return #self.m_pet_list, num
end

function M:getConditionByEvo(evo)
    local lower_level = 0
    local upper_level = 0
    if self.m_evolutionCfg[evo] then
        lower_level = self.m_evolutionCfg[evo].min_condition
        upper_level = self.m_evolutionCfg[evo].limit
    end
    return lower_level, upper_level
end

function M:getAttrs()
    return self.m_sel_pet_data.data.attrs
end

function M:getAttrPopData()
    return table.copy(self.m_sel_pet_data.data.attrs)
end

function M:getTalentData()
    local hero_enumeration_cfg = ConfigManager:getCfgByName("hero_enumeration")
    local attr_id
    local num
    local attr_text
    local talentData = {}
    for k, v in pairs(self.m_sel_pet_data.data.quality) do
        attr_id = v.base[1]
        num = v.param[2]
        if hero_enumeration_cfg[attr_id] then
            attr_text = Language:getTextByKey(hero_enumeration_cfg[attr_id].name)
            talentData[tonumber(k)] = { num = num, attr_text = attr_text }
        end
    end
    return talentData
end

function M:getVariationRate()
    local evo = self.m_sel_pet_data.data.evo
    local rate = 0
    if self.m_evolutionCfg[evo] then
        rate = self.m_evolutionCfg[evo].variation_base
        if self.m_upgradeCfg[self.m_sel_pet_sever_lv] then
            rate = rate + self.m_upgradeCfg[self.m_sel_pet_sever_lv].variation_rate_add
        end
    end
    return rate * 100 .. "%"
end

function M:getCurPetName()
    local name_key = self.m_sel_pet_data.cfg.name
    return Language:getTextByKey(name_key)
end

function M:getCurPetCid()
    return self.m_sel_pet_data.data.id
end

function M:getSkillPopDataByType(type)
    local skill_id
    local img = ""
    local des = ""
    local name = ""
    if type == 1 then
        skill_id = self.m_killer_skill_id
    elseif type == 2 and self.m_help_skill_id then
        skill_id = self.m_help_skill_id
    end
    img, des, name = self:getSkillDataBySkillId(self.m_skillCfg[skill_id].skill_id)
    return { title_text = name, skill_text = des }
end

function M:getAllHelpSkillPopData()
    local des = ""
    local name = Language:getTextByKey("pet_bag_text_0036")
    local skill_cfg = ConfigManager:getCfgByName("skill_detail")
    for k, v in ipairs(self.m_help_skill_ids) do
        if skill_cfg[v] then
            des = des .. Language:getTextByKey(skill_cfg[v].name) .. "\n"
            des = des .. Language:getTextByKey(skill_cfg[v].des) .. "\n"
        end
        des = des .. "\n"
    end
    return { title_text = name, skill_text = des }
end

function M:getSkillDetailData()
    local highest_skill_ids = self.m_sel_pet_data.cfg.skill_list
    local show_skill_data = {}
    for k1, v1 in ipairs(highest_skill_ids) do
        if self.m_skillCfg[v1] then
            local skill_group = self.m_skillCfg[v1].skill_group
            local skill_quality = 4
            local own_skill_group = false
            local skill_id = v1
            for k2, v2 in ipairs(self.m_sel_pet_data.data.skills) do
                if self.m_skillCfg[v2] and self.m_skillCfg[v2].skill_group == skill_group then
                    skill_quality = self.m_skillCfg[v2].quality
                    skill_id = v2
                    own_skill_group = true
                    break
                end
            end
            table.insert(show_skill_data, { skill_id = skill_id, skill_quality = skill_quality, own_skill_group = own_skill_group })
        end
    end
    return show_skill_data
end

function M:getAllSkillList()
    return self.m_sel_pet_data.data.skills
end

function M:getPetIndexByOid(oid)
    for k, v in pairs(self.m_pet_list) do
        if oid == v then
            return k
        end
    end
    return 1
end

function M:getOwnSkillsCfg()
    local skillCfg = {}
    local skill_list = self.m_sel_pet_data.data.skills
    for k, v in ipairs(skill_list) do
        if self.m_skillCfg[v] then
            skillCfg.insert(v, self.m_skillCfg[v])
        end
    end
    return skillCfg
end

function M:getKillerSkillQualityBgById(petId)
    local data, cfg = self:getPetDataById(petId)
    if data == nil then
        return false
    end
    
    for _, v in ipairs(data.skills) do
        if self.m_skillCfg[v].skill3 == 1 then
            return true, GameUtil:getPetSkillBg(v)
        end
    end
    return false
end

function M:getHelperSkillQualityBgById(petId)
    local data, cfg = self:getPetDataById(petId)
    if data == nil then
        return false
    end

    for _, v in ipairs(data.skills) do
        if self.m_skillCfg[v].type == 2 then
            return true, GameUtil:getPetSkillBg(v)
        end
    end
    return false
end



--必杀技
function M:getKillerSkillCfg()
    local isLock = true
    for k, v in ipairs(self.m_sel_pet_data.data.skills) do
        if self.m_skillCfg[v].skill3 == 1 then
            self.m_killer_skill_id = v
            isLock = false
            break
        end
    end
    local type_bg = GameUtil:getPetSkillBg(self.m_killer_skill_id)
    local quality_bg = self:getSkillQualityBg(self.m_skillCfg[self.m_killer_skill_id].quality)
    local type_text = self:getSkillTypeText(self.m_skillCfg[self.m_killer_skill_id].type)
    local skill_img = ""
    if self.m_skillCfg[self.m_killer_skill_id].skill_jump == 1 then
        skill_img = self:getSkillDataBySkillId(self.m_skillCfg[self.m_killer_skill_id].skill_id)
    end
    return { killer_skill_id = self.m_killer_skill_id, isLock = isLock, quality_bg = quality_bg, type_text = type_text, skill_img = skill_img, type_bg = type_bg }
end

--协战技
function M:getHelpSkillCfg()
    local isLock = true
    local type_bg = ""
    local skill_img = ""
    local quality_bg = ""
    local type_text = ""
    if self.m_help_skill_id then
        if self.m_skillCfg[self.m_help_skill_id].skill_jump == 1 then
            skill_img = self:getSkillDataBySkillId(self.m_skillCfg[self.m_help_skill_id].skill_id)
        end
        isLock = false
        type_bg = GameUtil:getPetSkillBg(self.m_help_skill_id)
        quality_bg = self:getSkillQualityBg(self.m_skillCfg[self.m_help_skill_id].quality)
        type_text = self:getSkillTypeText(self.m_skillCfg[self.m_help_skill_id].type)
    else
        --技能图标一样，默认取第一个
        local help_skill_id = self.m_help_skill_ids[1]
        if self.m_skillCfg[help_skill_id].skill_jump == 1 then
            skill_img = self:getSkillDataBySkillId(self.m_skillCfg[help_skill_id].skill_id)
        end
    end
    return { help_skill_id = self.m_help_skill_id, isLock = isLock, quality_bg = quality_bg, type_text = type_text, skill_img = skill_img, type_bg = type_bg }
end

function M:getDescByPetSkillId(petSkillId)
    local desc = ""
    if self.m_skillCfg[petSkillId] then
        if self.m_skillCfg[petSkillId].skill_id and self.m_skillCfg[petSkillId].skill_jump == 1 then
            local skill_id = self.m_skillCfg[petSkillId].skill_id
            local skill_cfg = ConfigManager:getCfgByName("skill_detail")
            if skill_cfg[skill_id] then
                desc = Language:getTextByKey(skill_cfg[skill_id].name) .. "\n"
            end
        end
        desc = desc .. Language:getTextByKey(self.m_skillCfg[petSkillId].skill_des)
    end
    return desc
end

function M:getCurSkillList()
    local show_skills = table.copy(self.m_sel_pet_data.data.skills)
    local killer_skill_id = self.m_killer_skill_id
    --不显示必杀技和协战技
    for i = #show_skills, 1, -1 do
        if show_skills[i] == killer_skill_id then
            table.remove(show_skills, i)
        elseif self.m_help_skill_id and show_skills[i] == self.m_help_skill_id then
            table.remove(show_skills, i)
        end
    end

    local function sortFunc(skill_one, skill_two)
        return skill_one > skill_two
    end
    table.sort(show_skills, sortFunc)
    return show_skills
end

function M:getOwnSkillNum()
    return #self.m_sel_pet_data.data.skills or 0
end

function M:getSkillQualityBg(quality)
    if quality == 1 then
        return "a_cwyc_qsjn_lan"
    elseif quality == 2 then
        return "a_cwyc_qsjn_zi"
    elseif quality == 3 then
        return "a_cwyc_qsjn_cheng"
    else
        return ""
    end
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

function M:getSkillDataByPetSkill(petSkillId)
    if self.m_skillCfg[petSkillId] then
        local type_text = self:getSkillTypeText(self.m_skillCfg[petSkillId].type)
        local desc_text = ""
        local name_text = ""
        local type = self.m_skillCfg.type
        local quality = self.m_skillCfg[petSkillId].quality
        if self.m_skillCfg[petSkillId].skill_jump == 1 then
            local img
            local des
            img, des, name_text = self:getSkillDataBySkillId(self.m_skillCfg[petSkillId].skill_id)
            desc_text = "<Color=#af6c40>" .. name_text .. "</Color>" .. "\n"
        end
        desc_text = desc_text .. Language:getTextByKey(self.m_skillCfg[petSkillId].skill_des)
        return { type = type, desc_text = desc_text, name_text = name_text, quality = quality, type_text = type_text }
    end
    return nil
end

--带图标的必杀技和协站技从skill_detail取
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

function M:getEvolvePopData(oid)
    local evolvePopData = {}
    local data, cfg = self:getPetDataById(oid)
    if data.old_skills and data.old_variation and data.variation_skills then
        evolvePopData.old_skills = data.old_skills
        evolvePopData.old_variation = data.old_variation
        evolvePopData.oid = oid
        evolvePopData.variation_skills = data.variation_skills
    end
    return evolvePopData
end

function M:getCurMoveX(num, max_h)
    local rate = num / 640
    local n_num = (max_h / 2) * rate
    return n_num
end

function M:getEggIcon(oid)
    local data, cfg = self:getPetDataById(oid)
    if self.m_evolutionCfg[data.evo] then
        return self.m_evolutionCfg[data.evo].egg_pic
    end
end

function M:saveLastLvData()
    self.last_lv = self:getCurShowLevel()
    self.last_attrs = table.copy(self.m_sel_pet_data.data.attrs)
    self.last_combat = self:getCurCombat()
end

function M:getCurMoodCfg()
    local mood_cfg = ConfigManager:getCfgByName("mood_random")
    local mood_id = self.m_sel_pet_data.data.mood
    if mood_cfg[mood_id] then
        return mood_cfg[mood_id], mood_id
    end
    return nil
end

function M:checkMoodOpen()
    local data = UserDataManager:getPetPvpSeasonData()
    if data and data.season and data.season > 0 then
        return true
    end
    return false
end

function M:refreshTeamList()
    local team_ids = UserDataManager.hero_data:getTeamByKey("pet_pvp")
    self.team_list = {}
    for i = 1, 3 do
        if team_ids[i] ~= "" then
            table.insert(self.team_list, team_ids[i])
        end
    end
end

function M:checkInTeam(oid)
    if table.indexof(self.team_list, oid) then
        return true
    end
    return false
end

function M:destroy()
    self:getNetData("pet_check_egg")
    M.super.destroy(self)
end


return M


