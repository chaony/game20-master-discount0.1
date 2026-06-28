---
---@class AwakeSystemMainModel:OODataBase
local M = class("AwakeSystemMainModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("awaken_index")
end

function M:onEnter()
    self.m_current_mode = 0  --此时的状态  0未选中侠客 1羽化阶段 2登仙阶段
    self.m_first = true  --记一个mode  是否发生改变
    self.m_last_mode = true
    self.m_currentHeroIndex = 0 --当前选中的heroid
    self.m_cur_hero_id = 0
    self.m_select_id = 0
    self:initCfg()
    self:initData(self.m_data)
end

function M:initCfg()
    self.m_last_god = {}
    self.m_awaken_cfg = ConfigManager:getCfgByName("awaken")  --开启羽化的配置
    self.m_awaken_fly_cfg = ConfigManager:getCfgByName("awaken_fly")  --羽化阶段的配置
    self.m_awaken_god_cfg = ConfigManager:getCfgByName("awaken_god")  --登仙阶段的配置
    self.m_item_cfg = ConfigManager:getCfgByName("item")  --item
    self.m_card_hero_cfg = ConfigManager:getCfgByName("card_hero")  
    self.m_cur_god_cost_cfg = {}
end

function M:initData(data,func)
    self.m_cur_hero_id = data.cur_hero_id or 0
    self.m_fly = data.fly or {}
    self.m_fly_quests = data.fly_quests or {}
    self.m_fly_heros = data.fly_heros or {}
    self.m_god = data.god or {}
    self.m_god_cost_add = data.god_cost_add or 0
    self.m_god_friend_add = data.god_friend_rate or {}
    self.m_god_fail_rate = data.god_fail_rate or 0
    self.m_god_god_heros = data.god_heros or {}
    self.m_god_daily_times = data.god_daily_times or 0
    self.m_god_daily_remain_times = data.god_daily_remain_times or 0
    self.m_can_fly_heros = data.heros or {}
    self.m_skills = data.skills or {}
    self.m_stage_data = data.stage_data or {}
    self.m_fly_quests_finish_all = data.fly_quests_finish_all  --如果一个侠客，羽化任务完成提交了一组，那么今天就不能切换了
    self:dealState()
    self:getEquipData()
    if self.m_cur_hero_id ~= 0 and self.m_currentHeroIndex == 0 then
        for k,v in ipairs(self.m_can_fly_heros) do
            local id = string.sub(tostring(v),1,3)
            if tonumber(id) == self.m_cur_hero_id then
                self.m_currentHeroIndex = v
                break
            end
        end         
    end
    if type(func) == "function" then
        func()
    end
end

function M:resetHeroFlyLevel(data)
    local need_data = data.data or {}
    local update_data = need_data.update or {} 
    for k,v in pairs(update_data) do
        self.m_fly_heros[k] = v
    end     
end

function M:resetState()
    self.m_last_mode = true
    self.m_current_mode = 0
end

function M:dealState()
    local pre_mode = self.m_current_mode 
    if self.m_cur_hero_id == 0 then
        self.m_current_mode = 0
    else
        if self.m_god_god_heros[tostring(self.m_cur_hero_id)] then
            self.m_current_mode = 2
        elseif self.m_fly_heros[tostring(self.m_cur_hero_id)] then
            self.m_current_mode = 1
        else
            self.m_current_mode = 0
            Logger.log("有问题啊,不在上面的列表里,找个服务器大哥查一查")
        end
    end    
    local next_mode = self.m_current_mode
    if self.m_first then
        self.m_first = false
    else
        self.m_last_mode = pre_mode ~= next_mode 
    end
end

function M:getCanFlyHeros()
    local function checkoutCallback(response)
        if response then
            self.m_can_fly_heros = response or {}
        end
    end
    self:getNetData("awaken_get_heros", nil, checkoutCallback)
end

--判断当前选中的有没有羽化
function M:countCurHeroFly()
    if self.m_currentHeroIndex ~= 0 then
        local data,_ = self:getSelectHeroData(self.m_currentHeroIndex)
        for k,v in pairs(self.m_fly_heros) do
            if tonumber(k) == data.id then
                return true
            end
        end
        return false    
    end
    return false
end

--判断当前选中是否在渡劫
function M:countCurHeroGod()
    if self.m_currentHeroIndex ~= 0 then
        local data,_ = self:getSelectHeroData(self.m_currentHeroIndex)
        for k,v in pairs(self.m_god_god_heros) do
            if tonumber(k) == data.id then
                return true
            end
        end
        return false
    end
    return false
end

--判断是否可以渡劫
function M:getCanGodFlag()
    local name = {"exp_body","exp_heart","exp_soul"}
    local cur_fly_cfg,cur_fly_level = self:getCurGodCfg()
    if cur_fly_cfg and cur_fly_level then
        local cur_cfg = cur_fly_cfg[cur_fly_level.lv]
        for i = 1,3 do
            local value = self.m_god[name[i]] or 0
            local cfg_calue = cur_cfg[name[i]] or 100
            if value ~= cfg_calue then
                return false
            end
        end
        return true
    end
    return false
end

function M:getLastLevel(cfg)
    local level = 0
    for k1,v1 in pairs(cfg) do
        if v1.next == 0 then
            level = k1
        end
    end
    return level
end

--返回当前的渡劫配置
function M:getCurGodCfg()
    local god_cfg = {}
    local data1, cfg = self:getSelectHeroData(self.m_currentHeroIndex)
    local hero_id = data1.id
    god_cfg = table.copy(self.m_awaken_god_cfg[hero_id])
    local god_level = self.m_god_god_heros[tostring(hero_id)]
    return god_cfg,god_level
end

--计算渡劫成功率   配置的  好友助力的  失败的
function M:getGodRate()
    local cfg_rate,friend_rate,fail_rate
    local cur_fly_cfg,cur_fly_level = self:getCurGodCfg()
    local cur_cfg = cur_fly_cfg[cur_fly_level.lv]
    if self.m_currentHeroIndex ~= 0 and cur_cfg then
        cfg_rate = cur_cfg.success_rate or 0
        local nums = table.nums(self.m_god_friend_add)
        friend_rate = math.min(cur_cfg.friend_rate * nums,cur_cfg.friend_rate_max)
        fail_rate = self.m_god_fail_rate 
    end
    return cfg_rate*100,friend_rate*100,fail_rate*100
end

function M:getEquipData()
    self.m_show_data = {}
    GameUtil:insertEquipsData(self.m_show_data)
end

--通过装备id  来获取背包里同一类型的装备
function M:getNeedEquipData(equip_id)
    local  need_equip_data = {}
    for k,v in pairs(self.m_show_data) do
        if v.data_id == equip_id then
            local equip_data = UserDataManager.equip_data:getEquipDataById(v.oid)
            if equip_data then
                local attrs = UserDataManager:appendAttrs(UserDataManager:getEquipAttrsByData(equip_data, v.item_cfg))
                local combat = UserDataManager:computeEquipCombat(attrs)
                v.combat = combat
                table.insert(need_equip_data,v)                
            end
        end
    end
    
    local function sortFun(data1, data2)
        local equip_data1 = UserDataManager.equip_data:getEquipDataById(data1.oid)
        local equip_data2 = UserDataManager.equip_data:getEquipDataById(data2.oid)
        local lv1 = equip_data1.lv
        local lv2 = equip_data2.lv
        local combat1 = data1.combat
        local combat2 = data2.combat
        local quality1, quality2 = data1.item_cfg.quality, data2.item_cfg.quality
        if quality1 == quality2 then
            if lv1 ==lv2 then
                return combat1 < combat2
            else
                return lv1 < lv2
            end
        else
           return quality1 < quality2 
        end
    end
    table.sort(need_equip_data,sortFun)
    return need_equip_data[1] or {}
end

--获取所有英雄
function M:getAllHeroIds()
    local ids = table.copy(UserDataManager.hero_data:getHerosId())
    UserDataManager.hero_data:heroIdsSort(ids, "team")
    return ids
end

--获取材料卡消耗本卡
function M:getEvoSixHeroList(card_hero_id)
    local cur_card_hero_cfg = self.m_card_hero_cfg[card_hero_id]
    local evo_isSix_hero = {}
    if cur_card_hero_cfg then
        local hero_id = cur_card_hero_cfg.hero_id
        local need_evo = cur_card_hero_cfg.hero_evo
        local all_hero = self:getAllHeroIds()
        for i, v in pairs(all_hero) do
            local data, cfg = UserDataManager.hero_data:getHeroDataById(v)
            if data.evo == need_evo and data.id == hero_id then
                table.insert(evo_isSix_hero,{data = data,cfg = cfg})
            end
        end 
    end
    return evo_isSix_hero
end

function M:dealWithItemForServer()
    local ori_data = table.copy(self.m_cur_god_cost_cfg)
    local final_data = {}
    local can_flag = true
    if not self:getCanGodFlag() then
        can_flag = false
        return can_flag
    end
    for k,v in pairs(ori_data) do
        final_data[tostring(v[1])] = {}
    end
    for k,v in pairs(ori_data) do
        if v[1] == RewardUtil.REWARD_TYPE_KEYS.ITEM then
            final_data[tostring(v[1])][tostring(v[2])] = v[3]
            local consItem = RewardUtil:getProcessRewardData(v)
            can_flag = consItem.user_num >= consItem.data_num
        elseif v[1] == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
            final_data[tostring(v[1])][(v[2])] = v[3]
        --elseif v[1] == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
          --  final_data[v[1]][(v[2])] = v[3]
        elseif v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
            local material_list = self:getEvoSixHeroList(v[2])
            if next(material_list)~= nil then
                final_data[tostring(v[1])][material_list[1].data.oid] = v[3]
            else
                can_flag = false
            end
        end
    end
    return final_data,can_flag
end

function M:getSelectHeroData(index)
    local data,cfg = UserDataManager.hero_data:getHeroDataById(index) 
    return data,cfg
end

function M:checkSkillLv4Unlock(skillIndex)
    local meridians_cultivation_cfg=ConfigManager:getCfgByName("meridians_cultivation")
    local index_cfg=nil
    --local h_data, h_cfg = self:getSelectHeroData(self.m_currentHeroIndex)

    for i, v in pairs(meridians_cultivation_cfg) do
        if v.open_maxlv_skill_index then
            if v.open_maxlv_skill_index==skillIndex then
                index_cfg=v
                index_cfg.id=i
            end
        end
    end

    local clv=self:getHero_lv()
    local sig_deep =self:get_sig_deep()
    local unlock=clv>=index_cfg.hero_lv_limit and sig_deep>=index_cfg.id
    return unlock
end

function M:get_sig_deep()
    local sig_deep=0

    local h_data, h_cfg = self:getSelectHeroData(self.m_currentHeroIndex)
    if h_data then
        local sig = h_data.sig or {}
        local sig_data = sig["1"]
        if sig_data then
            sig_deep=sig_data.deep or 0
        end

    end
    return sig_deep
end

function M:getHero_lv()
    local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
    local h_data, cfg = self:getSelectHeroData(self.m_currentHeroIndex)
    if h_data and h_data.clv > 0 then
        local upgrade_cfg = hero_upgrade[tonumber(h_data.clv )]
        if self.m_cur_Lv == nil then
            self.m_cur_Lv = upgrade_cfg.display_level or 1
        end
        return upgrade_cfg.display_level
    end
    if self.m_cur_Lv == nil then
        if h_data then
            self.m_cur_Lv = h_data.lv or 1
        else
            self.m_cur_Lv = 1
        end
    end
    local upgrade_cfg = hero_upgrade[tonumber(self.m_cur_Lv)]
    if upgrade_cfg then
        return upgrade_cfg.display_level
    else
        return 1
    end
end
--获取消耗的道具是否足够
function M:getFlyItemFlag()
    if self:countCurHeroFly()  then
        return false
    else
        local data, cfg = self:getSelectHeroData(self.m_currentHeroIndex)
        local cur_cfg = self.m_awaken_cfg[data.id]
        local consItem = RewardUtil:getProcessRewardData(cur_cfg.cost[1])
        return consItem.user_num < consItem.data_num 
    end
end


function M:getHeroid(index)
    local data,cfg = UserDataManager.hero_data:getHeroDataById(index)
    return data.id
end

return M
