------------ DataUpdateHandlers
--[[
    方法名对应client_cache_update中的key
    数组的返回所有，字典的返回变化的数据
    值和数组直接替换数据
]]

local M = {}

-- 英雄数据更新
function M.hero(udm, key, data)
	local hero_data = udm.hero_data
    local heros = data.heros
    local cfg_heros = data.cfg_heros
    if data.rollback_buy_times then
        udm.m_rollback_buy_times = data.rollback_buy_times
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "update_rollback_times"})
    end
    if data.reset_times then
        udm.reset_times = data.reset_times
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "update_reset_times"})
    end
    if heros then
        local update_data = heros.update
        local remove_data = heros.remove
        hero_data:updateMoreHeroData(update_data)
        if #remove_data > 0 then
            hero_data:removeMoreHeroDataById(remove_data)
        end
        hero_data:resetSigRedPointData()
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "heros_update", data = heros})
    end
    if cfg_heros then
        local update_data = cfg_heros.update
        local remove_data = cfg_heros.remove
        for k,v in pairs(update_data) do
            udm.cfg_heros_data[k] = v
        end
    end
    local level_top = data.level_top
    if level_top then
        hero_data:setLevelTop(level_top)
    end
    local crystal_slot = data.crystal_slot
    if crystal_slot then
        hero_data:setCrystalSlot(crystal_slot)
    end
    local fates = data.fates
    if fates then
        local update_data = fates.update
        if update_data then
            table.merge(udm.fates, update_data)
        end
        local remove_data = fates.remove
        if remove_data then
            for i, v in ipairs(remove_data) do
                udm.fates[tostring(v)] = nil
            end
        end
    end

    local fate_building_data = data.fate_building
    if fate_building_data then
        local update_data = fate_building_data.update or {}
        table.merge(udm.m_fate_building, update_data)
        local remove_data = fate_building_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.m_fate_building[tostring(v)] = nil
        end
        --EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "richman_update", data = quests_data})
    end

    local fate_master_data = data.fate_master
    if fate_master_data then
        local update_data = fate_master_data.update or {}
        table.merge(udm.m_fate_master, update_data)
        local remove_data = fate_master_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.m_fate_master[tostring(v)] = nil
        end
        --EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "richman_update", data = quests_data})
    end

    -- 镶嵌秘籍 在hero看着有点怪-可能后端取着方便吧
    local mystic_data = udm.mystic_data
    local mystic = data.mystic
    if mystic then
        local update_data = mystic.update
        local remove_data = mystic.remove
        mystic_data:updateInlayMysticData(update_data)
        if #remove_data > 0 then
            mystic_data:removeInlayMysticData(remove_data)
        end
    end
    --战力压制全局部分的变化
    local repress_data = data.combat_repress
    if repress_data then
        local update_data = repress_data.update
        local remove_data = repress_data.remove
        for k,v in pairs(update_data) do
            udm.m_global_repress_data[k] =  v
        end
        if #remove_data > 0 then
            for k,v in pairs(remove_data) do
                udm.m_global_repress_data[k] =  nil
            end
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "combat_repress_update"})
    end
end

--宠物数据更新
function M.pet(udm, key, data)
    local pets = data.pets
    local pet_data = udm.pet_data
    if pets then
        local update_data = pets.update
        local remove_data = pets.remove
        pet_data:updatePetData(update_data)
        if #remove_data > 0 then
            pet_data:removeMorePetDataById(remove_data)
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "pets_update", data = pets})
    end

    local pet_collect = data.collect
    if pet_collect then
        local update_data = pet_collect.update
        pet_data:updateMorePetCollect(update_data)
        local remove_data = pet_collect.remove
        if #remove_data > 0 then
            pet_data:removePetDataById(remove_data)
        end
    end
end

-- 宠物工坊数据更新
function M.pet_factory(udm, key, data)
    local pets = data.pets
    local pet_data = udm.pet_data

    if pets then
        pet_data:updatePetFactoryData(pets)
    end
end

