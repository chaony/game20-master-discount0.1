--- 竞技场结算 成功
local M = class("SettlementWorldBossWinNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementWorldBossWinNode"
M.bossHpColor = {
    Color(206/255,165/255,85/255,1),  --黄色
    Color(85/255,168/255,206/255,1),  -- 天蓝
    Color(167/255,85/255,206/255,1),  -- 紫色
    Color(206/255,85/255,85/255,1),   -- 红色
}
function M:onEnter()
    self.value_slider = self:findSlider("value_slider")
    self.m_silder_fill = self:findImage("Fill")
    self.m_silder_bg = self:findImage("damage_bg_img")
    self.m_silder_bg.color.a = 0
    self.value_text = self:findText("value_text")
    self.bosshead_tx_img = self:findGameObject("bosshead_tx_img")
    self.m_boss_max_hp = self.m_model.m_data.max_hp
    self.m_boss_hp_cid = self.m_model.m_data.boss_hp_cid
    self:refreshUI()
    self:showReward()
    self.color = Color(0,0,0,0)
end

function M:refreshUI()
    local data = self.m_model.m_data
    local new_bg_img = self:findGameObject("new_bg_img")
    new_bg_img:SetActive(data.max_damage_change == 1)
    -- self.value_text.gameObject:SetActive(false)
    self:setTextByLanKey("max_harm_text", "world_boss_str_0019")
    self:setTextByLanKey("new_bg_text", "xin_jl_text")
    self:setTextByLanKey("reward_title_text", "hunt_treasure_str_036")
    self:setTextByLanKey("return_btn_text", "new_str_0478")
    local max_damage = self:getMaxDamage()
    self:setText("max_value_text", max_damage)
    local next_dan_1_text = self:findText("next_dan_1_text")
    local next_dan_2_text = self:findText("next_dan_2_text")
    if data.pre_mix_damage and data.pre_mix_damage ~= -1 then
        next_dan_1_text.text = string.format(Language:getTextByKey("world_boss_str_0020"), data.pre_mix_damage)
    else
        self:setObjectVisible("next_dan_1_text", false)
    end
    self:setTextByLanKey("treasure_box_text", tostring(self.m_model.m_data.chest_count or 0))
    self:setObjectVisible("next_reward_text", false)
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
        self:setObjectVisible("treasureHead", false)
        self.hero_train= ConfigManager:getCfgByName("train_challenge")
        self.hero_train_cfg = self.hero_train[self.m_model.m_boss_id or 1] or {}
        local hero_detail = ConfigManager:getCfgByName("hero_detail");
        local hero_data = hero_detail[self.hero_train_cfg.hero_id];
        UIUtil.setImg(self.bosshead_tx_img, hero_data.icon, "hero_head_ui")
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then
        self:setObjectVisible("treasureHead", false)
        self.hero_train= ConfigManager:getCfgByName("mood_shadow_stage")
        self.hero_train_cfg = self.hero_train[self.m_model.m_boss_id or 1] or {}
        local hero_detail = ConfigManager:getCfgByName("hero_detail");
        local hero_data = hero_detail[self.hero_train_cfg.boss_show];
        UIUtil.setImg(self.bosshead_tx_img, hero_data.icon, "hero_head_ui")
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW then
        self:setObjectVisible("treasureHead", false)
        self.hero_train= ConfigManager:getCfgByName("hero_event_stage")
        self.hero_train_cfg = self.hero_train[self.m_model.m_boss_id or 1] or {}
        local hero_detail = ConfigManager:getCfgByName("hero_detail");
        local hero_data = hero_detail[self.hero_train_cfg.boss_show];
        UIUtil.setImg(self.bosshead_tx_img, hero_data.icon, "hero_head_ui") 
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
        self:setObjectVisible("treasureHead", false)
        self.hero_train= ConfigManager:getCfgByName("chivalrous_practice_stage")
        self.hero_train_cfg = self.hero_train[self.m_model.m_boss_id or 1] or {}
        local hero_detail = ConfigManager:getCfgByName("hero_detail");
        local hero_data = hero_detail[self.hero_train_cfg.boss_show];
        UIUtil.setImg(self.bosshead_tx_img, hero_data.icon, "hero_head_ui")  
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
        self:setObjectVisible("treasureHead", false)
        self.hero_train= ConfigManager:getCfgByName("active_train")
        self.hero_train_cfg = self.hero_train[self.m_model.m_params.open_id][self.m_model.m_params.version][self.m_model.m_boss_id or 1] or {}
        local hero_detail = ConfigManager:getCfgByName("hero_detail");
        local hero_data = hero_detail[self.hero_train_cfg.boss_show];
        UIUtil.setImg(self.bosshead_tx_img, hero_data.icon, "hero_head_ui") 
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD then
        self:setObjectVisible("treasureHead", false)
        self.hero_train= ConfigManager:getCfgByName("evil_shadow_stage")
        self.hero_train_cfg = self.hero_train[self.m_model.m_boss_id or 2] or {}
        local hero_detail = ConfigManager:getCfgByName("hero_detail");
        local hero_data = hero_detail[self.hero_train_cfg.boss_show]
        UIUtil.setImg(self.bosshead_tx_img, hero_data.icon, "hero_head_ui")
    else
        self:refreshNextRewardText()
        local world_boss = ConfigManager:getCfgByName("world_boss")
        local world_boss_item = world_boss[self.m_model.m_boss_id or 1] or {}
        local boss_icon = world_boss_item.boss_icon or "a_sjbs_bosstouxiang"
        UIUtil.setImg(self.bosshead_tx_img, boss_icon, "battle_ui")
    end
        --local dan_data, next_dan_data = self:getDanData()
        ---- self:setTextByLanKey("dan_text", dan_data.division_name)
        --local ArenaSegmentNode = self:findGameObject("ArenaSegmentNode")
        --CommonUIUtil:setSegmentInfo(ArenaSegmentNode, dan_data, true)
        --local luaBehaviour = UIUtil.findLuaBehaviour(ArenaSegmentNode)
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "segment_rank_text" , false)

        --if data.pre_mix_damage == -1 then
        --    next_dan_2_text.gameObject:SetActive(false)
        --    next_dan_2_text.text = string.format(Language:getTextByKey("world_boss_str_0022"), Language:getTextByKey(dan_data.division_name))
        --else
        --    local dan_name = Language:getTextByKey(next_dan_data.division_name)
        --    if next_dan_data.star_num and next_dan_data.star_num > 0 then
        --        dan_name = dan_name .. next_dan_data.star_num
        --    end
        --    next_dan_2_text.text = string.format(Language:getTextByKey("world_boss_str_0021"), dan_name)
        --end
        --local boss_user = self.m_model:getUserInfoBySort(2)
        --local boss_head = self:findGameObject("boss_head")
        --GameUtil:setUserAvatar(boss_head, boss_user)
