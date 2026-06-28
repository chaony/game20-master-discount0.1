---
---@class AwakeSystemSmeltPopModel:OODataBase
local M = class("AwakeSystemSmeltPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self:initConfig()
    self.m_open_tab_index = self.m_params.open_tab_index or 4
    self.m_sel_tab_index = nil
    self.m_data_cache = {}  --所有的数据
    self.m_material_data_list = {}  -- 被选中的材料
    self.m_result_data_list = {} --熔炼出的结果
end

function M:initConfig()
    self.m_awaken_recycle = ConfigManager:getCfgByName("awaken_recycle")
    self.m_hero_detail = ConfigManager:getCfgByName("hero_detail")
    self.can_show_type = {}
    self.can_show_equip_quality = {}  --装备的品质要求
    self.can_show_hero_quality = {}  --侠客的品质要求
    for k, v in pairs(self.m_awaken_recycle) do
        self.can_show_type[k] = true
        if k == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
            for k1, v1 in pairs(v) do
                self.can_show_equip_quality[v1.quality] = true
            end
        end
        if k == RewardUtil.REWARD_TYPE_KEYS.HEROS then
            for k1, v1 in pairs(v) do
                self.can_show_hero_quality[v1.quality] = true
            end
        end
    end
end

function M:refreshListData(index, force_refresh)
    if force_refresh then
        self.m_data_cache = {}
    end
    index = index or self.m_open_tab_index
    if self.m_data_cache[index] == nil then
        local show_data = {}
        if index == 1 then
            -- 道具
            local function filterFunc(item_data, item_cfg)
                return (item_cfg.sort == 1 or item_cfg.sort == 5) and (item_cfg.is_show == 1) and (item_cfg.sort ~= 3)
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
        elseif index == 2 then
            -- 装备
            GameUtil:insertEquipsData(show_data)
        elseif index == 3 then
            -- 灵魂石
            local function filterFunc(item_data, item_cfg)
                return item_cfg.sort == 2 and item_cfg.is_show == 1
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
        elseif index == 4 then
            -- 全部
            local function filterFunc(item_data, item_cfg)
                return item_cfg.is_show == 1 and item_cfg.sort == 3 and (item_cfg.sort ~= 3)
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
            local other_items_data = {}
            local function filterFunc(item_data, item_cfg)
                return item_cfg.is_show == 1 and item_cfg.sort ~= 3 and (item_cfg.sort ~= 3)
            end
            GameUtil:insertProcessItemData(other_items_data, filterFunc)
            table.insertto(show_data, other_items_data)
            GameUtil:insertEquipsData(show_data)
            GameUtil:insertMysticesDataandOid(show_data)
            self:getAllHeroIds(show_data)

        elseif index == 5 then
            -- 秘籍碎片
            local function filterFunc(item_data, item_cfg)
                return item_cfg.sort == 4 and item_cfg.is_show == 1
            end
            GameUtil:insertProcessItemData(show_data, filterFunc)
            GameUtil:insertMysticesDataandOid(show_data)
        end
        --类型为20的自选卡，奖励内容和赛季相关
        for i, v in ipairs(show_data) do
            if v.data_type ~= RewardUtil.REWARD_TYPE_KEYS.HEROS then
                GameUtil:updateItemEffect(v)
            end
        end
        ----筛选出 只在表里配了的类型  我选择从这里面筛选出来需要的数据
        local real_data = self:filterShowData(show_data)
        self.m_data_cache[index] = real_data
    end
    self.m_show_data = self.m_data_cache[index] or {}
    return self.m_show_data
end

--获取所有英雄
function M:getAllHeroIds(show_data)
    local ids = table.copy(UserDataManager.hero_data:getHerosId())
    local hero_table = {}
    UserDataManager.hero_data:heroIdsSort(ids, "team")
    for k, v in pairs(ids) do
        local data = nil
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        if hero_data and hero_cfg then
            data = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0 })
            data.quality = hero_data.evo
            data.card_id = v
            data.hero_data = hero_data
        end
        table.insert(hero_table, data)
    end
    table.insertto(show_data, hero_table)
end

function M:getShowData()
    return self.m_show_data
end

function M:refreshMaterialListData()
    self.m_material_data_list = {}
end

--只针对了目前策划的需求写的代码
function M:filterShowData(show_data)
    local real_data = {}
    for i, v in ipairs(show_data) do
        if self.can_show_type[v.data_type] then
            --需要处理的类型  根据策划的表来处理
            if v.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM  then
                -- 道具类型
                local cur_type_cfg = self.m_awaken_recycle[v.data_type]
                local item_id = v.data_id
                for k1, v2 in pairs(cur_type_cfg) do
                    if v2.item_id == tonumber(item_id) then
                        table.insert(real_data, v)
                    end
                end
            elseif v.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
                -- 装备
                if self.can_show_equip_quality[v.quality] then
                    table.insert(real_data, v)
                end
            elseif v.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS then
                -- 侠客
                if self.can_show_hero_quality[v.hero_data.evo] then
                    table.insert(real_data, v)
                end
            end
        end
    end
    return real_data