-- 装备数据更新
function M.equip(udm, key, data)
    local equip_data = udm.equip_data
    local equips = data.equips
    local thrones = data.thrones
    local thrones_upgrade = data.thrones_upgrade
    local thrones_phase = data.thrones_phase
    if equips then
        local update_data = equips.update
        local remove_data = equips.remove
        equip_data:updateMoreEquipData(update_data)
        if #remove_data > 0 then
            equip_data:removeMoreEquipDataById(remove_data)
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "equips_update", data = equips})
    end
    if thrones then
        local update_data = thrones.update
        local remove_data = thrones.remove
        table.merge(udm.m_thrones, update_data)
        for i, v in ipairs(remove_data) do
            udm.m_thrones[v] = nil
        end
    end
    if thrones_upgrade then
        local update_data = thrones_upgrade.update
        local remove_data = thrones_upgrade.remove
        table.merge(udm.m_thrones_upgrade, update_data)
        for i, v in ipairs(remove_data) do
            udm.m_thrones_upgrade[v] = nil
        end
    end
    if thrones_upgrade then
        local update_data = thrones_upgrade.update
        local remove_data = thrones_upgrade.remove
        table.merge(udm.m_thrones_upgrade, update_data)
        for i, v in ipairs(remove_data) do
            udm.m_thrones_upgrade[v] = nil
        end
    end
    if thrones_phase then
        local update_data = thrones_phase.update
        table.merge(udm.m_thrones_phase, update_data)
    end
end

-- 装备数据更新
function M.seal_character(udm, key, data)
    local talins_data = udm.talis_data
    local seal_character = data.seal_characters
    if seal_character then
        local update_data = seal_character.update
        local remove_data = seal_character.remove
        talins_data:updateMoreTalisData(update_data)
        if #remove_data > 0 then
            talins_data:removeMoreEquipDataById(remove_data)
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "seal_character_update", data = seal_character})
    end
end

--神器数据更新
function M.artifact(udm, key, data)
    local art_data = udm.artifact_data
    local atrifacts = data.artifacts
    if atrifacts then
        local update_data = atrifacts.update
        local remove_data = atrifacts.remove
        art_data:updateArtifactData(update_data)
        if #remove_data > 0 then
            art_data:removeMoreArtifactDataById(remove_data)
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "artifacts_update", data = atrifacts})
    end
end

-- 道具数据更新
function M.item(udm, key, data)
    local item_data = udm.item_data
    local items = data.items
    local red_packet = data.red_envelope
    if items then
        local update_data = items.update
        local remove_data = items.remove
        item_data:updateMoreItemData(update_data)
        if next(update_data) ~= nil then
            udm:updateClientRedPoint(update_data)
        end 
        if #remove_data>0 then
            item_data:removeMoreItemDataById(remove_data)
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "items_update", data = items})
    end
    if red_packet then
        local update_data = red_packet.update
        local remove_data = red_packet.remove
        if next(update_data) then
            for k, v in pairs(update_data) do
                udm.red_packet_data[k] = v
            end
        end
        if next(remove_data) then
            for k, v in pairs(remove_data) do
                udm.red_packet_data[tostring(v)] = nil
            end
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "red_packet_update", data = red_packet})
    end
end

-- 秘籍数据更新
function M.mystic(udm, key, data)
    local mystic_data = udm.mystic_data
    local mystices = data.mystics
    if mystices then
        local update_data = mystices.update
        local remove_data = mystices.remove
        mystic_data:updateMoreMysticData(update_data, 1)
        if #remove_data > 0 then
            mystic_data:removeMoremysticDataById(remove_data)
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "mystices_update", data = mystices})
    end
    
    local effect_data = data.effect_data
    if effect_data then
        udm.mystic_effect_data = effect_data
    end
end

-- 称号数据更新
function M.title(udm, key, data)
    local title_data = udm.title_data
    local titles = data.titles
    if titles then
        local update_data = titles.update
        local remove_data = titles.remove
        title_data:updateMoreTitleData(update_data, 1)
        if #remove_data > 0 then
            title_data:removeMoreTitleDataById(remove_data)
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "titles_update", data = titles})
    end
    local title_packages = data.packages
    if title_packages then
        local update_data = title_packages.update
        local remove_data = title_packages.remove
        title_data:updateMoreTitlePackageData(update_data)
        if #remove_data > 0 then
            title_data:removeMoreTitlePackageDataById(remove_data)
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "title_packages_update", data = title_packages})
    end
end