end

function M:getNewBossRewardCfg()
    local world_boss_reward_cfg = ConfigManager:getCfgByName("world_boss_rewards")
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS and world_boss_reward_cfg and next(world_boss_reward_cfg) and world_boss_reward_cfg[self.m_model.m_boss_id] then
        local reward_data = world_boss_reward_cfg[self.m_model.m_boss_id][self.m_boss_hp_cid]
        return reward_data.reward_lost_hp
    end
    return {}
end

function M:showOverWord()
    self:setObjectVisible("return_btn", false)
end

function M:refreshNextRewardText()
    local need_damage, is_max = self:getNextRewardDamage()
    if is_max then
    else
        self:setObjectVisible("next_reward_text", true)
        self:setTextByLanKey("next_reward_text", "world_boss_str_0034", GameUtil:formatValueToString(need_damage))
    end
end

function M:getNextRewardDamage()
    local world_boss_cfg = ConfigManager:getCfgByName("world_boss")
    local world_boss_cfg_item = world_boss_cfg[self.m_model.m_boss_id or 1] or {}
    local reward_lost_hp = world_boss_cfg_item.reward_lost_hp or {}
    if next(self:getNewBossRewardCfg()) then
        reward_lost_hp = self:getNewBossRewardCfg()
    end
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
        world_boss_cfg = ConfigManager:getCfgByName("train_challenge")
        world_boss_cfg_item = world_boss_cfg[self.m_model.m_boss_id or 1] or {}
        reward_lost_hp = world_boss_cfg_item.lost_hp or {}
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then
        world_boss_cfg = ConfigManager:getCfgByName("mood_shadow_stage")
        world_boss_cfg_item = world_boss_cfg[self.m_model.m_boss_id or 1] or {}
        reward_lost_hp = world_boss_cfg_item.lost_hp or {}
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW then
        world_boss_cfg = ConfigManager:getCfgByName("hero_event_stage")
        world_boss_cfg_item = world_boss_cfg[self.m_model.m_boss_id or 1] or {}
        reward_lost_hp = world_boss_cfg_item.lost_hp or {}
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
        world_boss_cfg = ConfigManager:getCfgByName("chivalrous_practice_stage")
        world_boss_cfg_item = world_boss_cfg[self.m_model.m_boss_id or 1] or {}
        reward_lost_hp = world_boss_cfg_item.lost_hp or {} 
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
        world_boss_cfg = ConfigManager:getCfgByName("active_train")
        world_boss_cfg_item = world_boss_cfg[self.m_model.m_params.open_id][self.m_model.m_params.version][self.m_model.m_boss_id or 1] or {}
        reward_lost_hp = world_boss_cfg_item.lost_hp or {}
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD then
        world_boss_cfg = ConfigManager:getCfgByName("evil_shadow_stage")
        world_boss_cfg_item = world_boss_cfg[self.m_model.m_boss_id or 2] or {}
        reward_lost_hp = world_boss_cfg_item.lost_hp or {}
    end
    local cur_damage = self.m_model.m_damage
    local cur_index = 1
    local need_damage = 0
    local is_max = true
    for i, v in ipairs(reward_lost_hp) do
        if cur_damage < v then
            cur_index = i
            is_max = false
            break
        end
    end
    local hp_value = 1
    if self.m_boss_max_hp and cur_damage >= self.m_boss_max_hp then
        is_max = true
    end
    if not(is_max) then 
        local front_value = 0
        if cur_index-1 > 0 and cur_index-1 <= table.nums(reward_lost_hp) then
            front_value = reward_lost_hp[cur_index-1]
        end 
        need_damage = reward_lost_hp[cur_index] - cur_damage
        hp_value = math.min(1, (cur_damage - front_value) / reward_lost_hp[cur_index])
    end
    return need_damage, is_max, hp_value