end

--添加一件装备
function M:addCheckEqp(data)
    local nums = self:getMinNums(data)
    local cur_nums = self.m_material_data_list[data] or 0
    local final_nums = nums + cur_nums
    if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then  --只有道具去判断
        if final_nums > data.user_num then
            GameUtil:lookInfoTips(self.m_control,{msg = Language:getTextByKey("awake_system_text_0051"), delay_close = 2})
            return
        end
    end
    if self.m_material_data_list[data] then
        self.m_material_data_list[data] = self.m_material_data_list[data] + nums
        return
    end
    self.m_material_data_list[data] = nums
end

--添加多件装备
function M:addMoreCheckEqp(data, num)
    if self.m_material_data_list[data] then
        self.m_material_data_list[data] = self.m_material_data_list[data] + num
        return
    end
    self.m_material_data_list[data] = num
end

--检查当前装备数量是否达到最大
function M:checkIsInEqpList(data)
    if self.m_material_data_list[data] and self.m_material_data_list[data] >= data.user_num then
        return true
    end
    return false
end

--检查当前装备在列表中的数量
function M:checkNumInList(data)
    for k,v in pairs(self.m_material_data_list) do
        local m_data = k
        if m_data == data then
            return v
        end
    end
    return 0
end

--移除一件装备
function M:removeCheckEqp(data)
    local nums = self:getMinNums(data)
    if self.m_material_data_list[data] and self.m_material_data_list[data] > nums then
        self.m_material_data_list[data] = self.m_material_data_list[data] - nums
    else
        self.m_material_data_list[data] = nil
    end
end

--通过材料列表来计算结果列表
function M:countResultItem()
    self.m_result_data_list = {}
    for k,v in pairs(self.m_material_data_list) do
        local cur_type_cfg = self.m_awaken_recycle[k.data_type]
        if k.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM or k.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
            -- 道具类型
            local item_id = k.data_id
            for k1, v2 in pairs(cur_type_cfg) do
                if v2.item_id == tonumber(item_id) then
                    self:addRewardList(v2.exchange_item,v,k)
                end
            end
        elseif k.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
            -- 装备
            if self.can_show_equip_quality[k.quality] then   --如果存在品质匹配  就去匹配Race
                if k.race == 0 then
                    for k1, v2 in pairs(cur_type_cfg) do
                        if v2.quality == k.quality and v2.item_id == 0 then
                            self:addRewardList(v2.exchange_item,v,k)
                            break
                        end
                    end
                else
                    for k1, v2 in pairs(cur_type_cfg) do
                        if v2.quality == k.quality and v2.item_id == 1 then
                            self:addRewardList(v2.exchange_item,v,k)
                            break
                        end
                    end
                end
            end
        elseif k.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS then
            -- 侠客
            if self.can_show_hero_quality[k.hero_data.evo] then --是匹配的品质，那么去看基础的种族
                local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(k.card_id) --
                if hero_data and hero_cfg then
                    local init_evo = hero_cfg.evo
                    local hero_race = hero_cfg.race
                    for k2,v2 in pairs(cur_type_cfg) do
                        if init_evo == v2.item_id[1] and hero_race == v2.item_id[2] and v2.quality == k.hero_data.evo then
                            self:addRewardList(v2.exchange_item,v,k)
                            break
                        end
                    end
                                  
                end
            end
        end
    end
    local final = self.m_result_data_list
end

function M:addRewardList(data,nums,ori_data)
    local id = data[2]
    local data_nums = nums
    local nums_pre = self:getMinNums(ori_data)
    local final_nums = math.floor(nums/nums_pre)
    local new_data = table.copy(data)
    for k3, v3 in pairs(new_data) do
        local key = v3[2]
        v3[3] = v3[3] * final_nums 
        if self.m_result_data_list[key] then
            self.m_result_data_list[key][3] = self.m_result_data_list[key][3] + v3[3]
        else
            self.m_result_data_list[key] = v3
        end
    end
end

function M:dealWithItemForServer()
    local ori_data = table.copy(self.m_material_data_list)
    local final_data = {}
    for type,can in pairs(self.can_show_type) do
        final_data[tostring(type)] = {}
    end
    for k,v in pairs(ori_data) do 
        local cur_type_list = final_data[tostring(k.data_type)] 
        if k.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
            cur_type_list[k.data_id] = v
        elseif k.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
            cur_type_list[k.oid] = v
        elseif k.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
            cur_type_list[k.oid] = v
        elseif k.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS then
            cur_type_list[k.card_id] = v
        end
     --  table.insert(final_data[tostring(k.data_type)],data)
    end
    return final_data
end

--获取最小的数量
function M:getMinNums(data)
    local nums = 1
    if data.data_type ~= RewardUtil.REWARD_TYPE_KEYS.ITEM then
        nums = 1
    else
        local cur_type_cfg = self.m_awaken_recycle[data.data_type]
        local item_id = data.data_id
        for k1, v2 in pairs(cur_type_cfg) do
            if v2.item_id == tonumber(item_id) then
                nums = v2.num
            end
        end
    end
    return nums
  
end

return M