function M.hero_team(udm, key, data)
    local hero_data = udm.hero_data
    local teams = data.teams -- 
    if teams then
        local update_data = teams.update
        hero_data:updateTeams(update_data)
        if update_data and update_data.view ~= nil then --只有因设置view队伍而更新时，才发送这个事件，更新挂机展示英雄
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "main_team_update", data = update_data})
        end
    end
    local formation = data.formation -- 编队更新
    if formation then
        local update_data = formation.update
        hero_data:updateFormation(update_data)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "formation_update", data = formation})
    end
    local mult_teams = data.mult_teams -- 多队伍
    if mult_teams then
        local update_data = mult_teams.update
        hero_data:updateMultTeams(update_data)
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "city_team_update", data = mult_teams})
    end

    local deployments = data.deployments -- 单队伍阵法
    if deployments then
        local update_data = deployments.update
        hero_data:updateDeployments(update_data)
    end

    local mult_deployments = data.mult_deployments -- -多队伍阵法
    if mult_deployments then
        local update_data = mult_deployments.update
        hero_data:updateMultDeployments(update_data)
    end

    local normal_arrays = data.normal_arrays -- 单队伍阵法（新）
    if normal_arrays then
        local update_data = normal_arrays.update
        local remove_data = normal_arrays.remove
        for k, v in pairs(update_data) do
            udm.m_normal_array[k] = v
        end
        for k,v in pairs(remove_data) do
            udm.m_normal_array[tostring(v)] = nil
        end
    end

    local mult_normal_arrays = data.mult_normal_arrays -- -多队伍阵法（新）
    if mult_normal_arrays then
        local update_data = mult_normal_arrays.update
        local remove_data = mult_normal_arrays.remove
        for k, v in pairs(update_data) do
            udm.m_mult_normal_array[k] = v
        end
        for k,v in pairs(remove_data) do
            udm.m_mult_normal_array[tostring(v)] = nil
        end
    end
    
    local mult_relics = data.mult_relics -- -多队伍法宝
    if mult_relics then
        local update_data = mult_relics.update
        local remove_data = mult_relics.remove
        for k, v in pairs(update_data) do
            udm.m_mult_relics[k] = v
        end
        for k,v in pairs(remove_data) do
            udm.m_mult_relics[tostring(v)] = nil
        end
    end

    local battle_pet = data.battle_pet
    if battle_pet then
        udm.m_battle_pet = battle_pet
    end

    local mult_battle_pet = data.mult_battle_pet
    if mult_battle_pet then
        local update_data = mult_battle_pet.update
        local remove_data = mult_battle_pet.remove
        for k, v in pairs(update_data) do
            udm.m_mult_battle_pet[k] = v
        end
        for k,v in pairs(remove_data) do
            udm.m_mult_battle_pet[tostring(v)] = nil
        end
    end
end

--羁绊
function M.hero_friend(udm, key, data)
    local active_links = data.active_links
    local can_rcvd = data.can_rcvd
    if active_links then
        local update_data = active_links.update
        local remove_data = active_links.remove
        for k,v in pairs(update_data) do
            udm.active_links[k] = v
        end
    end
    if can_rcvd then
        local update_data = can_rcvd.update
        local remove_data = can_rcvd.remove
        for k,v in pairs(update_data) do
            udm.can_rcvd[k] = v
        end
        for k,v in pairs(remove_data) do
            udm.can_rcvd[tostring(v)] = nil
        end
    end
end

--法宝
function M.relic(udm, key, data)
    local relics = data.relics
    local slots = data.slots
    if relics then
        local update_data = relics.update
        local remove_data = relics.remove
        for k,v in pairs(update_data) do
            udm.m_relics[k] = v
        end
        for k,v in pairs(remove_data) do
            udm.m_relics[tostring(v)] = nil
        end
    end
    if slots then
        local update_data = slots.update
        local remove_data = slots.remove
        for k,v in pairs(update_data) do
            udm.m_slots[k] = v
        end
        for k,v in pairs(remove_data) do
            udm.m_slots[tostring(v)] = nil
        end
    end
end

--充值
function M.charge(udm, key, data)
    for k,v in pairs(data) do
        local charge_id = v.charge_id --charge_id
        local reward = v.reward --奖励
        local add_token = v.add_token --充值失败 0 或者没有当前字段 无需处理
        if reward and next(reward) then
            RewardUtil:rewardTipsByData(reward)
        else
            if charge_id then
                if static_rootControl then
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0734"), delay_close = 2})
                end
            end
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHARGE_BACK, {event = "charge", data = v})
    end
end

--特权
function M.subscribe(udm, key, data)
    for k,v in pairs(data) do
        udm.m_subscribe[k] = v
    end
    EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHARGE_BACK, {event = "subscribe", data = v})
end

--特权领取奖励
function M.sub_received(udm, key, data)
    for k,v in pairs(data) do
        udm.m_sub_received[k] = v
    end
    EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.CHARGE_BACK, {event = "subscribe", data = v})