end

function M:getDanData()
    local world_boss_reward = ConfigManager:getCfgByName("world_boss_reward")
    local dan = self.m_model.m_data.self_rank or 999
    local next_dan = dan

    local table_key = {}
    for k,v in pairs(world_boss_reward) do
        table_key[#table_key + 1] = k
    end
    local function sort(data1, data2)
        return data1 < data2
    end
    table.sort(table_key,sort)
    local index = table.bisect(table_key, dan)

    local damage = self:getMaxDamage()
    for i=index, #table_key do
        dan = table_key[i]
        local dan_data = world_boss_reward[dan]
        if dan_data.min_damage <= damage then
            index = i
            break
        end
    end

    dan = table_key[index]
    next_dan = table_key[index - 1] or 0
    return world_boss_reward[dan], world_boss_reward[next_dan]
end

function M:getMaxDamage()
    local max_damage = self.m_model.m_data.max_damage or 0

    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
        max_damage = self.m_model.m_data.last_damage or 0
    end
    --if self.m_model.m_data.damage_log then
    --    for i,v in ipairs(self.m_model.m_data.damage_log) do
    --        local damage = v.damage or 0
    --        if damage > max_damage then
    --            max_damage = damage
    --        end
    --    end
    --else
    --    max_damage = self.m_model.m_data.damage or 0
    --end
    return max_damage
end

function M:getSliderColor(cur_index)
    self.value_slider.value = 0
    self.m_silder_bg.color = self.color
    self.lastnum = 0
    local num = cur_index  % #self.bossHpColor
    if num <= 0  then
        if self.lastnum > #self.bossHpColor then
            self.lastnum = 1
        end
        num = self.lastnum +1
    end
    self.lastnum = num
    if num > #self.bossHpColor  then
        num = num - #self.bossHpColor
    end
    self.color = self.m_silder_fill.color
    self.color.a = 1
    self.m_silder_fill.color = self.bossHpColor[num]
end

function M:sliderAnim()
    --local world_boss_cycle = ConfigManager:getCfgByName("world_boss_cycle")
    --local world_cfg = world_boss_cycle[self.m_model.m_data.battle_config_id]
    local world_boss = ConfigManager:getCfgByName("world_boss")
    local world_cfg = world_boss[self.m_model.m_boss_id or 1] or {}
    local _, _, hp_value = self:getNextRewardDamage()

    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE then
        world_boss = ConfigManager:getCfgByName("train_challenge")
        world_cfg = world_boss[self.m_model.m_boss_id or 1] or {}
        hp_value = 1
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY then
        world_boss = ConfigManager:getCfgByName("mood_shadow_stage")
        world_cfg = world_boss[self.m_model.m_boss_id or 1] or {}
        hp_value = 1
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW then
        world_boss = ConfigManager:getCfgByName("hero_event_stage")
        world_cfg = world_boss[self.m_model.m_boss_id or 1] or {}
        hp_value = 1 
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
        world_boss = ConfigManager:getCfgByName("chivalrous_practice_stage")
        world_cfg = world_boss[self.m_model.m_boss_id or 1] or {}
        hp_value = 1 
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE then
        world_boss = ConfigManager:getCfgByName("active_train")
        world_cfg = world_boss[self.m_model.m_params.open_id][self.m_model.m_params.version][self.m_model.m_boss_id or 1] or {}
        hp_value = 1
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD then
        world_boss = ConfigManager:getCfgByName("evil_shadow_stage")
        world_cfg = world_boss[self.m_model.m_boss_id or 2] or {}
        hp_value = 1
    else
        self.m_silder_fill.color = self.bossHpColor[4]
    end
    local max_damage = self.m_model.m_damage
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
        max_damage = self.m_model.m_data.last_damage or 0
    end
    if world_cfg then
        local lost_hp = (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE or  self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW 
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD 
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE 
                or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS) and world_cfg.lost_hp or world_cfg.reward_lost_hp
        local sliderFun = nil
        local old_hp = 0
        local slider_anim_time = 2
        sliderFun = function ()
            --local value = math.min(max_damage/lost_hp[index],1)
            Tweening.DOTween.To(function (v)
                local text = math.floor(v)
                self.value_text.text = text
            end, old_hp, max_damage, slider_anim_time)
            self.value_slider.value = 0
            local sequence = Tweening.DOTween.Sequence()
            if self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.ACTIVE 
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.FIVE_ARRAY 
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.EVIL_SHADOW 
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.DRAGONSWORD 
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.COMMON_BATTLE 
                    and self.m_model.m_mode ~= GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
                for i = 1, self.m_model.m_data.chest_count + 1 do
                    if i == self.m_model.m_data.chest_count + 1 then
                        self.value_slider.value = 0
                        sequence:Append(DOTweenModuleUI.DOValue(self.value_slider, hp_value, 0.5))
                    else
                        sequence:Append(DOTweenModuleUI.DOValue(self.value_slider, 1, slider_anim_time / self.m_model.m_data.chest_count))
                        sequence:AppendCallback(function()
                            self:getSliderColor(i)
                        end)
                    end
                end
            else
                sequence:Append(DOTweenModuleUI.DOValue(self.value_slider, hp_value, slider_anim_time))
            end
           
            sequence:OnComplete(function()
                self.value_text.text = tostring(max_damage)
            end)
            sequence:SetAutoKill(true)
            self.m_sequence = sequence
        end
        sliderFun()
    end
end

--[[
    奖励列表
]]
function M:showReward()
    local reward_grid = self:findGameObject("reward_grid")
    local reward = self.m_model.m_rewards or {}
    local num = #reward
    for i = 1, num do
        local data = reward[i]
        local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
        local item = GameUtil:createItemElement(data, showNum, true)
        item.transform:SetParent(reward_grid.transform, false)
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
            local itemLuabehaviour = UIUtil.findLuaBehaviour(item)
            local show_flag = false
            if GameUtil:checkDoubleActiveByType(6) == true then
                show_flag = true
            end
            LuaBehaviourUtil.setObjectVisible(itemLuabehaviour, "double_earn", show_flag)
        end
    end
end

function M:destroy()
    if not IsNull(self.m_sequence) then
        self.m_sequence:Kill()
        self.m_sequence = nil
    end
    M.super.destroy(self)
end

return M