end

function M.stage(udm, key, data)
    local stage_id = data.stage_id
    if stage_id then
        udm.stage_id = stage_id
        udm:updateDeploymentData()
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "stage_update", data = stage_id})
    end

    local chapter_over = data.chapter_over
    if chapter_over ~= nil then
        udm.chapter_over = chapter_over
    end
end

-- 更新爬塔
function M.tower(udm, key, data)
    local cur_floor = data.cur_floor
    if cur_floor then
        udm.tower_floor = cur_floor
    end
end

function M.hero_collect(udm, key, data)
   local hero_data = udm.hero_data
	local collect = data.collect
    if collect then
        local update_data = collect.update
        local remove_data = collect.remove
        hero_data:updateMoreHeroCollect(update_data)
        if #remove_data > 0 then
            
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "heros_update", data = collect})
    end
    local prestige = data.prestige
    if prestige then
        for k,v in ipairs(prestige) do
            udm.m_hero_prestige_data =  prestige
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "hero_prestige", data = prestige})
    end
    
end

-- 更新新手引导
function M.user(udm, key, data)
    local vip_received = data.vip_received
    if vip_received then
        udm.vip_received = vip_received
    end
    -- 头像框
    local frames = data.frames
    if frames then
        udm.frames = frames
    end
     -- 头像
    local avatars = data.avatars
    if avatars then
        udm.avatars = avatars
    end
    -- 表情包
    local emojis = data.emoji -- 表情包
    if emojis then
        local update_data = emojis.update
        local remove_data = emojis.remove
        for k, v in pairs(update_data) do
            udm.m_emoji[k] = v
        end
        for k,v in pairs(remove_data) do
            udm.m_emoji[tostring(v)] = nil
        end
    end
    local hero_roles = data.hero_roles
    if hero_roles then
        local update_data = hero_roles.update
        for k, v in pairs(update_data) do
            udm.hero_roles[k] = v -- 图鉴升级职业属性加成
        end
    end

    -- 更新奇遇数据
    local medals = data.medals
    if udm.m_medals == nil then
        udm.m_medals = {}
    end
    if medals then
        local update_data = medals.update
        local remove_data = medals.remove
        for k, v in pairs(update_data) do
            udm.m_medals[k] = v
        end
        for k,v in pairs(remove_data) do
            udm.m_medals[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "medals_update", data = medals})
    end

    -- 更新主界面背景
    local main_bgs_data = data.main_bgs
    if main_bgs_data then
        for k,v in ipairs(main_bgs_data) do
            table.insert(udm.m_main_bgs,v)
        end
    end
end

-- 动态表情包
function M.emoji(udm, key, data)
    local emojis = data.emoji -- 表情包
    if emojis then
        local update_data = emojis.update
        local remove_data = emojis.remove
        for k, v in pairs(update_data) do
            udm.m_emoji[k] = v
        end
        for k,v in pairs(remove_data) do
            udm.m_emoji[tostring(v)] = nil
        end
    end
end

-- 更新新手引导
function M.guide(udm, key, data)
    local guide = data.guide
    if guide then
        local update_data = guide.update or {}
        --table.merge(udm.guide, update_data)
        for k,v in pairs(update_data) do
            local id = udm.guide[k] or 0
            udm.guide[k] = math.max(id, v)
        end
    end
end

-- 主线任务
-- main_quests : 主线任务
function M.quest(udm, key, data)
    local quests = data.quests
    if quests then
        local main_quests = udm.quest.main_quests or {}
        local update_data = quests.update or {}
        local remove_data = quests.remove or {}
        for k,v in pairs(update_data) do
            v.show_flag = true
        end
        table.merge(main_quests, update_data)
        for k,v in pairs(remove_data) do
            main_quests[tostring(v)] = nil
        end
    end
end

-- 日常和周长任务
-- daily_quests : 日常任务 weekly_quests : 周常任务
function M.quest_time(udm, key, data)
    local daily_quests_data = data.daily_quests
    if daily_quests_data then
        local daily_quests = udm.quest.daily_quests or {}
        local update_data = daily_quests_data.update or {}
        local remove_data = daily_quests_data.remove or {}
        for k,v in pairs(update_data) do
            v.show_flag = true
        end
        table.merge(daily_quests, update_data)
        for k,v in pairs(remove_data) do
            daily_quests[v] = nil
        end
    end
    data.daily_quests = nil

    local weekly_quests_data = data.weekly_quests
    if weekly_quests_data then
        local weekly_quests = udm.quest.weekly_quests or {}
        local update_data = weekly_quests_data.update or {}
        local remove_data = weekly_quests_data.remove or {}
        for k,v in pairs(update_data) do
            v.show_flag = true
        end
        table.merge(weekly_quests, update_data)
        for k,v in pairs(remove_data) do
            weekly_quests[v] = nil
        end
    end
    data.weekly_quests = nil
    table.merge(udm.quest, data)
end

function M.race_tower(udm, key, data)
	local race_floor = udm.race_floor
	local race_floor_data = data.race_floor
    local race_floor_times = udm.race_floor_times
    local today_battle_times_data = data.today_battle_times
    if race_floor_data then
        local update_data = race_floor_data.update
        table.merge(race_floor, update_data)
    end
    if today_battle_times_data then
        local update_data = today_battle_times_data.update
        if next(update_data) == nil then
            race_floor_times = update_data
        else
            table.merge(race_floor_times, update_data)
        end 
    end
end

function M.gift_center(udm, key, data)
    local elite_hero_nums = data.elite_hero_nums
    if elite_hero_nums then
        udm.elite_hero_nums = elite_hero_nums
    end
end

function M.tripods(udm, key, data) -- 神炉
    udm.tripods = data
end

function M.troop_ids(udm, key, data) -- 激活的图书馆羁绊id
    udm.troop_ids = data
end

function M.top_arena(udm, key, data) -- 巅峰赛数据
    local top_arena = data
    udm.m_top_arena = top_arena or {}
    UserDataManager.local_data:setUserDataByKey("top_arena_result", top_arena)
end

function M.top_arena_final(udm, key, data) -- 巅峰赛决赛结果数据
    local top_arena = data
    local server_time = UserDataManager:getServerTime()
    if server_time == nil or data == nil then
        return;
    end
    if server_time > data.end_ts then --超时结束
        return
    end
    udm.top_arena_final = top_arena or {}
    UserDataManager.local_data:setUserDataByKey("top_arena_final", top_arena)
end

function M.red_dot(udm, key, data) -- 红点
    local red_dot_data = data.red_dot
    if red_dot_data then
        local update_data = red_dot_data.update or {}
        table.merge(udm.red_dot, update_data)
        local remove_data = red_dot_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.red_dot[v] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "red_dot_update", data = red_dot_data})
    end
end

function M.guild_lv(udm, key, data) -- 公会等级
    udm.guild_lv = data
end

function M.guild_talent_coin(udm, key, data) -- 公会等级
    udm.guild_talent_coin = data
end

function M.rpg_attr(udm, key, data) -- 
    local enable_ending_data = data.enable_ending
    if enable_ending_data then
        local update_data = enable_ending_data.update or {}
        table.merge(udm.enable_ending, update_data)
        local remove_data = enable_ending_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.enable_ending[tostring(v)] = nil
        end
    end
end

function M.big_map(udm, key, data)
    local cur_map_id = data.cur_map_id
    if cur_map_id then
        udm.cur_map_id = cur_map_id
    end

    local map_pos = data.map_pos
    if map_pos ~= nil then
        udm.map_pos = map_pos
    end
    
    local ongoing_task_data = data.ongoing_task
    if ongoing_task_data then
        local update_data = ongoing_task_data.update or {}
        table.merge(udm.ongoing_task, update_data)
        local remove_data = ongoing_task_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.ongoing_task[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "ongoing_task_update", data = ongoing_task_data})
    end

    local scene_lines_data = data.lines
    if scene_lines_data ~= nil then
        local update_data = scene_lines_data.update or {}
        table.merge(udm.scene_lines, update_data)
        local remove_data = scene_lines_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.scene_lines[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "scene_lines_update", data = scene_lines_data})
    end
end

-- 大地图 事件
function M.map_task(udm, key, data)
    local map_event_data = data.map_event
    if map_event_data then
        local update_data = map_event_data.update or {}
        table.merge(udm.map_event, update_data)
        local remove_data = map_event_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.map_event[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "map_task_update", data = map_event_data})
    end
end

-- 大地图 限时事件
function M.deadline_task(udm, key, data)
    local complete_teams_data = data.complete_teams
    if complete_teams_data then
        udm.complete_teams = complete_teams_data
    end
    local ongoing_teams_data = data.ongoing_teams
    if ongoing_teams_data then
        local update_data = ongoing_teams_data.update or {}
        table.merge(udm.ongoing_teams, update_data)
        local remove_data = ongoing_teams_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.ongoing_teams[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "deadline_task_update", data = ongoing_teams_data})
    end
end

-- 大地图 奇遇事件
function M.encounter(udm, key, data)
    local complete_teams_data = data.complete_teams
    if complete_teams_data then
        udm.e_complete_teams = complete_teams_data
    end
    
    local ongoing_teams_data = data.ongoing_teams
    if ongoing_teams_data then
        local server_time = UserDataManager:getServerTime()
        udm.new_ongoing_teams_max_time = 0
        local update_data = ongoing_teams_data.update or {}
        for k,v in pairs(update_data) do
            if udm.e_ongoing_teams[k] == nil then
                udm.new_ongoing_teams = true
                local end_ts = v.end_ts or 0
                local diff_time = end_ts - server_time
                udm.new_ongoing_teams_max_time = math.max(udm.new_ongoing_teams_max_time, diff_time)
            end
        end
        table.merge(udm.e_ongoing_teams, update_data)
        local remove_data = ongoing_teams_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.e_ongoing_teams[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "encounter_update", data = ongoing_teams_data})
    end
    
    local next_trigger_ts = data.next_trigger_ts -- 下次可触发事件时间戳
    if next_trigger_ts then
        udm.e_next_trigger_ts = next_trigger_ts
    end
    local today_event_count = data.today_event_count -- 今日触发事件的次数
    if today_event_count then
        udm.e_today_event_count = today_event_count
    end
end

-- 大地图支线任务
function M.map_regional(udm, key, data)
    local task_done_data = data.task_done
    if task_done_data then
        local update_data = task_done_data.update or {}
        table.merge(udm.regional_task_done, update_data)
        local remove_data = task_done_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.regional_task_done[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "task_done_update", data = task_done_data})
    end
    local articles_data = data.articles
    if articles_data ~= nil then
        local update_data = articles_data.update or {}
        table.merge(udm.articles, update_data)
        local remove_data = articles_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.articles[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "articles_update", data = articles_data})
    end

    local tasks_data = data.tasks
    if tasks_data ~= nil then
        local update_data = tasks_data.update or {}
        table.merge(udm.tasks, update_data)
        local remove_data = tasks_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.tasks[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "tasks_update", data = tasks_data})
    end

    local close_option_data = data.closeoption
    if close_option_data ~= nil then
        local update_data = close_option_data.update or {}
        table.merge(udm.close_option, update_data)
        local remove_data = close_option_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.close_option[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "close_option_update", data = close_option_data})
    end

    local delegation_ids = data.delegation_ids
    if delegation_ids ~= nil then
        local update_data = delegation_ids.update or {}
        table.merge(udm.delegation_ids, update_data)
        local remove_data = delegation_ids.remove or {}
        for i, v in ipairs(remove_data) do
            udm.delegation_ids[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "delegation_ids_update", data = delegation_ids})
    end
end


-- 三侠五义支线任务
function M.chivalrous(udm, key, data)
    local task_done_data = data.task_done
    if task_done_data then
        local update_data = task_done_data.update or {}
        table.merge(udm.regional_task_done_activity, update_data)
        local remove_data = task_done_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.regional_task_done_activity[tostring(v)] = nil
        end
    end
    
    local articles_data = data.articles
    if articles_data ~= nil then
        local update_data = articles_data.update or {}
        table.merge(udm.articles_activity, update_data)
        local remove_data = articles_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.articles_activity[tostring(v)] = nil
        end
    end

    local tasks_data = data.tasks
    if tasks_data ~= nil then
        local update_data = tasks_data.update or {}
        table.merge(udm.tasks_activity, update_data)
        local remove_data = tasks_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.tasks_activity[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "tasks_activity_update", data = tasks_data})
    end

    local close_option_data = data.closeoption
    if close_option_data ~= nil then
        local update_data = close_option_data.update or {}
        table.merge(udm.close_option_activity, update_data)
        local remove_data = close_option_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.close_option_activity[tostring(v)] = nil
        end
    end

    local delegation_ids = data.delegation_ids
    if delegation_ids ~= nil then
        local update_data = delegation_ids.update or {}
        table.merge(udm.delegation_ids_activity, update_data)
        local remove_data = delegation_ids.remove or {}
        for i, v in ipairs(remove_data) do
            udm.delegation_ids_activity[tostring(v)] = nil
        end
    end
end

-- 随机江湖大地图支线任务
function M.new_map_regional(udm, key, data)
    -- 和江湖共用一份变量
    local task_done_data = data.task_done
    if task_done_data then
        local update_data = task_done_data.update or {}
        table.merge(udm.new_map_regional_task_done, update_data)
        local remove_data = task_done_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.new_map_regional_task_done[tostring(v)] = nil
        end
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "new_task_done_update", data = task_done_data})
    end
    local articles_data = data.articles
    if articles_data ~= nil then
        local update_data = articles_data.update or {}
        table.merge(udm.new_map_articles, update_data)
        local remove_data = articles_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.new_map_articles[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "articles_update", data = articles_data})
    end

    local tasks_data = data.tasks
    if tasks_data ~= nil then
        local update_data = tasks_data.update or {}
        table.merge(udm.new_map_tasks, update_data)
        local remove_data = tasks_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.new_map_tasks[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "new_tasks_update", data = tasks_data})
    end

    local close_option_data = data.closeoption
    if close_option_data ~= nil then
        local update_data = close_option_data.update or {}
        table.merge(udm.new_map_close_option, update_data)
        local remove_data = close_option_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.new_map_close_option[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "close_option_update", data = close_option_data})
    end

    local delegation_ids = data.delegation_ids
    if delegation_ids ~= nil then
        local update_data = delegation_ids.update or {}
        table.merge(udm.new_map_delegation_ids, update_data)
        local remove_data = delegation_ids.remove or {}
        for i, v in ipairs(remove_data) do
            udm.new_map_delegation_ids[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "delegation_ids_update", data = delegation_ids})
    end
    
    local scene_lines_data = data.lines
    if scene_lines_data ~= nil then
        local update_data = scene_lines_data.update or {}
        table.merge(udm.new_map_scene_lines, update_data)
        local remove_data = scene_lines_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.new_map_scene_lines[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "scene_lines_update", data = scene_lines_data})
    end

    local attrs_data = data.attrs
    if attrs_data ~= nil then
        local update_data = attrs_data.update or {}
        table.merge(udm.new_map_attrs, update_data)
        local remove_data = attrs_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.new_map_attrs[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "attrs_update", data = attrs_data})
    end

    local puzzle_groups_data = data.puzzle_groups
    if puzzle_groups_data ~= nil then
        local update_data = puzzle_groups_data.update or {}
        table.merge(udm.new_map_puzzle_groups, update_data)
        local remove_data = puzzle_groups_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.new_map_puzzle_groups[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "puzzle_groups_update", data = puzzle_groups_data})
    end

    local puzzle_ids = data.puzzle_ids
    if puzzle_ids ~= nil then
        local update_data = puzzle_ids.update or {}
        table.merge(udm.new_map_puzzle_ids, update_data)
        local remove_data = puzzle_ids.remove or {}
        for i, v in ipairs(remove_data) do
            udm.new_map_puzzle_ids[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "puzzle_ids_update", data = puzzle_ids})
    end

    local cur_hour = data.hour
    if cur_hour then
        udm.new_map_hour = cur_hour
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "weather_hour_update", data = cur_hour})
    end

    local cur_weather = data.weather
    if cur_weather then
        udm.new_map_weather = cur_weather
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "weather_hour_update", data = cur_weather})
    end
    
end

-- 跑马灯
function M.rolling(udm, key, data)
    local rollings_data = data.rollings
    if rollings_data then
        local update_data = rollings_data.update or {}
        table.merge(udm.rollings, update_data)
        local remove_data = rollings_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.rollings[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "rollings_update", data = rollings_data})
    end
end

-- 主线任务拆分的特殊任务
function M.quest_special(udm, key, data)
    local quests_data = data.quests
    if quests_data then
        local update_data = quests_data.update or {}
        table.merge(udm.quest_special, update_data)
        local remove_data = quests_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.quest_special[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "quest_special_update", data = quests_data})
    end
end

--推送礼包
function M.limit_push(udm, key, data)
    local limit_push_data = data.push_gifts
    local push_gifts_extra = data.push_gifts_extra
    local choice_gifts_data = data.choice_gifts
    if limit_push_data then
        local update_data = limit_push_data.update or {}
        table.merge(udm.m_limit_push, update_data)
        local remove_data = limit_push_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.m_limit_push[tostring(v)] = nil
        end
    end
    if push_gifts_extra then
        local update_data = push_gifts_extra.update or {}
        table.merge(udm.m_push_gifts_extra, update_data)
        local remove_data = push_gifts_extra.remove or {}
        for i, v in ipairs(remove_data) do
            udm.m_push_gifts_extra[tostring(v)] = nil
        end
    end
    if choice_gifts_data then
        local update_data = choice_gifts_data.update or {}
        table.merge(udm.m_choice_gifts, update_data)
        local remove_data = choice_gifts_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.m_choice_gifts[tostring(v)] = nil
        end
    end
end

-- 英雄皮肤
function M.hero_skin(udm, key, data)
    local hero_skins_data = data.hero_skins
    if hero_skins_data then
        local update_data = hero_skins_data.update or {}
        for k,v in pairs(update_data) do
            udm.hero_data:addHeroSkin(k)
        end
        table.merge(udm.hero_skins, update_data)
        local remove_data = hero_skins_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.hero_skins[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "hero_skins_update", data = hero_skins_data})
    end
end


-- 主线任务拆分的特殊任务
function M.richman(udm, key, data)
    local quests_data = data.quests
    if quests_data then
        local update_data = quests_data.update or {}
        table.merge(udm.richman, update_data)
        local remove_data = quests_data.remove or {}
        for i, v in ipairs(remove_data) do
            udm.richman[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "richman_update", data = quests_data})
    end
end

-- 帮会战
function M.gvg2_player(udm, key, data)
    local gvg_teams = data.gvg_teams
    if gvg_teams then
        local update_data = gvg_teams.update or {}
        table.merge(udm.m_gvg_teams, update_data)
        local remove_data = gvg_teams.remove or {}
        for i, v in ipairs(remove_data) do
            udm.m_gvg_teams[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "gvg_teams_update", data = gvg_teams})
    end
end
-- 帮会战 兼容
function M.gvg2_new_player(udm, key, data)
    local gvg_teams = data.gvg_teams
    if gvg_teams then
        local update_data = gvg_teams.update or {}
        table.merge(udm.m_gvg_teams, update_data)
        local remove_data = gvg_teams.remove or {}
        for i, v in ipairs(remove_data) do
            udm.m_gvg_teams[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "gvg_teams_update", data = gvg_teams})
    end
end


function M.friend(udm, key, data)
    local blacklist = data.blacklist
    if blacklist then
        udm:updateBlackList(blacklist)
    end
end

-- 更新奇遇数据
function M.medals(udm, key, data)
    local medals = data.medals
    if medals then
        udm.m_medals = medals
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "medals_update", data = medals})
    end
end

-- 更新风华录
function M.fenghua_record(udm, key, data)
    local fenghua_data = data.record
    if fenghua_data then
        for k,v in ipairs(fenghua_data) do
           table.insert(udm.m_fenghua_record_data,v)    
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "fenghua_update", data = fenghua_data})
    end
end

-- 更新红包
function M.red_envelope(udm, key, data)
    local red_packet_data = data
    if red_packet_data then
        for k,v in ipairs(red_packet_data) do
            table.insert(udm.red_packet_data,v)
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "red_packet_update", data = fenghua_data})
    end
end

-- 更新威望
function M.prestige(udm, key, data)
    local board_data = data.checkerboard_info
    if board_data then
        for k,v in pairs(board_data.update) do
            udm.m_prestige_board[k] = v
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "board_data", data = board_data})
    end
    local piece_data = data.piece_info
    if piece_data then
        for k,v in pairs(piece_data.update) do
            udm.m_prestige_pieces[k] = v
        end

        for k,v in pairs(piece_data.remove) do
            udm.m_prestige_pieces[tostring(v)] = nil
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "piece_data", data = piece_data})
    end
end

-- 更新登仙楼
function M.awaken(udm, key, data)
    local fly_hero_data = data.fly_heros
    local first = true
    if fly_hero_data then
        for k,v in pairs(fly_hero_data.update) do
            if udm.m_awaken_system_data.fly_heros[k] then
                first = false 
            end
            udm.m_awaken_system_data.fly_heros[k] = v
        end
        EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "fly_hero_data", data = fly_hero_data,first = first})
    end
    local god_heros_data = data.god_heros
    if god_heros_data then
        for k,v in pairs(god_heros_data.update) do
            udm.m_awaken_system_data.god_heros[k] = v
        end
        --EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "god_heros_data", data = god_heros_data})
    end
    local skils_data = data.skills
    if skils_data then
        for k,v in pairs(skils_data.update) do
            udm.m_awaken_system_data.skills[k] = v
        end
        --EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "skils_data", data = skils_data})
    end
end

return M