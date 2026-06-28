------------------- RedPointUtil

local M = {}

-- 是否可进阶
function M:isHeroAdvanced(heroOid)
    local hero_evolution = ConfigManager:getCfgByName("hero_evolution")
    local heroData, heroCfg = UserDataManager.hero_data:getHeroDataById(heroOid)
    if heroCfg.islink and heroCfg.islink > 0 then 
		local exhero_evolution_cfg = ConfigManager:getCfgByName("exhero_evolution")
		local type_table = exhero_evolution_cfg[heroCfg.islink or 0]
		hero_evolution = type_table[heroData.id] or type_table[0]
	end
    if heroData.evo >= heroCfg.max_evo then
        return false, 1 -- 已达最高品质
    end
    if heroData.evo <= 0 then
        return false, 0
    end
    local consume = hero_evolution[heroData.evo].consume
    if not heroCfg.islink or heroCfg.islink == 0 then
        if heroCfg.race == 5 then
            consume = hero_evolution[heroData.evo].consume_self5
        elseif heroCfg.race == 6 then
            consume = hero_evolution[heroData.evo].consume_self6
        elseif heroCfg.race == 7 then
            consume = hero_evolution[heroData.evo].consume_self7
        end
    end
    
    local universal_item = nil --万能材料
    if heroCfg.race == 7 and hero_evolution[heroData.evo].universal and hero_evolution[heroData.evo].universal > 0 then
        universal_item = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, hero_evolution[heroData.evo].universal, 0})
    end
    local count = {}
    for i, v in ipairs(consume or {}) do
        if v[1] == 1 and universal_item then -- 吃自己/可以使用万能材料
            if v[3] == 6 then
                count[i] = universal_item.user_num/2
            else
                count[i] = universal_item.user_num
            end
        else
            count[i] = 0
        end
    end
    local limit_evo = ConfigManager:getCommonValueById(327, 6)
    local flag = false
    for i, v in ipairs(UserDataManager.hero_data:getHerosId()) do
        if heroOid ~= v then
            local oneData, oneCfg = UserDataManager.hero_data:getHeroDataById(v)
            if heroData.id == oneData.id and oneData.evo >= limit_evo and heroData.evo >= limit_evo - 1 then
                return false, 2 -- 已有相同红品质以上
            end
            local length = 0
            for i, v in ipairs(consume or {}) do
                if v[1] == 1 then -- 吃自己
                    if heroData.id == oneData.id and v[3] == oneData.evo then
                        count[i] = count[i] + 1
                    end
                elseif v[1] == 2 then -- 吃同族
                    if heroCfg.race == oneCfg.race and v[3] == oneData.evo then
                        count[i] = count[i] + 1
                    end
                elseif v[1] == 3 then -- 吃特定族
                    if v[4] == oneCfg.race and v[3] == oneData.evo then
                        count[i] = count[i] + 1
                    end
                end

                if count[i] >= v[2] then
                    length = length + 1
                end
            end

            if length == #count then
                flag = true
                break
            end
        end
    end
    return flag, 0
end

--[[
	检查可以强化专属武器的英雄-返回英雄列表
]]
function M:checkExclusiveWeaponLvUp()
    local Ids = {}
    local hero_evolution = ConfigManager:getCfgByName("equip_heroes")
    local herosData = UserDataManager.hero_data:getHerosId()
    for k, v in pairs(herosData) do
        if self:checkExclusiveWeaponLvUpById(v) == true then
            table.insert(Ids, v)
        end
    end
    return Ids
end

--[[
	检查可以强化专属武器的英雄-根据id检查
]]
function M:checkExclusiveWeaponLvUpById(id)
    local hero_evolution = ConfigManager:getCfgByName("equip_heroes")
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(id)
    if hero_data.sig and next(hero_data.sig) then
        local exclusive_weapon = hero_evolution[hero_cfg.equip_heroes_id]
        local cost = exclusive_weapon.level_up[hero_data.sig.lv].levelup_cost
        local cost_data = RewardUtil:getProcessRewardData(cost[1])
        if cost_data.user_num >= cost_data.data_num then
            return true
        end
    end
    return false
end

--[[
	检查重铸提示
]]
function M:checkRecoinById(h_id, pos)
    local cons_cfg = ConfigManager:getCommonValueById(82)
    local item_data, item_cfg = UserDataManager.item_data:getItemDataById(cons_cfg[1][2])
    if item_data == nil or item_data.num <= 0 then
        return false
    end
    local h_data, h_cfg = UserDataManager.hero_data:getHeroDataById(h_id)
    if h_data.equips[tostring(pos)] ~= nil then
        local eqp_data = h_data.equips[tostring(pos)]
        local cfg = UserDataManager.equip_data:getEquipConfigByCid(eqp_data.id)
        if cfg.quality >= 9 and eqp_data.race > 0 then
            if eqp_data.race ~= h_cfg.race then
                return true
            end
        else
            return false
        end
    end
    return false
end

--[[
	检查单个升阶提示
]]
function M:checkSublimingById(h_id, pos)
    local h_data, h_cfg = UserDataManager.hero_data:getHeroDataById(h_id)
    if h_data and h_data.equips[tostring(pos)] ~= nil then
        local eqp_data = h_data.equips[tostring(pos)]
        local cfg = UserDataManager.equip_data:getEquipConfigByCid(eqp_data.id)
        local item_cost = RewardUtil:getProcessRewardData(cfg.evolution_cost[1])
        if next(cfg.evolution_cost) ~= nil and cfg.quality >= 9 and item_cost.user_num >= item_cost.data_num then
            return true
        else
            return false
        end
    end
    return false
end

--[[
	检查神器升星
]]
function M:checkArtifact(data)
    local tab = ConfigManager:getCfgByName("artifact")
    local art_cfg = tab[data.id]
    local lv_up_data = art_cfg.level_up[data.lv]
    for k, v in pairs(lv_up_data.levelup_cost) do
        local item_cost = RewardUtil:getProcessRewardData(v)
        if item_cost.user_num < item_cost.data_num then
            return false
        end
    end
    return true
end

--[[
	有更好的装备时显示小红点，具体到对应武魂→【一件穿戴】按钮
	需提示的武魂：
	①未开启共鸣水晶时，所有等级大于等于1级的武魂均有提示
	②共鸣水晶开启后，所有共鸣水晶关联的武魂均有提示
]]
function M:checkHeroBetterEquipRedPointById(oid)
    if RedPointUtil:checkInTeam(oid) == false then
        return false
    end
    local red_flag = false
    local crystal_heros_id = {}
    local open_flag, _ = BtnOpenUtil:isBtnOpen(29)
    if open_flag then
        crystal_heros_id = UserDataManager.hero_data:getCrystalAllHerosId()
    end
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
    local lv = hero_data.lv or 1
    if lv > 1 or crystal_heros_id[oid] ~= nil then
        local hero_cfg_type = hero_cfg.type or 1
        local equips = hero_data.equips or {}
        local equips_id = UserDataManager.equip_data:getEquipsId()
        for i, v in pairs(equips_id) do
            local equip_data, equip_cfg = UserDataManager.equip_data:getEquipDataById(v)
            if hero_cfg_type == equip_cfg.type then
                local pos = equip_cfg.pos
                local equip_data2 = equips[tostring(pos)]
                if equip_data2 then
                    local equip_cfg2 = UserDataManager.equip_data:getEquipConfigByCid(equip_data2.id)
                    if equip_data and equip_cfg2 and equip_cfg.quality > equip_cfg2.quality then
                        red_flag = true
                        break
                    end
                else
                    red_flag = true
                    break
                end
            end
        end
    end
    return red_flag
end

--需求-穿装备的红点，只有上阵中的人才会提示（包括竞技场、天机楼、推图阵容）
function M:checkInTeam(oid)
    local teams = UserDataManager.hero_data:getTeams()
    for k, v in pairs(teams) do
        for kk, vv in pairs(v) do
            if oid == vv then
                return true
            end
        end
    end
    return false
end

function M:checkInStageTeam(oid)
    local teams = UserDataManager.hero_data:getTeamByKey("stage")
    for k, v in pairs(teams) do
        if oid == v then
            return true
        end
    end
    return false
end

--检查英雄羁绊红点
function M:checkHeroFetterRedPoint(oid)
    local red_flag = false
    local hero_friend_tab = {}
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
    local hero_friend_table = ConfigManager:getCfgByName("hero_friend")
    if hero_data and hero_cfg then
        for k, v in pairs(hero_friend_table) do
            if hero_cfg.id == v.main_hero then
                table.insert(hero_friend_tab, k)
            end
        end
    end
    for i, v in ipairs(hero_friend_tab) do
        for kk, vv in pairs(UserDataManager.can_rcvd) do
            if v == tonumber(kk) then
                red_flag = true
            end
        end
    end
    return red_flag
end

function M:checkPushFormationRedPoint()
    local push_formation = UserDataManager:getRedDotByKey("push_formation")
    return push_formation == 1
end

--助战系统红点点
function M:checkSupportSysRedPoint()
    local hero_help = UserDataManager:getRedDotByKey("hero_help")
    return hero_help == 1
end

-- 经脉红点
function M:checkHeroSigCanLevelUpById(oid)
    if BtnOpenUtil:isBtnOpen(62) == false then
        return
    end
    local red_flag = false
    local open_flag_1, _ = BtnOpenUtil:isBtnOpen(147)
    local open_flag_2, _ = BtnOpenUtil:isBtnOpen(148)
    local open_evo = ConfigManager:getMeridianOpenEvoByPos(1)
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
    if hero_data.evo >= open_evo and open_flag_1 and open_flag_2 then
        for i = 1, GlobalConfig.HERO_SIG_NUM do
            red_flag = self:checkHeroOneSigCanLevelUpByData(hero_data, hero_cfg, i)
            if red_flag then
                break
            end
        end
    end
    return red_flag
end

-- 单个经脉红点
function M:checkHeroOneSigCanLevelUpByData(hero_data, hero_cfg, sig_id)
    if RedPointUtil:checkInStageTeam(hero_data.oid) == false then
        return false
    end
    local red_flag = false
    local sig_red_point_data = UserDataManager.hero_data:getSigRedPointData()
    local equip_heroes_cfg = ConfigManager:getCfgByName("equip_heroes")
    local equip_heroes_cfg_item = equip_heroes_cfg[hero_cfg.equip_heroes_id] or {}
    local sig = hero_data.sig or {}
    local one_sig_data = sig[tostring(sig_id)]
	local meridians_cultivation_cfg = ConfigManager:getCfgByName("meridians_cultivation")
	local meridians_cultivation_cfg_item = (one_sig_data and one_sig_data.deep ~= nil) and meridians_cultivation_cfg[one_sig_data.deep+1] or meridians_cultivation_cfg[0]
    local season = UserDataManager:getCurSeason()
    local cur_stage = UserDataManager:getCurStage()
    local open_order = hero_cfg.open_order or {}
    local open_order_pos = -1
    for k, v in ipairs(open_order) do
        if v == sig_id then
            open_order_pos = k
            break
        end
    end
    if one_sig_data and one_sig_data.lv%10 == 0 and meridians_cultivation_cfg_item then
        local unlock3 = meridians_cultivation_cfg_item.unlock_condition_param3 or 0
        if meridians_cultivation_cfg_item.season_unlock > season and (unlock3 <= 0 or unlock3 > cur_stage) then --解锁赛季限制不满足，并且，没有配超前解锁条件或者有超前解锁条件但是不满足
           return false 
        end
    end
    local open_evo = ConfigManager:getMeridianOpenEvoByPos(open_order_pos)
    if hero_data.evo >= open_evo then -- 秘籍位置开启
        if sig_red_point_data[sig_id] == -1 then -- 所有能激活的武神都显示红点
            if one_sig_data == nil or one_sig_data.lv < 10 then
                local sig_cfg = equip_heroes_cfg_item[sig_id] or {}
                local level_up = sig_cfg.level_up or {}
                local level_up_sig_cfg = level_up[0]
                if level_up_sig_cfg then
                    local cost = level_up_sig_cfg.levelup_cost
                    local level_up_cost = RewardUtil:getProcessRewardData(cost[1])
                    if level_up_cost.user_num >= 1000 and level_up_cost.user_num >= level_up_cost.data_num then
                        red_flag = true
                    end
                end
            end
        else -- 对应的最高经脉的英雄显示红点
            local red_hero_id = sig_red_point_data[sig_id + 100]
            if red_hero_id == hero_data.oid and one_sig_data then
                local sig_cfg = equip_heroes_cfg_item[sig_id] or {}
                local level_up = sig_cfg.level_up or {}
                local level_up_sig_cfg = level_up[one_sig_data.lv + 1]
                if level_up_sig_cfg then
                    local cost = level_up_sig_cfg.levelup_cost
                    local level_up_cost = RewardUtil:getProcessRewardData(cost[1])
                    if level_up_cost.user_num >= 1000 and level_up_cost.user_num >= level_up_cost.data_num then
                        red_flag = true
                    end
                end
            end
        end
    end
    return red_flag
end

-- 是否有秘籍可以装备
function M:checkHeroCanEquipMysticById(oid)
    local red_flag = false
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
    local lv = hero_data.lv or 1
    local open_flag_1, _ = BtnOpenUtil:isBtnOpen(147)
    local open_flag_2, _ = BtnOpenUtil:isBtnOpen(148)
    local open_evo = ConfigManager:getMeridianOpenEvoByPos(1)
    if lv > 1 and hero_data.evo >= open_evo and open_flag_1 and open_flag_2 then
        local hero_evo = hero_data.evo or 0
        local mystics = hero_data.mystics or {}
        local open_order = hero_cfg.open_order or {}
        for k, v in ipairs(open_order) do
            local open_evo = ConfigManager:getMeridianOpenEvoByPos(k)
            if hero_evo >= open_evo then
                local mystic_id = mystics[tostring(v)]
                if mystic_id == nil or mystic_id == "" then
                    --red_flag = UserDataManager.mystic_data:getCanEquipmentMysticesFlag(v)
                    --if red_flag then
                    --    break
                    --end
                end
            else
                break
            end
        end
    end
    return red_flag
end

--- 单个英雄红点
function M:checkHeroRedPointById(id)
    local red_point = self:checkHeroBetterEquipRedPointById(id)
    if not red_point then
        red_point = self:checkHeroCanEquipMysticById(id)
    end
    if not red_point then
        red_point = self:checkHeroSigCanLevelUpById(id)
    end
    if not red_point then
        red_point = self:checkHeroSkipRedPointById(id)
    end
    if not red_point then
        red_point = self:checkHeroFrendLevelUp(id)
    end
    --local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(id)
    --local book_red_flag = UserDataManager.hero_data:checkHeroCollectPoint(hero_data.id)
    return red_point == true -- or book_red_flag == true
end

--英雄好感可升级红点
function M:checkHeroFrendLevelUp(oid)
    if BtnOpenUtil:isBtnOpen(181) == false then
        return
    end
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
    if hero_data == nil or hero_cfg == nil then
        return false
    end
    if hero_cfg.evo == 3 then --蓝色英雄没有好感度
        return false
    end
    local hv_city_teams = false --好感红点 只展示推图队伍中的五个
    local teams = UserDataManager.hero_data:getTeamByKey("stage")
    for k,v in pairs(teams) do
        if oid == v then
            hv_city_teams = true
            break
        end
    end
    if hv_city_teams == false then
        return false
    end
    local lock_evo = ConfigManager:getCommonValueById(465,10)
    if hero_data.evo < lock_evo then
        return false
    end
    local friend_data = UserDataManager.m_friendliness[tostring(hero_cfg.id)] or {point=0,lv=0} --好感数据
    if hero_data.lv > 1 or hero_data.clv > 1  then --0级好感不显示小红点
        local favorite_gift = hero_cfg.favorite_gift or {}
        local items = UserDataManager.item_data:getItemsBySubType(favorite_gift,friend_data.lv)
        local lv_cfg, is_max = self:getFetterEqpMaxNum(hero_cfg.role_type ,friend_data.lv)
        local add_num = 0
        if is_max == true then
            return false
        end
        if lv_cfg then
            for k,v in pairs(items) do
                local item_data, item_cfg = UserDataManager.item_data:getItemDataById(v)
                for k,v in pairs(item_cfg.effect) do
                    if v[1] == friend_data.lv then
                        add_num = add_num + (item_data.num * v[2])
                    end
                end
                if add_num + friend_data.point >= lv_cfg.upgrade then
                    return true
                end
            end
        end
    end
    return false
end

function M:getFetterEqpMaxNum(role_type, friend_lv)
	local fetters_level_tab = ConfigManager:getCfgByName("fetters_level")
    local season = UserDataManager:getCurSeason()
    local com_data = ConfigManager:getCommonValueById(636)
    local max_limit = {0,0,0} --{赛季，下限，上限}
    for k,v in pairs(com_data) do
        if v[1] == season then
            max_limit = v
        end
    end
    local max_lv = max_limit[3] or 0
    if max_lv == 0 then
        return nil, false
    end
	if fetters_level_tab then
		local fet_tab = fetters_level_tab[role_type]
		if friend_lv +1 <= max_lv then
			return fet_tab[friend_lv +1], false
		else
			return fet_tab[max_lv], true	
		end
	end
	return nil, false
end

--英雄皮肤红点
function M:checkHeroSkipRedPointById(oid)
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
    if hero_data == nil or hero_cfg == nil then
        return false
    end
    local skin = hero_cfg.skin or {}
    if #skin > 1 then
        for k, v in pairs(skin) do
            local new_skip = UserDataManager.hero_data:checkHeroSkin(tostring(v))
            if new_skip and new_skip == 1 then
                return true
            end
        end
    end
    return false
end

--清除单个英雄皮肤红点
function M:clearHeroSkipRedPointById(oid)
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
    local skin = hero_cfg.skin or {}
    if #skin > 1 then
        for k, v in pairs(skin) do
            local new_skip = UserDataManager.hero_data:checkHeroSkin(tostring(v))
            if new_skip and new_skip == 1 then
                UserDataManager.hero_data:removeHeroSkin(tostring(v))
            end
        end
    end
end

--- 背包 武魂碎片能合成	等级限制可开宝箱
function M:checkItemRedPointById(id)
    local level = UserDataManager.user_data:getUserStatusDataByKey("level") or 1
    local red_flag = false
    local item_data, cfg = UserDataManager.item_data:getItemDataById(id)
    if cfg then
        if cfg.sort == 2 then
            local use_num = cfg.use_num
            if item_data.num >= use_num then
                red_flag = true
            end
        elseif cfg.sort == 4 then -- 随机秘籍合成
            local use_num = cfg.use_num
            if use_num > 0 and item_data.num >= use_num then
                red_flag = true
            end
        elseif cfg.sort == 1 then
            local player_lv = cfg.player_lv or 1
            local red_show = cfg.red_show or 0
            if red_show == 1 and level >= player_lv then
                if cfg.type == GlobalConfig.ITEM_TYPE.CONDITION_BOX then
                    local received = item_data.received or {}
                    local box_special_cfg = ConfigManager:getBoxSpecialCfg(cfg.effect)
                    for k, v in pairs(box_special_cfg) do
                        -- 1=登陆天数  2=玩家等级 total_login_days
                        local target_type = v.target_type or 0
                        local target_id = v.target_id or 0
                        local cur_value = 0
                        if target_type == 1 then -- 登陆天数
                            cur_value = UserDataManager:getTempData("total_login_days") or 0
                        elseif target_type == 2 then -- 玩家等级
                            cur_value = UserDataManager.user_data:getUserStatusDataByKey("level") or 0
                        end
                        local index = table.indexof(received, k)
                        if index == false and cur_value >= target_id then --可领取
                            red_flag = true
                            break
                        end
                    end
                else
                    red_flag = true
                end
            end
        end
    end
    return red_flag
end

local __red_point = {}

-- 背包 武魂碎片能合成	等级限制可开宝箱
__red_point[1] = function()
    local red_flag = false
    local data = UserDataManager.item_data:getItemsId()
    for i, v in ipairs(data) do
        local flag = M:checkItemRedPointById(v)
        if flag then
            red_flag = true
            break
        end
    end
    local hero_bag_once = UserDataManager:getRedDotByKey("main_bag_once")
    if hero_bag_once == 0 and red_flag == true then
        red_flag = false
    end
    return red_flag
end

-- 背包  武魂碎片能合成
__red_point[1001] = function()
    local red_flag = false
    local function filterFunc(item_data, item_cfg)
        return item_cfg.sort == 2
    end
    local data = UserDataManager.item_data:getItemsIdByFilterFunc(filterFunc)
    for i, v in ipairs(data) do
        local flag = M:checkItemRedPointById(v)
        if flag then
            red_flag = true
            break
        end
    end
    return red_flag
end

-- 背包 等级限制可开宝箱
__red_point[1002] = function()
    local red_flag = false
    local function filterFunc(item_data, item_cfg)
        return item_cfg.sort == 1
    end
    local data = UserDataManager.item_data:getItemsIdByFilterFunc(filterFunc)
    for i, v in ipairs(data) do
        local flag = M:checkItemRedPointById(v)
        if flag then
            red_flag = true
            break
        end
    end
    return red_flag
end

-- 背包 随机秘籍合成
__red_point[1003] = function()
    local red_flag = false
    local function filterFunc(item_data, item_cfg)
        return item_cfg.sort == 4
    end
    local data = UserDataManager.item_data:getItemsIdByFilterFunc(filterFunc)
    for i, v in ipairs(data) do
        local flag = M:checkItemRedPointById(v)
        if flag then
            red_flag = true
            break
        end
    end
    return red_flag
end

-- 挂机
__red_point[3] = function()
    local red_flag = false
    return red_flag
end

-- 事务
__red_point[4] = function()
    local red_flag = false
    return red_flag
end

-- 侠义
__red_point[5] = function()
    local red_flag = false
    return red_flag
end

-- 当共鸣水晶中当武魂栏位中有空位时显示小红点，具体到栏位
__red_point[6] = function()
    local red_flag = false
    --[[if M:localRedPointJudge("red_crystal") then
		local crystal_slot = UserDataManager.hero_data:getCrystalSlot()
		for k,v in pairs(crystal_slot) do
			local hid = v.hid or ""
			local etime = v.etime or 0
			if hid == "" and (etime - UserDataManager:getServerTime()) <= 0 then
				red_flag = true
				break
			end
		end
		if red_flag == false then
			red_flag = __red_point[6001]()
		end
	end--]]
    local crystal_slot = UserDataManager:getRedDotByKey("crystal_slot")
    red_flag = crystal_slot == 1
    if red_flag == false then
        red_flag = __red_point[6002]()
    end
    return red_flag
end

--有新的槽位可以解锁
__red_point[6001] = function()
    local red_flag = false
    --if M:localRedPointJudge("red_crystal") then
    local crystal_slot = UserDataManager.hero_data:getCrystalSlot()
    local count = #crystal_slot
    local reset_cost = GameUtil:getRefreshCost(count, 8)
    local cost_data = RewardUtil:getProcessRewardData(reset_cost)
    if cost_data.user_num >= cost_data.data_num then
        red_flag = true
    end
    --end
    return red_flag
end

--可以升级或者解锁等级上限
__red_point[6002] = function()
    local red_flag = false
    if UserDataManager.m_clv > 0 and UserDataManager.m_clv_limit > 0 and UserDataManager.m_clv >= UserDataManager.m_clv_limit then
        return false
        --到达上限
    end
    local lv_top = UserDataManager.hero_data:getLevelTop()
    if UserDataManager.m_clv == 0 and next(lv_top) ~= nil then
        --可以解锁等级上限
        for k,v in pairs(lv_top) do
            if v[2] < 300 then
                return false
            end
        end
        return true
    end
    local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local crystal = crystal_upgrade[UserDataManager.m_clv] --上一级需要的资源
    local user_data = UserDataManager.user_data
    local coin = user_data:getUserStatusDataByKey("coin")
    if coin < crystal.coin then 
        return false
    end
    local hero_exp = user_data:getUserStatusDataByKey("hero_exp")
    if hero_exp < crystal.exp then 
        return false
    end
    local dust = user_data:getUserStatusDataByKey("dust")
    if dust < crystal.special_num then 
        return false
    end
    return true
end

--[[	
	抽卡
]]
__red_point[7] = function()
    local red_flag = false
    local gacha_cfg = ConfigManager:getCfgByName("gacha")
    for index = 1, 3 do
        local gacha = gacha_cfg[index]
        local ten_cost = gacha.ten_cost
        if UserDataManager:hasGachaSubscribe() then
            ten_cost = gacha.special_ten_cost
        end
        for i, v in ipairs(ten_cost or {}) do
            local itemData = RewardUtil:getProcessRewardData(v)
            if itemData.user_num >= itemData.data_num then
                if itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
                    return true
                end
            else
                if index == 1 then
                    local min_count = gacha.limit or 10
                    local once_cost = gacha.cost_item[1][3]
                    if itemData.user_num >= min_count * once_cost then
                        return true
                    end
                elseif index == 2 and itemData.data_type ~= RewardUtil.REWARD_TYPE_KEYS.DIAMOND then
                    --local min_count = gacha.limit or 10
                    --if itemData.user_num >= min_count then
                    --	return true
                    --end
                elseif index == 3 then
                    local min_count = gacha.limit or 10
                    if itemData.user_num >= min_count then
                        return true
                    end
                end
            end
        end
    end
    local bless_need_change = UserDataManager:getRedDotByKey("bless_need_change") --
    local bless_look_times = UserDataManager:getBlessNeedChange()
    red_flag = bless_need_change == 1 and bless_look_times == 0
    --red_flag = M:hasRedPointById(10003)
    return red_flag
end

--- 抽卡宝箱 --------重复id----
-- __red_point[10003] = function()
-- 	local red_flag = false
-- 	local gacha_chest = UserDataManager:getRedDotByKey("gacha_chest")
-- 	red_flag = gacha_chest == 1
-- 	return red_flag
-- end

__red_point[7001] = function()
    local red_flag = false
    local friend_coin = UserDataManager.user_data:getUserStatusDataByKey("friend_coin") or 0 -- 友情点
    red_flag = friend_coin >= 10
    return red_flag
end

__red_point[7002] = function()
    local red_flag = false
    local item_8 = UserDataManager.item_data:getItemDataById("1010") -- 混元令
    red_flag = item_8.num > 0
    return red_flag
end

__red_point[7003] = function()
    local red_flag = false
    local item_7 = UserDataManager.item_data:getItemDataById("1009") -- 金元令
    red_flag = item_7.num > 0
    return red_flag
end

--[[
	封神榜（凯旋丰碑
]]
__red_point[8] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("rank_reward")
    red_flag = rank_reward == 1
    return red_flag
end

-- 武魂 有更好的装备
__red_point[9] = function()
    local red_flag = false
    local heros_id = UserDataManager.hero_data:getHerosId()
    for i, v in pairs(heros_id) do
        if M:checkHeroRedPointById(v) then
            red_flag = true
            break
        end
    end
    if not red_flag then
        red_flag = UserDataManager.hero_data:checkHeroRedPoint()
    end
    if not red_flag then
        red_flag = M:checkPushFormationRedPoint()
    end

    if not red_flag then
        red_flag = M:checkSupportSysRedPoint()
    end

    return red_flag == true
end

--- 藏经阁/琅嬛阁
__red_point[10] = function()
    local red_flag = false
    -- 获得新秘籍
    -- 秘籍升星
    -- if UserDataManager.mystic_data and next(UserDataManager.mystic_data.m_new_ids) ~= nil then
    -- 	red_flag = true
    -- end
    return red_flag
end

--- 论剑
__red_point[11] = function()
    local red_flag = false
    --local arena_beat = UserDataManager:getRedDotByKey("arena_beat") --被打
    --local arena_can_chanllenge = UserDataManager:getRedDotByKey("arena_can_chanllenge") --论剑免费次数
    local arena_reward = UserDataManager:getRedDotByKey("arena_reward") --论剑奖励
    local arena = UserDataManager:getRedDotByKey("arena") --论剑点赞
    if arena == 1 then
        return true
    end
    red_flag = arena_reward == 1
    return red_flag
end

--论剑点赞 一次性红点
__red_point[1102] = function()
    local red_flag = false
    local arena_once = UserDataManager:getRedDotByKey("arena") --被打
    if arena_once == 1 then
        return true
    end
    return red_flag
end

--论剑被打
__red_point[1101] = function()
    local red_flag = false
    -- local arena_beat = UserDataManager:getRedDotByKey("arena_beat") --被打
    -- if arena_beat == 1 then
    -- 	return true
    -- end
    return red_flag
end

--- 帮会
__red_point[12] = function()
    local red_flag = false
    red_flag = __red_point[127]() or __red_point[12001]() or __red_point[168]()
    return red_flag
end

--- 弹劾帮主红点
__red_point[168] = function()
    local red_flag = false
    local guild_impeach = UserDataManager:getRedDotByKey("guild_impeach") --是否可以弹劾帮主的红点
    red_flag = guild_impeach == 1
    return red_flag
end

-- 帮会点卯
__red_point[127] = function()
    local red_flag = false
    local guild_sign = UserDataManager:getRedDotByKey("guild_sign")
    red_flag = guild_sign == 1
    return red_flag
end

-- 帮会神炉可祈福一次性红点
__red_point[12001] = function()
    local red_flag = false
    local tripod_once = UserDataManager:getRedDotByKey("tripod_once")
    local once_bl = M:localRedPointJudge("tripod_day_once")
    red_flag = tripod_once == 1 and once_bl == true

    return red_flag
end

-- 帮会战队设置
__red_point[12002] = function()
    local red_flag = false
    local guild_sign = UserDataManager:getRedDotByKey("guild_war_def_team_empty")
    red_flag = guild_sign == 1
    return red_flag
end

-- 主界面-好友
__red_point[13] = function()
    local red_flag = false
    local f_apply = UserDataManager:getRedDotByKey("friend_apply")
    local f_coin = UserDataManager:getRedDotByKey("friend_coin")
    red_flag = f_apply == 1 or f_coin == 1
    return red_flag
end

-- 社交-好友
__red_point[1301] = function()
    local red_flag = false
    local f_apply = UserDataManager:getRedDotByKey("friend_apply")
    local f_coin = UserDataManager:getRedDotByKey("friend_coin")
    red_flag = f_apply == 1 or f_coin == 1
    return red_flag
end

-- 社交-好友 --申请
__red_point[1302] = function()
    local red_flag = false
    local f_apply = UserDataManager:getRedDotByKey("friend_apply")
    red_flag = f_apply == 1
    return red_flag
end

-- 社交-好友 --列表
__red_point[1303] = function()
    local red_flag = false
    local f_coin = UserDataManager:getRedDotByKey("friend_coin")
    red_flag = f_coin == 1
    return red_flag
end

-- 主界面-贸易港
__red_point[14] = function()
    local red_flag = false
    return red_flag
end

--- 迷宫开启
__red_point[16] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("maze_open")
    local un_lock = UserDataManager:getRedDotByKey("maze_unlock")
    local maze_challenge = UserDataManager:getRedDotByKey("maze_challenge")
    red_flag = rank_reward == 1 or un_lock == 1
    if red_flag == false then
        if maze_challenge == 1 then
            red_flag = true
        end
    end
    return red_flag
end

---迷宫升级
__red_point[1601] = function()
    local red_flag = false
    local un_lock = UserDataManager:getRedDotByKey("maze_unlock")
    red_flag = un_lock == 1
    return red_flag
end

--- 装备强化
__red_point[17] = function()
    local red_flag = false
    return red_flag
end

--[[
	快速挂机(免费次数)
]]
__red_point[18] = function()
    local red_flag = false
    local subscr_tim = 1
    local idle_auto_etime = UserDataManager.m_subscribe.idle_auto_etime or 0
    local end_time = idle_auto_etime - UserDataManager:getServerTime()
    if idle_auto_etime > 0 and end_time > 0 then
        local sub_tab = ConfigManager:getCfgByName("auto_subscribe")
        local sub_cfg = sub_tab[3]
        subscr_tim = subscr_tim + sub_cfg.free_quick_times
    end
    local user_data = UserDataManager.user_data
    local vip = user_data:getUserStatusDataByKey("vip")
    local vip_cfg = ConfigManager:getCfgByName("vip")[vip]
    red_flag = UserDataManager.idle_info.qi_free_times < subscr_tim
    return red_flag
end

-- 好友 好友管理
__red_point[4001] = function()
    local red_flag = false
    local f_apply = UserDataManager:getRedDotByKey("friend_apply")
    red_flag = f_apply == 1
    return red_flag
end

-- 好友 一键领取和赠送
__red_point[4002] = function()
    local red_flag = false
    local f_coin = UserDataManager:getRedDotByKey("friend_coin")
    red_flag = f_coin == 1
    return red_flag
end

-- 主界面-邮件
__red_point[15] = function()
    local red_flag = false
    local mail = UserDataManager:getRedDotByKey("mail")
    red_flag = mail == 1
    return red_flag
end

-- 事务-传功殿 升阶
__red_point[19] = function()
    local red_flag = false
    local hero_evolution = UserDataManager:getRedDotByKey("hero_evolution")
    red_flag = hero_evolution == 1
    return red_flag
end

--- 竞技场被挑战
__red_point[20] = function()
    local red_flag = false
    return red_flag
end

--- 悬赏领奖
__red_point[21] = function()
    local red_flag = false
    local bounty_reward = UserDataManager:getRedDotByKey("bounty_reward")
    local bounty_open = UserDataManager:getRedDotByKey("bounty_open")
    red_flag = bounty_reward == 1 or bounty_open == 1
    return red_flag
end

--- 神州探秘
__red_point[22] = function()
    local red_flag = false
    return red_flag
end

--双鹿红点
__red_point[226] = function()
    local new_year = UserDataManager:getRedDotByKey("new_year")
    local new_year_gift = UserDataManager:getRedDotByKey("new_year_gift")
    local red_flag = (new_year == 1) or (new_year_gift == 1)
    if not red_flag then
        red_flag = RedPointUtil:localRedPointJudge("linglu_shopRedDot")
    end
    return red_flag
end

--- 高阶竞技场红点
__red_point[24] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("high_arena_beat")
    local high_arena_quest = UserDataManager:getRedDotByKey("high_arena_quest")
    local qs_high_arena = UserDataManager:getRedDotByKey("qs_high_arena")
    local high_arena = UserDataManager:getRedDotByKey("high_arena")
    red_flag = rank_reward == 1 or high_arena_quest == 1 or qs_high_arena == 1 or high_arena == 1
    return red_flag
end

--- 高阶竞技场被挑战
__red_point[2401] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("high_arena_beat")
    red_flag = rank_reward == 1
    return red_flag
end

--- 高阶竞技场任务红点
__red_point[2402] = function()
    local red_flag = false
    local high_arena_quest = UserDataManager:getRedDotByKey("high_arena_quest")
    red_flag = high_arena_quest == 1
    return red_flag
end

--- 高阶竞技场特殊任务红点
__red_point[2403] = function()
    local red_flag = false
    local qs_high_arena = UserDataManager:getRedDotByKey("qs_high_arena")
    red_flag = qs_high_arena == 1
    return red_flag
end

--- 高阶竞技场点赞红点
__red_point[2404] = function()
    local red_flag = false
    local high_arena = UserDataManager:getRedDotByKey("high_arena")
    red_flag = high_arena == 1
    return red_flag
end

--- 编队
__red_point[26] = function()
    local red_flag = false
    return red_flag
end

--- 图鉴
__red_point[27] = function()
    local red_flag = UserDataManager.hero_data:checkHeroRedPoint()
    local check_red_flag = M:localRedPointJudge("tj_lv_up_red_point")
    if not red_flag and check_red_flag == true then -- 判断彩五图鉴升级红点
        local hero_ids = UserDataManager.hero_data:getHeroRoleCanUpGradeIdList()
        red_flag = #hero_ids>0
    end
    return red_flag
end

--- 佣兵
__red_point[28] = function()
    local red_flag = false
    local reset = UserDataManager:getRedDotByKey("apostle_reset")
    local apply = UserDataManager:getRedDotByKey("apostle_apply")
    local get = UserDataManager:getRedDotByKey("apostle_get")
    red_flag = reset == 1 or apply == 1 or get == 1
    return red_flag
end

--- 赛季成就
__red_point[240] = function()
    local red_flag = false
    local quest_season = UserDataManager:getRedDotByKey("quest_season")
    red_flag = quest_season == 1 
    return red_flag
end

__red_point[244] = function()
    local red_flag = false
    local dark_tower_daily = UserDataManager:getRedDotByKey("dark_tower_daily")
    local dark_tower_reward = UserDataManager:getRedDotByKey("dark_tower_reward")
    local red_flag2 =   __red_point[24402]()
    red_flag = dark_tower_daily == 1 or dark_tower_reward == 1 or red_flag2
    return red_flag
end

__red_point[24401] = function()
    local red_flag = false
    local dark_tower_reward = UserDataManager:getRedDotByKey("dark_tower_reward")
    red_flag = dark_tower_reward == 1
    return red_flag
end

-- 极阴塔推送礼包一次性红点
__red_point[24402] = function()
    local red_flag = false
    local have_gift = GameUtil:getGiftStatusByOpenId(244)
    local dark_tower_reward_once = RedPointUtil:localRedPointJudge("dark_tower_reward_once")
    red_flag = dark_tower_reward_once  and have_gift
    return red_flag
end

__red_point[245] = function()
    local red_flag = false
    local tower_active = UserDataManager:getRedDotByKey("tower_active")
    local tower_active_reward = UserDataManager:getRedDotByKey("tower_active_reward")
    local red_flag2 =  __red_point[24502]()
    red_flag = tower_active == 1 or tower_active_reward == 1 or red_flag2
    return red_flag
end

__red_point[24501] = function()
    local red_flag = false
    local tower_active_reward = UserDataManager:getRedDotByKey("tower_active_reward")
    red_flag = tower_active_reward == 1
    return red_flag
end

-- 天机秘境推送礼包一次性红点
__red_point[24502] = function()
    local red_flag = false
    local have_gift = GameUtil:getGiftStatusByOpenId(245)
    local tower_active_reward = RedPointUtil:localRedPointJudge("tower_active_reward_once")
    red_flag = tower_active_reward  and have_gift
    return red_flag
end

--- 新的佣兵申请
__red_point[2801] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("apostle_apply")
    red_flag = rank_reward == 1
    return red_flag
end

--- 借到新的佣兵
__red_point[2802] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("apostle_get")
    red_flag = rank_reward == 1
    return red_flag
end

--- 世界boss
__red_point[29] = function()
    local red_flag = false
    --有剩余免费次数
    local rank_reward = UserDataManager:getRedDotByKey("world_boss")
    local world_boss_like = UserDataManager:getRedDotByKey("world_boss_like")
    red_flag = rank_reward == 1 or world_boss_like == 1
    return red_flag
end

--- 师徒
__red_point[30] = function()
    local red_flag = false
    --[[local quest = UserDataManager:getRedDotByKey("mentorship_quest")
	local apostle_reset = UserDataManager:getRedDotByKey("mentorship_apostle_reset")
	local apply = UserDataManager:getRedDotByKey("mentorship_apply")
	red_flag = quest == 1 or apostle_reset == 1 or apply == 1]]
    return red_flag
end

--- 师徒任务（授业礼包）
__red_point[3001] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("mentorship_quest")
    red_flag = rank_reward == 1
    return red_flag
end

--- 师徒佣兵重置
__red_point[3002] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("mentorship_apostle_reset")
    red_flag = rank_reward == 1
    return red_flag
end

--- 师徒申请
__red_point[3002] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("mentorship_apply")
    red_flag = rank_reward == 1
    return red_flag
end

--- 师徒
__red_point[31] = function()
    local red_flag = false
    return red_flag
end

--- 帮会BOSS
__red_point[32] = function()
    local red_flag = false
    -- local rank_reward = UserDataManager:getRedDotByKey("guild_boss")
    -- red_flag = rank_reward == 1
    return red_flag
end

--- 帮会升级
__red_point[33] = function()
    local red_flag = false
    -- 以删除ß
    --local rank_reward = UserDataManager:getRedDotByKey("guild_levelup")
    --red_flag = rank_reward == 1
    return red_flag
end

--- 帮会神炉升级
__red_point[3301] = function()
    local red_flag = false
    -- 以删除
    --local rank_reward = UserDataManager:getRedDotByKey("guild_tripod_lvlup")
    --red_flag = rank_reward == 1
    return red_flag
end

--- 帮会管理、入会申请（管理层）
__red_point[34] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("guild_apply") --一次性
    if rank_reward == 1 then
        red_flag = true
    end
    return red_flag
end

--心愿清单
__red_point[35] = function()
    local red_flag = false
    local bless_need_change = UserDataManager:getRedDotByKey("bless_need_change") --
    local bless_look_times = UserDataManager:getBlessNeedChange()
    red_flag = bless_need_change == 1 and bless_look_times == 0
    return red_flag
end

--秘籍
__red_point[40] = function()
    local red_flag = false
    return red_flag
end

--参悟
__red_point[41] = function()
    local red_flag = false
    return red_flag
end

--巅峰竞技场
__red_point[42] = function()
    local red_flag = false
    return red_flag
end

-- 每日任务
__red_point[43] = function()
    local red_flag = false
    local quest_daily = UserDataManager:getRedDotByKey("quest_daily")
    red_flag = quest_daily == 1
    return red_flag
end
-- 周任务
__red_point[44] = function()
    local red_flag = false
    local quest_weekly = UserDataManager:getRedDotByKey("quest_weekly")
    red_flag = quest_weekly == 1
    return red_flag
end

-- 主线任务
__red_point[45] = function()
    local red_flag = false
    local quest_main = UserDataManager:getRedDotByKey("quest_main")
    red_flag = quest_main == 1
    return red_flag
end

--- 活动
__red_point[4600] = function()
    local red_flag = false
    local gather = UserDataManager:getRedDotByKey("hero_gather")
    local gather_active = UserDataManager:getRedDotByKey("hero_gather_active")
    local recruit = UserDataManager:getRedDotByKey("recruit")
    local tour = UserDataManager:getRedDotByKey("seven_tour")
    red_flag = gather == 1 or recruit == 1 or tour == 1 or gather_active == 1
    return red_flag
end

--- 绿林集结
__red_point[46] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("hero_gather")
    red_flag = rank_reward == 1
    return red_flag
end

--- 大侠试炼
__red_point[47] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("recruit")
    red_flag = rank_reward == 1
    if red_flag == false then
        local versions, cur_version, day = GameUtil:checkRecruit()
        if table.nums(versions) == 1 then
            red_flag = RedPointUtil:recruitShopRedPoint(cur_version, day)
        else
            for k, v in pairs(versions) do
                if v == cur_version then
                    red_flag = RedPointUtil:recruitShopRedPoint(cur_version, day)
                elseif v > cur_version then
                    red_flag = RedPointUtil:recruitShopRedPoint(v, 7)
                end
                if red_flag == true then
                    return red_flag
                end
            end
        end
    end
    return red_flag
end

--- 剑出鸿蒙
__red_point[474] = function()
    local red_flag = false
    local rta_promote = UserDataManager:getRedDotByKey("rta_promote")
    red_flag = rta_promote == 1
    return red_flag
end

--大侠试炼折扣商品红点
function M:recruitShopRedPoint(ver, day)
    local ver_recruit_shop = UserDataManager.m_recruit_shop[tostring(ver)] or {}
    for i = 1, day do
        if RedPointUtil:getRecruitShopStatus(tonumber(ver), i) == true and self:checkGetBuyShop(ver_recruit_shop, i) then
            return true
        end
    end
    return false
end

function M:checkGetBuyShop(shops, day)
    for k, v in pairs(shops) do
        if v == day then
            return true
        end
    end
    return false
end

function M:recruitShopDayRedPoint(ver, day)
    local ver_recruit_shop = UserDataManager.m_recruit_shop[tostring(ver)] or {}
    for k, v in pairs(ver_recruit_shop) do
        if v == day and RedPointUtil:getRecruitShopStatus(ver, day) == true then
            return true
        end
    end
    return false
end

function M:getRecruitShopStatus(version, day)
    local c_day = GameUtil:dayCompute()
    local v_day = version .. "_" .. day
    local day_bl = UserDataManager.local_data:getUserDataByKey("recruit_shop_" .. c_day .. "_" .. v_day, 0)
    return day_bl == 0
end

function M:recruitSetRedPoint(version, day)
    local c_day = GameUtil:dayCompute()
    local v_day = version .. "_" .. day
    UserDataManager.local_data:setUserDataByKey("recruit_shop_" .. c_day .. "_" .. v_day, 1)
end
--- 七日巡礼
__red_point[48] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("seven_tour")
    if rank_reward == 0 then
        return false
    end
    if type(rank_reward) == "table" and next(rank_reward) == nil then
        return false
    end
    for k, v in pairs(rank_reward) do
        if v > 0 then
            return true
        end
    end
    return red_flag
end

--- 七日巡礼---限时活动
__red_point[4801] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("seven_tour")
    if rank_reward == 0 then
        return false
    end
    if type(rank_reward) == "table" and next(rank_reward) == nil then
        return false
    end
    for k, v in pairs(rank_reward) do
        if v == 2 then
            return true
        end
    end
    return red_flag
end

function M:checkExchangeLimit(vsn)
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("seven_tour")
    if rank_reward == 0 then
        return false
    end
    if type(rank_reward) == "table" and next(rank_reward) == nil then
        return false
    end
    for k, v in pairs(rank_reward) do
        if v == vsn then
            return true
        end
    end
    return red_flag
end


--- 七日巡礼---一次性红点 用于监测是否弹出过拍脸图
__red_point[4802] = function()
    local red_flag = false
    local seven_tour_once = UserDataManager:getRedDotByKey("seven_tour_once")
    red_flag = seven_tour_once == 1
    return red_flag
end

-- 任务
__red_point[49] = function()
    local red_flag = false
    local quest_daily = UserDataManager:getRedDotByKey("quest_daily")
    local quest_weekly = UserDataManager:getRedDotByKey("quest_weekly")
    local quest_main = UserDataManager:getRedDotByKey("quest_main")
    red_flag = quest_daily == 1 or quest_weekly == 1 or quest_main == 1
    return red_flag
end

-- 问卷调查
__red_point[50] = function()
    local red_flag = true
    return red_flag
end

-- 是否有剧情完成奖励
__red_point[5001] = function()
    local red_flag = false
    local data = UserDataManager:getRegionalTaskDoneData()
    for k, v in pairs(data) do
        local status = v.status -- 0：未完成，1：可领取，2：已领取
        if status == 1 then
            red_flag = true
            break
        end
        local scenes = v.scenes or {}
        for k1, v1 in pairs(scenes) do
            if v1.status == 1 then
                red_flag = true
                break
            end
        end
        if red_flag then
            break
        end
    end
    return red_flag
end

-- 单地图是否有剧情完成奖励
__red_point[5002] = function(map_id)
    local red_flag = false
    map_id = tostring(map_id)
    local data = UserDataManager:getRegionalTaskDoneData()
    local data_item = data[map_id] or {}
    local scenes = data_item.scenes or {}
    for k, v in pairs(scenes) do
        if v.status == 1 then
            red_flag = true
            break
        end
    end
    return red_flag
end

-- 每日签到
__red_point[51] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("sign_daily_reward")
    red_flag = rank_reward == 1
    return red_flag
end

-- 在线奖励
__red_point[52] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("online_reward")
    red_flag = rank_reward == 1
    return red_flag
end

-- 双倍收益
__red_point[53] = function()
    local red_flag = false
    return red_flag
end

-- 首充
__red_point[54] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("first_payment")
    red_flag = rank_reward == 1
    return red_flag
end

--连续充值
__red_point[55] = function()
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(79) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("continuous_payment")
    red_flag = rank_reward == 1
    return red_flag
end

--武林战令
__red_point[56] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("war_order")
    red_flag = rank_reward == 1
    return red_flag
end

--特惠礼包
__red_point[57] = function()
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(81) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("gift_off")
    if rank_reward == 0 then
        return false
    end
    if type(rank_reward) == "table" and next(rank_reward) ~= nil then
        return true
    end
    red_flag = rank_reward == 1
    return red_flag
end

function M:checkGiftOffByVer(ver)
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("gift_off") or {}
    if rank_reward == 0 then
        return false
    end
    if type(rank_reward) == "table" and next(rank_reward) == nil then
        return false
    end
    for k, v in pairs(rank_reward) do
        if v == ver then
            return true
        end
    end
    return false
end

__red_point[259] = function()
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(259) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("gift_mould") or {}
    if rank_reward == 0 then
        return false
    end
    if type(rank_reward) == "table" and next(rank_reward) ~= nil then
        return true
    end
    red_flag = rank_reward == 1
    return red_flag
end


function M:checkGiftMouldByVer(ver)
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("gift_mould") or {}
    if rank_reward == 0 then
        return false
    end
    if type(rank_reward) == "table" and next(rank_reward) == nil then
        return false
    end
    for k, v in pairs(rank_reward) do
        if v == ver then
            return true
        end
    end
    return false
end

-- 天命化星礼包
__red_point[260] = function()
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(260) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("growth_gift") or {}
    if rank_reward == 0 then
        return false
    end
    if type(rank_reward) == "table" and next(rank_reward) ~= nil then
        return true
    end
    red_flag = rank_reward == 1
    return red_flag
end

-- 天命化星礼包
function M:checkGrowUpGiftByVer(ver)
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("growth_gift") or {}
    if rank_reward == 0 then
        return false
    end
    if type(rank_reward) == "table" and next(rank_reward) == nil then
        return false
    end
    for k, v in pairs(rank_reward) do
        if v == ver then
            return true
        end
    end
    return false
end

--新手礼包
__red_point[58] = function()
    local red_flag = false
    return red_flag
end

--日
__red_point[59] = function()
    if UserDataManager:getActivesRechargeByOpenId(83) == false then
        return false
    end
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("daily_gifts")
    red_flag = rank_reward == 1
    return red_flag
end

--月卡
__red_point[60] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("month_card")
    local month_card_alert = UserDataManager:getRedDotByKey("month_card_alert")
    local open_card = UserDataManager:getActivesRechargeByOpenId(84)
    if open_card == false then
        return false
    end
    red_flag = rank_reward == 1
    if red_flag == false then
        if month_card_alert == 1 and RedPointUtil:localRedPointJudge("month_card_alert") then
            red_flag = true
        end
    end
    return red_flag
end

--基金
__red_point[61] = function()
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(85) == false then
        return false
    end
    local red_dot_data = UserDataManager:getRedDotData() or {}
    local red_dot_data_fund = red_dot_data.growth_fund_new or {}
    local red_flag_data = red_dot_data_fund[tostring(85)] or 0
    red_flag = red_flag_data == 1
    return red_flag
end

--元宝商店
__red_point[62] = function()
    local red_flag = false
    return red_flag
end

--限时礼包
__red_point[63] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("limit_push")
    red_flag = rank_reward == 1
    return red_flag
end

--商店
__red_point[64] = function()
    local red_flag = false
    return red_flag
end

--江湖威望
__red_point[71] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("prestige_reward")
    red_flag = rank_reward == 1
    return red_flag
end

--江湖战令
__red_point[82] = function()
    local red_flag = false
    -- local rank_reward = UserDataManager:getRedDotByKey("war_order_heroic")
    -- red_flag = rank_reward == 1
    return red_flag
end
--周
__red_point[83] = function()
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(110) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("week_gifts")
    red_flag = rank_reward == 1
    return red_flag
end
--月
__red_point[84] = function()
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(111) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("month_gifts")
    red_flag = rank_reward == 1
    return red_flag
end

--单笔充值/新手福利
__red_point[87] = function()
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(114) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("bright_bless")
    red_flag = rank_reward == 1
    return red_flag
end

--卦签
__red_point[90] = function()
    local red_flag = false
    if UserDataManager:getActivesByOpenId(117) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("draw_quest")
    red_flag = rank_reward == 1
    if red_flag == false then
        red_flag = RedPointUtil:gerDrawTaskRedPoint()
        return red_flag
    end
    return red_flag
end

--基金-无限版
__red_point[5000] = function(ver, open_id)
    open_id = open_id or -1
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(open_id) == false then
        return false
    end
    local red_dot_data = UserDataManager:getRedDotData() or {}
    local red_dot_data_fund = red_dot_data.growth_fund_new or {}
    local red_flag_data = red_dot_data_fund[tostring(open_id)] or 0
    red_flag = red_flag_data == 1
    return red_flag
end

function M:gerDrawTaskRedPoint()
    local active_data = UserDataManager:getActivesDataByOpenId(117)
    local server_ts = UserDataManager:getServerTime()
    if active_data then
        local day = GameUtil:NumberOfDaysInterval(active_data.start_ts, server_ts, 0)
        local m_day = day + 1
        local chu_day = m_day % 7
        if chu_day == 0 then
            chu_day = 7
        end
        for i = 1, chu_day do
            local day_bl = self:drawTaskShopDayRedPoint(i)
            if day_bl == true then
                return true
            end
        end
    end
    return false
end

function M:drawTaskShopDayRedPoint(day)
    if UserDataManager:getActivesByOpenId(117) == false then
        return false
    end
    for k, v in pairs(UserDataManager.m_draw_shop) do
        if v == day and RedPointUtil:getDrawTaskShopStatus(day) == true then
            return true
        end
    end
    return false
end

--卦签每日限购首次红点
function M:getDrawTaskShopStatus(day)
    local c_day = GameUtil:dayCompute()
    local day_bl = UserDataManager.local_data:getUserDataByKey("draw_task_shop_" .. c_day .. "_" .. day, 0)
    return day_bl == 0
end

function M:setDrawTaskShopRedPoint(day)
    if UserDataManager:getActivesByOpenId(117) == false then
        return false
    end
    local c_day = GameUtil:dayCompute()
    UserDataManager.local_data:setUserDataByKey("draw_task_shop_" .. c_day .. "_" .. day, 1)
end

--锦囊玉轴
__red_point[91] = function()
    if UserDataManager:getActivesByOpenId(118) == false then
        return false
    end
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("scroll")
    red_flag = rank_reward == 1
    if red_flag == false then
        red_flag = RedPointUtil:getScrollActiveShopStatus()
    end
    return red_flag
end

--锦囊玉轴每日限购红点
function M:getScrollActiveShopStatus()
    if UserDataManager:getActivesByOpenId(118) == false then
        return false
    end
    local c_day = GameUtil:dayCompute()
    local day_bl = UserDataManager.local_data:getUserDataByKey("scroll_active_shop_" .. c_day, 0)
    return day_bl == 0
end

function M:setScrollActiveShopRedPoint()
    local c_day = GameUtil:dayCompute()
    UserDataManager.local_data:setUserDataByKey("scroll_active_shop_" .. c_day, 1)
end

--秘境探宝
__red_point[288] = function()
    if UserDataManager:getActivesByOpenId(288) == false then
        return false
    end
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("secret")
    red_flag = rank_reward == 1
    if red_flag == false then
        red_flag = RedPointUtil:getSecretActiveShopStatus()
    end
    return red_flag
end

--锦囊玉轴每日限购红点
function M:getSecretActiveShopStatus()
    if UserDataManager:getActivesByOpenId(288) == false then
        return false
    end
    local c_day = GameUtil:dayCompute()
    local day_bl = UserDataManager.local_data:getUserDataByKey("secret_active_shop_" .. c_day, 0)
    return day_bl == 0
end

function M:setSecretActiveShopRedPoint()
    local c_day = GameUtil:dayCompute()
    UserDataManager.local_data:setUserDataByKey("secret_active_shop_" .. c_day, 1)
end

--江湖茶楼 -存在未完成关卡
__red_point[92] = function()
    local red_flag = false
    -- local tea_reward = UserDataManager:getRedDotByKey("biography") --存在未完成关卡
    -- local biography_reward = UserDataManager:getRedDotByKey("qs_biography") --奖励未领取
    -- local qs_bio_chapter = UserDataManager:getRedDotByKey("qs_bio_chapter") --奖励未领取
    -- if tea_reward == 1 then
    -- 	red_flag = true
    -- end
    -- if red_flag == false then
    -- 	red_flag = biography_reward  == 1 or qs_bio_chapter == 1
    -- end
    return red_flag
end

--主界面显示江湖解锁新建筑的红点
function M:jiangHuJieSuo()
    --local reward_red_point = UserDataManager:getRedDotByKey("big_map_reward")
    local open_red_point = UserDataManager:getRedDotByKey("big_map_open")

    local cur_map, isDone = GameUtil:getCurMapData()
    local enter_map_list = UserDataManager:getTempData("enter_map_list") or {}
    local new_map_red_point =
        cur_map ~= nil and isDone == false and table.indexof(enter_map_list, cur_map.map_id) == false

    --return reward_red_point == 1 or open_red_point == 1 or new_map_red_point
    return open_red_point == 1 or new_map_red_point
end

--
function M:jiangHuRedPointSet()
    local jianzhu_tab = {}
    local cur_stage = UserDataManager:getCurStage()
    local regional_tab = ConfigManager:getCfgByName("regional_map")
    for i, v in pairs(regional_tab) do
        if v.stage_open > 0 and v.stage_open <= cur_stage then
            jianzhu_tab[i] = v
        end
    end
    for k, v in pairs(jianzhu_tab) do
        if self:jianZhuRedPoint(k) == true then
            UserDataManager.local_data:setUserDataByKey("jianghu_jiesuo_" .. k, 1)
        end
    end
end

function M:jianZhuRedPoint(id)
    local red_bl = UserDataManager.local_data:getUserDataByKey("jianghu_jiesuo_" .. id, 0)
    return red_bl == 0
end

--人设红点--奖励
__red_point[10001] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("welfare_npc")
    red_flag = rank_reward == 1
    return red_flag
end

--人设红点 -- 消息
__red_point[10002] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("welfare_npc_notice")
    red_flag = rank_reward == 1
    return red_flag
end

--人设红点 -- 武林手册
__red_point[10003] = function()
    local red_flag = false
    red_flag = RedPointUtil:checkShouceRedPoint()
    return red_flag
end

--人设红点 -- 送礼物
__red_point[10004] = function()
    local red_flag = false
    local m_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    local vip_tab = ConfigManager:getCfgByName("vip")
    local m_vip_exp = UserDataManager.user_data:getUserStatusDataByKey("vip_exp") or 0
    local max_num = table.nums(vip_tab)
    local max_vip = max_num - 1
    -- if m_vip >= max_vip then
    --     return false
    -- end
    local item_ids = UserDataManager.item_data:getItemsId()
    local item_table = {}
    local effect_num = 0
    for k, v in pairs(item_ids) do
        local data, cfg = UserDataManager.item_data:getItemDataById(v)
        if cfg and cfg.type == 16 then
            effect_num = effect_num + cfg.effect * data.num
            table.insert(item_table, v)
        end
    end
    local next_cfg = vip_tab[m_vip + 1]
    if next_cfg then
        local need_num = next_cfg.exp - m_vip_exp
        if effect_num >= need_num then
            return true
        end
    else
        if effect_num > 0 then
            return true
        end  
    end
    
    return red_flag
end

--人设红点 -- 特权
__red_point[10005] = function()
    local red_flag = false
    local vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    for i = 0, vip do
        local status = RedPointUtil:checkCanGet(i, vip)
        if status == 1 then
            red_flag = true
            break
        end
    end
    if red_flag == true then
        local vip_bag_once = UserDataManager:getRedDotByKey("vip_bag_once")
        if vip_bag_once == 0 then
            red_flag = false
        end
    end
    return red_flag
end

--武林志
__red_point[10006] = function()
    local red_flag = false
    local server_level = UserDataManager:getRedDotByKey("legend_quest")
    local server_legend = UserDataManager:getRedDotByKey("legend")
    if server_level == 1 then
        return true
    end
    if server_legend == 1 then
        return true
    end
    return red_flag
end

function M:checkCanGet(index, vip)
    local vip_received = UserDataManager.vip_received
    if vip >= index then
        for k, v in pairs(vip_received) do
            if v == index then
                return 2
            end
        end
        return 1
    else
        return 0
    end
    return 0
end

function M:checkShouceRedPoint()
    local cur_stage = UserDataManager:getCurStage()
    local all_jz = self:getNpcGuide2()
    local day = GameUtil:dayCompute()
    for k, v in pairs(all_jz) do
        local bl, cfg = self:getNpcGuideData(v)
        if cfg.unlock_days and cfg.unlock_days > 0 then
            if day >= cfg.unlock_days and cur_stage >= cfg.unlock_condition_param and bl == false then
                return true
            end
        else
            if cur_stage >= cfg.unlock_condition_param and bl == false then
                return true
            end
        end
    end
    return false
end

function M:getNpcGuide2()
    local npc_guide_list = {}
    local cur_stage = UserDataManager:getCurStage()
    local npc_guide_table = ConfigManager:getCfgByName("npc_guide")
    if cur_stage > 0 then
        for k, v in pairs(npc_guide_table) do
            if v.sort == 1 then
                table.insert(npc_guide_list, k)
            end
        end
    end
    return npc_guide_list
end

function M:getNpcGuideData(id)
    local npc_guide_tab = ConfigManager:getCfgByName("npc_guide")
    local guide_cfg = npc_guide_tab[id]
    local get_bl = false
    for k, v in pairs(UserDataManager.welfare_npc_guide) do
        if v == id then
            get_bl = true
        end
    end
    return get_bl, guide_cfg
end

--聊天
__red_point[74] = function()
    local red_flag = false
    for k, v in pairs(ChatUtil.channel_red_points) do
        if v == true then
            red_flag = true
            break
        end
    end
    if red_flag == false then
        if next(ChatUtil.player_red_points) ~= nil then
            red_flag = true
        end
    end
    return red_flag
end

---- 狐仙商人
__red_point[81] = function()
    local red_flag = false
    local shop_peddler = UserDataManager:getRedDotByKey("shop_peddler")
    red_flag = shop_peddler == 1
    return red_flag
end

--订制礼包
__red_point[93] = function()
    local red_flag = false
    if UserDataManager:getActivesDataByOpenId(120) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("custom_gift")
    red_flag = rank_reward == 1
    return red_flag
end

---- 6合1
__red_point[94] = function()
    local red_flag = false
    local rp_6in1 = UserDataManager:getRedDotByKey("hero_chest")
    red_flag = rp_6in1 == 1
    return red_flag

end



function M:__update_summerRP(rplist)
    M._redpoint_summerData = rplist
end

--英雄成长礼包
__red_point[101] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("hero_gift") or {}
    if rank_reward == 0 then
        return red_flag
    end
    if #rank_reward > 0 then
        return true
    end
    return red_flag
end

function M:checkHeroGiftByVer(ver)
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("hero_gift") or {}
    if rank_reward == 0 then
        return red_flag
    end
    for k, v in pairs(rank_reward) do
        if v == ver then
            return true
        end
    end
    return false
end

--每日18
__red_point[102] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("daily_charge")
    red_flag = rank_reward == 1
    return red_flag
end

--累计充值
__red_point[103] = function()
    if UserDataManager:getActivesRechargeByOpenId(130) == false then
        return false
    end
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("cmlt_recharge")
    red_flag = rank_reward == 1
    return red_flag
end

--藏宝图
__red_point[104] = function()
    if UserDataManager:getActivesByOpenId(131) == false then
        return false
    end
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("treasure")
    red_flag = rank_reward == 1
    return red_flag
end

--侠客试炼
__red_point[105] = function()
    if UserDataManager:getActivesByOpenId(132) == false then
        return false
    end
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("hero_train")
    local hero_train_login = UserDataManager:getRedDotByKey("hero_train_login")
    red_flag = rank_reward == 1 or hero_train_login == 1
    return red_flag
end

--江湖茶楼 -奖励未领取
__red_point[106] = function()
    local red_flag = false
    local biography_reward = UserDataManager:getRedDotByKey("biography_reward")
    red_flag = biography_reward == 1
    return red_flag
end

--签到基金
__red_point[110] = function()
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(143) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("sign_fund")
    red_flag = rank_reward == 1
    return red_flag
end

--盗帅红点
__red_point[113] = function()
    local rank_reward = UserDataManager:getRedDotByKey("daoshuai_once")
    local red_flag = rank_reward == 1
    if red_flag == false then
        return __red_point[11301]()
    end
    return red_flag
end

--盗帅礼包一次性
__red_point[11301] = function()
    local red_flag = M:localRedPointJudge("voyage_bag_once")
    return red_flag
end

-- 占星 前缘桥
__red_point[114] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("gacha7_once")
    -- local gacha = ConfigManager:getCfgByName("gacha")[7]
    -- local cost = gacha.cost
    -- local itemData = RewardUtil:getProcessRewardData(cost[1])
    -- if itemData.user_num >= 10 then
    -- 	red_flag = true
    -- end
    -- elseif itemData.user_num > 0 then
    -- 	if M:localRedPointJudge("red_predestined") then
    -- 		red_flag = true
    -- 	end
    -- end
    red_flag = rank_reward == 1
    return red_flag
end

-- 占星 神隐阁
__red_point[449] = function()
    local red_flag = false
    local gacha = ConfigManager:getCfgByName("gacha")[GlobalConfig.GACHA_SP_ID]
    local cost = gacha.cost
    local itemData = RewardUtil:getProcessRewardData(cost[1])
    if itemData.user_num >= itemData.data_num then
        red_flag = true
    end
    return red_flag
end

--轮盘
__red_point[116] = function()
    local red_flag = false
    local shop_peddler = UserDataManager:getRedDotByKey("roulette")
    local shop_peddler_once = UserDataManager:getRedDotByKey("roulette_once")
    red_flag = shop_peddler == 1 or shop_peddler_once == 1
    -- for i=1, 2 do
    -- 	local one_need = ConfigManager:getCommonValueById(375)
    -- 	if i == 2 then
    -- 		one_need = ConfigManager:getCommonValueById(376)
    -- 	end
    -- 	local itemData = RewardUtil:getProcessRewardData(one_need)
    -- 	if itemData.user_num >= itemData.data_num then
    -- 		red_flag = true
    -- 		break
    -- 	end
    -- end
    -- local open_compass_time = UserDataManager.local_data:getUserDataByKey("open_compass_time", nil)
    -- if open_compass_time then
    -- 	red_flag = false
    -- end
    return red_flag
end

--订阅特权
__red_point[119] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("subscribe")
    red_flag = rank_reward == 1
    return red_flag
end



--推荐
__red_point[121] = function()
    local red_flag = false
    if UserDataManager:getActivesRechargeByOpenId(79) == false then
        return false
    end
    if UserDataManager:getActivesRechargeByOpenId(130) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("recommend")
    red_flag = rank_reward == 1
    return red_flag
end

--特卖商店可购买
__red_point[122] = function()
    local red_flag = false
    local fixed_shop_goods = UserDataManager:getRedDotByKey("fixed_shop_goods")
    red_flag = fixed_shop_goods == 1
    return red_flag
end

--普通商店可刷新
__red_point[123] = function()
    local red_flag = false
    local shop_refresh = UserDataManager:getRedDotByKey("shop_refresh")
    red_flag = shop_refresh == 1
    return red_flag
end

--限时兑换
__red_point[124] = function()
    local red_flag = false
    local exchange_bl = UserDataManager:getRedDotByKey("exchange")
    red_flag = exchange_bl == 1
    return red_flag
end

--江湖进度
__red_point[125] = function()
    local red_flag = false
    local server_level = UserDataManager:getRedDotByKey("server_level")
    red_flag = server_level == 1
    return red_flag
end

--帮会战
__red_point[126] = function()
    local red_flag = false
    if red_flag == false then
        red_flag = __red_point[133]()
    end
    return red_flag
end

--入口、天机楼种族今日解锁入口
__red_point[128] = function()
    local red_flag = false
    red_flag = __red_point[1281]() --今日有剩余挑战次数时（每日有挑战层数限制） 点击后消失
    if red_flag == false then
        for k, v in pairs(UserDataManager.race_tower_status) do
            red_flag = RedPointUtil:race_tower_reward(v)
            if red_flag == true then
                break
            end
        end
    end
    return red_flag
end

--单种族塔红点
function M:race_tower_reward(race)
    local ta_bl = 0
    if race == 1 then --奖励
        ta_bl = UserDataManager:getRedDotByKey("qs_race_tower_gold")
    elseif race == 2 then
        ta_bl = UserDataManager:getRedDotByKey("qs_race_tower_fire")
    elseif race == 3 then
        ta_bl = UserDataManager:getRedDotByKey("qs_race_tower_wood")
    elseif race == 4 then
        ta_bl = UserDataManager:getRedDotByKey("qs_race_tower_water")
    end
    if ta_bl == 0 then
        if race == 1 then --快速挑战
            ta_bl = UserDataManager:getRedDotByKey("qs_race_tower_gold")
        elseif race == 2 then
            ta_bl = UserDataManager:getRedDotByKey("qs_race_tower_fire")
        elseif race == 3 then
            ta_bl = UserDataManager:getRedDotByKey("qs_race_tower_wood")
        elseif race == 4 then
            ta_bl = UserDataManager:getRedDotByKey("qs_race_tower_water")
        end
    end
    return ta_bl == 1
end

--今日有剩余挑战次数时（每日有挑战层数限制） 点击后消失
__red_point[1281] = function()
    for k, v in pairs(UserDataManager.race_tower_status) do
        local have_num = RedPointUtil:checkTowerOnceOpen(v)
        if have_num == true then
            return true
        end
    end
    return false
end

function M:checkTowerOnceOpen(race)
    local have_num = false
    for k, v in pairs(UserDataManager.race_tower_status) do
        local tower_tab = ConfigManager:getCfgByName("tower_race")
        local tower_cfg = tower_tab[v]
        if race == v then
            local use_num = UserDataManager.race_floor_times[tostring(v)] or 0
            if tower_cfg.floors_per_day - use_num > 0 then
                have_num = true
                break
            end
        end
    end
    if have_num == true then
        local red_day = UserDataManager:getRedDotByKey("tower_race_once_" .. race)
        return red_day == 1
    end
    return have_num
end

--入口、天机楼入口
__red_point[129] = function()
    local red_flag = false
    return red_flag
end

function M:checkTaskStatus(task_id)
    local daily_quests = UserDataManager.quest.daily_quests or {}
    local task_data = daily_quests[tostring(task_id)]
    if task_data then
        return task_data.status == 0
    end
    return false
end

--新四象阵
__red_point[130] = function()
    local red_flag = false
    local boss_b1 = UserDataManager:getRedDotByKey("four_tower_times") --一次性红点
    local once_bl = UserDataManager:getRedDotByKey("four_tower_reward") --可领奖
    red_flag = boss_b1 == 1 or once_bl == 1
    return red_flag
end

--五行论剑被攻击记录
__red_point[131] = function()
    local red_flag = false
    -- local race_arena_beat = UserDataManager:getRedDotByKey("race_arena_beat") --被攻击记录
    -- if  race_arena_beat == 1 then
    -- 	red_flag = true
    -- end
    return red_flag
end

--天机楼
__red_point[132] = function()
    local red_flag = false
    local task_bl = UserDataManager:getRedDotByKey("task_red_point_1013") --日常任务1013未完成时 点击后消失
    local reward_bl = UserDataManager:getRedDotByKey("qs_tower") --奖励未领取 不满足条件后消失
    red_flag = task_bl == 1 or reward_bl == 1
    -- if red_flag == false then
    -- 	return RedPointUtil:towerCanQuick()--可以快速挑战时 不满足条件后消失
    -- end
    return red_flag
end

--帮会战--公会
__red_point[133] = function()
    local red_flag = false
    local guild_war_round_report = UserDataManager:getRedDotByKey("guild_war_round_report") --还没看过每周胜负时
    red_flag = guild_war_round_report == 1
    if red_flag == false then
        red_flag = __red_point[13301]()
    end
    return red_flag
end

--帮会争锋-前往战场按钮
__red_point[13301] = function()
    local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
    if guild_id == 0 then
        return
    end
    local red_flag = false
    local guild_war_team_dispatch = UserDataManager:getRedDotByKey("guild_war_team_dispatch") --公会战红点 公会战有未派遣的队伍：
    local guild_war_sign_up = UserDataManager:getRedDotByKey("guild_war_sign_up") --公会战可报名
    red_flag = guild_war_team_dispatch == 1 or guild_war_sign_up == 1
    return red_flag
end

--帮会战--竞技场
__red_point[136] = function()
    local red_flag = false
    local guild_war_round_report = UserDataManager:getRedDotByKey("guild_war_round_report") --还没看过每周胜负时
    red_flag = guild_war_round_report == 1
    if red_flag == false then
        red_flag = __red_point[13301]()
    end
    if red_flag == false then
        red_flag = __red_point[12002]()
    end
    return red_flag
end

--试炼遗迹
__red_point[138] = function()
    local red_flag = false
    return red_flag
end

--侠客试炼 新
__red_point[139] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("train_challenge")
    local hero_train_login = UserDataManager:getRedDotByKey("hero_train_login")
    red_flag = rank_reward == 1 or hero_train_login == 1
    return red_flag
end

--聚宝山
__red_point[140] = function()
    local red_flag = false
    local richman = UserDataManager:getRedDotByKey("richman")
    local richman_dispatch = UserDataManager:getRedDotByKey("richman_dispatch")
    red_flag = richman == 1 or richman_dispatch == 1
    return red_flag
end

--江湖传奇
__red_point[141] = function()
    local red_flag = false
    local legend = UserDataManager:getRedDotByKey("legend")
    local legend_quest = UserDataManager:getRedDotByKey("legend_quest")
    red_flag = legend == 1 or legend_quest == 1
    return red_flag
end

--- 江湖传奇日常任务红点
__red_point[14102] = function()
    local red_flag = false
    --local legend_quest = UserDataManager:getRedDotByKey("legend_quest")
    --red_flag = legend_quest == 1
    return red_flag
end

--- 江湖传奇主线任务红点
__red_point[14103] = function()
    local red_flag = false
    --local qs_high_arena = UserDataManager:getRedDotByKey("legend_quest")
    --red_flag = qs_high_arena == 1
    return red_flag
end

--天机楼 快速挑战
function M:towerCanQuick()
    local cur_floor = UserDataManager.tower_floor or 0
    if cur_floor == 0 then
        return false
    end
    local tab_tower_all = ConfigManager:getCfgByName("tower_stage")
    local tab_tower_main = tab_tower_all[0]
    local max_floor = table.nums(tab_tower_main)
    if cur_floor >= max_floor then
        return false
    end
    local ratio = ConfigManager:getCommonValueById(288)
    local main_combat = RedPointUtil:checkMainTeamCombat(0)
    local enemy_combat = RedPointUtil:checkEnemyTeamCombat(0, cur_floor)
    local com_a = (main_combat * ratio)
    local com_b = enemy_combat * 100
    return com_a > com_b
end

function M:checkMainTeamCombat(race)
    local combat = 0
    local main_team = {}
    if race == 0 then
        local main_team = table.copy(UserDataManager.hero_data:getTeamByKey("best", "stage"))
        for k, v in pairs(main_team) do
            local data, cfg = UserDataManager.hero_data:getHeroDataById(v)
            if data ~= nil then
                combat = data.combat + combat
            end
        end
    else
    end
    return combat
end

function M:checkEnemyTeamCombat(race, floor)
    local sub_combate = 0
    local e_l = {}
    local tab_tower_all = ConfigManager:getCfgByName("tower_stage")
    local tab_tower_main = tab_tower_all[race]
    local floor_data = tab_tower_main[floor + 1]
    --local stage_tab = ConfigManager:getCfgByName("stage_battle")
    if floor_data then
        sub_combate = UserDataManager:computStageBattleCombat(floor_data.battle_id)
    end
    return sub_combate
end

--五行论剑入口
__red_point[115] = function()
    local red_flag = false
    local race_arena = UserDataManager:getRedDotByKey("race_arena") --前三名点赞
    -- local race_arena_times = UserDataManager:getRedDotByKey("race_arena_times") --剩余次数
    local race_arena_reward = UserDataManager:getRedDotByKey("race_arena_reward") --奖励
    if race_arena_reward == 1 then
        return true
    end
    if race_arena == 1 then
        return true
    end
    return red_flag
end

--五行论剑点赞
__red_point[11501] = function()
    local red_flag = false
    local race_arena = UserDataManager:getRedDotByKey("race_arena")
    red_flag = race_arena == 1
    return red_flag
end

--五行论剑入口
__red_point[234] = function()
    local red_flag = false
    local race_arena = UserDataManager:getRedDotByKey("season_race_arena") --前三名点赞
    -- local race_arena_times = UserDataManager:getRedDotByKey("race_arena_times") --剩余次数
    local race_arena_reward = UserDataManager:getRedDotByKey("season_race_arena_reward") --奖励
    if race_arena_reward == 1 then
        return true
    end
    if race_arena == 1 then
        return true
    end
    return red_flag
end

--五行论剑点赞
__red_point[23401] = function()
    local red_flag = false
    local race_arena = UserDataManager:getRedDotByKey("season_race_arena")
    red_flag = race_arena == 1
    return red_flag
end


--武道场
__red_point[137] = function()
    local red_flag = false
    local server_level = UserDataManager:getRedDotByKey("raid")
    red_flag = server_level == 1
    return red_flag
end

--客服
__red_point[142] = function()
    local red_flag = false
    local server_level = UserDataManager:getRedDotByKey("customer")
    red_flag = server_level == 1
    return red_flag
end

--苗疆觅宝
__red_point[169] = function()
    local red_flag = false
    local mining_team = UserDataManager:getRedDotByKey("mining_team") --有编队可用
    local mining_reward = UserDataManager:getRedDotByKey("mining_reward") --有奖励可用
    local mining_log = UserDataManager:getRedDotByKey("mining_blog") --有奖励可用
    local mining_shop = UserDataManager:getRedDotByKey("mining_shop_goods") --苗疆商店
    red_flag = mining_team == 1 or mining_reward == 1 or mining_log == 1 or mining_shop == 1
    return red_flag
end

--苗疆商店
__red_point[170] = function()
    local red_flag = false
    local mining_shop_goods = UserDataManager:getRedDotByKey("mining_shop_goods") --有货物可兑换
    red_flag = mining_shop_goods == 1
    return red_flag
end

__red_point[176] = function()
    --if M.__getIsDBChannle == nil then
    --    M.__getIsDBChannle = false
    --    if SDKUtil.is_gmsdk then  
    --        local application_Id = SDKUtil.sdk_params.applicationId  
    --        if application_Id == "com.hermes.wl" or SDKUtil.sdk_params.app == 2 then
    --            M.__getIsDBChannle = true
    --        end
    --    end
    --end
    --
    --if M.__getIsDBChannle then
    --    if nil == M.__key_170_data then
    --        local server_level = UserDataManager:getRedDotByKey("tiktok")
    --        M.__key_170_data  = server_level == 1
    --    end
    --
    --    return M.__key_170_data
    --else
    --    return false
    --end 
    -- 王浩需求，永久关闭该红点
    return false
end

--老四象阵
__red_point[194] = function()
    local red_flag = false
    local boss_b1 = UserDataManager:getRedDotByKey("five") --当前挑战未完成
    local once_bl = UserDataManager:getRedDotByKey("five_once")
    red_flag = boss_b1 == 1 and once_bl == 1
    return red_flag
end

--法宝红点
__red_point[190] = function()
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("relic_new_unlock")
    red_flag = relic_new_unlock == 1 
    return red_flag
end

--- 侠客争锋
__red_point[197] = function()
    if BtnOpenUtil:isBtnOpen(197) == false then
        return false
    end
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("hero_rank")
    red_flag = relic_new_unlock == 1
    return red_flag
end

--- 制作人赠礼
__red_point[198] = function()
    if BtnOpenUtil:isBtnOpen(198) == false then
        return false
    end
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("producer")
    red_flag = relic_new_unlock == 1
    return red_flag
end

--- 阶梯礼包
__red_point[196] = function()
    if BtnOpenUtil:isBtnOpen(196) == false then
        return false
    end
    if UserDataManager:getActivesRechargeByOpenId(196) == false then
        return false
    end
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("gift_value")
    red_flag = relic_new_unlock == 1
    return red_flag
end
--- 每日阶梯礼包
__red_point[200] = function()
    if BtnOpenUtil:isBtnOpen(200) == false then
        return false
    end
    if UserDataManager:getActivesRechargeByOpenId(200) == false then
        return false
    end
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("gift_value_daily")
    red_flag = relic_new_unlock == 1
    return red_flag
end
--- 每周阶梯礼包
__red_point[201] = function()
    if BtnOpenUtil:isBtnOpen(201) == false then
        return false
    end
    if UserDataManager:getActivesRechargeByOpenId(201) == false then
        return false
    end
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("gift_value_week")
    red_flag = relic_new_unlock == 1
    return red_flag
end
--- 限时阶梯礼包
__red_point[202] = function()
    if BtnOpenUtil:isBtnOpen(202) == false then
        return false
    end
    if UserDataManager:getActivesRechargeByOpenId(202) == false then
        return false
    end
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("gift_value_limit")
    red_flag = relic_new_unlock == 1
    return red_flag
end

--- 支付宝红包
__red_point[217] = function()
    if (SDKUtil.sdk_params.app ~= 2) then
        return false
    end
    if UserDataManager:getActivesByOpenId(217) == false then
        return false
    end
    local red_flag = M:localRedPointJudge("AlipayRedBagActivityRedDot")
    return red_flag
end

--- 充值返利，聚宝盆
__red_point[216] = function()
    local red_flag = false
    if UserDataManager:getActivesByOpenId(216) == false then
        return false
    end
    local relic_new_unlock = UserDataManager:getRedDotByKey("bowl_gift")
    red_flag = relic_new_unlock == 1
    return red_flag
end

--- 铸剑大会入口
__red_point[177] = function()
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("sword_open")
    red_flag = relic_new_unlock == 1
    return red_flag
end

--- 全民铸剑
__red_point[204] = function()
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("sword_quest")
    red_flag = relic_new_unlock == 1
    return red_flag
end

--- 江湖召集
__red_point[205] = function()
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("sword_share")
    red_flag = relic_new_unlock == 1
    if not red_flag then
        red_flag = M:localRedPointJudge("CastingSwordShareBtnState")
    end
    return red_flag
end

--- 明星好礼
__red_point[206] = function()
    local red_flag = false
    local relic_new_unlock = UserDataManager:getRedDotByKey("sword_login")
    red_flag = relic_new_unlock == 1
    return red_flag
end

--- 铸剑--江湖大事件
__red_point[207] = function()
    local openId = 207
    local curTimer = UserDataManager:getServerTime()
    local activityData = UserDataManager:getActivesDataByOpenId(openId)
    if not activityData then
        return false
    end
    local isShowRedDot = curTimer >= activityData.start_ts and  curTimer < activityData.show_start_ts
    if not isShowRedDot then
        return false
    end
    isShowRedDot = RedPointUtil:isShowCastingSwordSinatvRedDot(openId)
    if not isShowRedDot then
        return false
    end
    local red_flag = M:localRedPointJudge("CastingSwordBigEvent")
    return red_flag
end

--- 铸剑--光明顶
__red_point[208] = function()
    local openId = 208
    local curTimer = UserDataManager:getServerTime()
    local activityData = UserDataManager:getActivesDataByOpenId(openId)
    if not activityData then
        return false
    end
    local isShowRedDot = curTimer >= activityData.start_ts and  curTimer < activityData.show_start_ts
    if not isShowRedDot then
        return false
    end
    isShowRedDot = RedPointUtil:isShowCastingSwordSinatvRedDot(openId)
    if not isShowRedDot then
        return false
    end
    local red_flag = M:localRedPointJudge("CastingSwordLightTop")
    return red_flag
end

--- 铸剑--分享按钮本地小红点
__red_point[100205] = function()
    local red_flag = M:localRedPointJudge("CastingSwordShareBtnState")
    return red_flag
end

--鸿运祈福--孔明灯
__red_point[231] = function()
    local red_flag = false
    local game_street = UserDataManager:getRedDotByKey("wish")
    red_flag = game_street == 1
    return red_flag
end


--满月兑换--
__red_point[233] = function()
    local red_flag = false
    if BtnOpenUtil:isBtnOpen(233) == false then
        return false
    end
    if UserDataManager:getActivesByOpenId(233) == false then
        return false
    end
    local month_exchange = UserDataManager:getRedDotByKey("month_exchange")
    red_flag = month_exchange == 1
    return red_flag
end


--神兵养成--
__red_point[232] = function()
    local red_flag = false
    if BtnOpenUtil:isBtnOpen(232) == false then
        return false
    end
    if UserDataManager:getActivesRechargeByOpenId(232) == false then
        return false
    end
    local equip_gift = UserDataManager:getRedDotByKey("equip_gift")
    if equip_gift ~= 0 and type(equip_gift) == "table" and next(equip_gift) ~= nil then
        return true
    end
    red_flag = equip_gift == 1
    return red_flag
end

--法宝可升级红点
function M:checkWeaponCanLvup()
    local tab_cfg = ConfigManager:getCfgByName("treasure_config")
    for k,v in pairs(UserDataManager.m_relics) do
        local cur_wea_data = tab_cfg[tonumber(k)]
        local wea_cfg = cur_wea_data.detail[v.lv] or cur_wea_data.detail[1]
        local cost_reward = RewardUtil:getProcessRewardData(wea_cfg.cost[1])
        if cost_reward.user_num >= cost_reward.data_num then
            return true
        end
    end
    return false
end

--小游戏
__red_point[1000001] = function()
    local red_flag = false
    local game_street = UserDataManager:getRedDotByKey("game_street")
    red_flag = game_street == 1
    return red_flag
end

__red_point[220] = function()
    local red_flag = false
    local season_data = UserDataManager.m_season_data or {}
    local season_recv = 1 -- 0 是可领取 1不可领取
    if season_data and next(season_data) and season_data.season_recv then
        season_recv = season_data.season_recv 
    end
    red_flag = season_recv == 0 and GameUtil:isSeasonPreviewOpen()
    red_flag = red_flag or (RedPointUtil:getCommonGiftRedByOpenId(313, true) and GameUtil:isSeasonPreviewOpen())
    return red_flag
end

--- 花火大赏入口红点
__red_point[221] = function()
    local red_flag = M:localRedPointJudge("petardShop_everyDayRedDot")
    if not red_flag then
        local double_twelve_daily = UserDataManager:getRedDotByKey("double_twelve_daily")
        red_flag = double_twelve_daily == 1 
    end
    if not red_flag then
        local serverRedDot = UserDataManager:getRedDotByKey("double_twelve")
        red_flag = serverRedDot == 1
    end
    return red_flag
end

--- 月影传说入口红点
__red_point[235] = function()
    local red_flag = false
    local mood_shadow = UserDataManager:getRedDotByKey("mood_shadow")
    red_flag = mood_shadow == 1
    return red_flag
end

--- 月影礼包入口红点
__red_point[236] = function()
    local active_data = UserDataManager:getActivesRechargeDataByOpenId(236)
    local red_flag = M:localRedPointJudge("MoonShadowGift")
    return red_flag and active_data and active_data.open_status == 1
end

--- 月影之约入口红点
__red_point[237] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(237)
    local red_flag = M:localRedPointJudge("MoonShadowDate")
    return red_flag and active_data and active_data.open_status == 1
end

--- 月影试炼入口红点
__red_point[238] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(238)
    local red_flag = M:localRedPointJudge("MoonShadowBattle")
    return red_flag and active_data and active_data.open_status == 1
end

--赛季商店
__red_point[239] = function()
    local red_flag = false
    local mining_shop_goods = UserDataManager:getRedDotByKey("season_shop_goods") --有货物可兑换
    red_flag = mining_shop_goods == 1
    return red_flag
end

--玩家回归，选择留在老服后是否有奖励可以领取
__red_point[241] = function()
    if UserDataManager.comeback_status == 2 then
        local reward_got = UserDataManager.comeback_rcvd or {}
        local current_day = math.floor((UserDataManager:getServerTime() - UserDataManager.comeback_ts) / (60 * 60 * 24)) + 1
        local reward_got_flag = false
        if current_day and current_day >= 1 and current_day <= 7 then
            for day = 1, current_day do
                reward_got_flag = false
                for _, value in ipairs(reward_got) do
                    if value == day then
                        reward_got_flag = true
                        break
                    end
                end
                if reward_got_flag == false then
                    return true
                end
            end
        end
    end
    return false
end

--- 侠客集结
__red_point[242] = function()
    local red_flag = false
    local rank_reward = UserDataManager:getRedDotByKey("hero_gather_active")
    red_flag = rank_reward == 1
    return red_flag
end

--- 侠客兑换
__red_point[243] = function()
    local red_flag = false
    if UserDataManager:getActivesByOpenId(243) == false then
        return false
    end
    local rank_reward = UserDataManager:getRedDotByKey("card_exchange")
    red_flag = rank_reward == 1
    return red_flag
end

--满月兑换--
__red_point[251] = function()
    local red_flag = false
    if BtnOpenUtil:isBtnOpen(251) == false then
        return false
    end
    if UserDataManager:getActivesByOpenId(251) == false then
        return false
    end
    local month_exchange = UserDataManager:getRedDotByKey("eat_exchange") or 0
    red_flag = rank_reward == 1
    return red_flag
end

--- 奇门遁甲入口红点
__red_point[246] = function()
    local red_flag = false
    local gve_daily = UserDataManager:getRedDotByKey("gve_daily")
    local gve_guild_reward = UserDataManager:getRedDotByKey("gve_guild_reward")
    local gve_quest = UserDataManager:getRedDotByKey("gve_quest")
    red_flag = gve_daily == 1 or gve_guild_reward == 1 or gve_quest == 1

    --新赛季前6个小时，因为活动不开启，所以不展示入口红点
    if red_flag == true then 
        red_flag = ((UserDataManager:getServerTime() - UserDataManager:getCurSeasonStartTime()) / (60 * 60)) > 6
    end
    
    return red_flag
end

--- 邪极魅影入口红点
__red_point[247] = function()
    local red_flag = false
    local mood_shadow = UserDataManager:getRedDotByKey("evil_shadow")
    red_flag = mood_shadow == 1
    return red_flag
end

--- 魅影礼包入口红点
__red_point[248] = function()
    local active_data = UserDataManager:getActivesRechargeDataByOpenId(248)
    local red_flag = M:localRedPointJudge("EvilShadowGift")
    return red_flag and active_data and active_data.open_status == 1
end

--- 魅影之约入口红点
__red_point[249] = function(ver)
    ver = ver or 0
    local red_flag = false
    local mood_shadow = UserDataManager:getRedDotByKey("hero_event")
    if mood_shadow ~= 0 then --没有数据默认是0
        for k, v in pairs(mood_shadow) do
            if v == ver then
                red_flag = k == 1
                break
            end
        end
    end
    return red_flag
end

--- 魅影试炼入口红点
__red_point[250] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(250)
    local red_flag = M:localRedPointJudge("EvilShadowBattle")
    return red_flag and active_data and active_data.open_status == 1
end

--- 龙泉剑影入口红点
__red_point[252] = function()
    local red_flag = false
    local mood_shadow = UserDataManager:getRedDotByKey("dragonsword")
    red_flag = mood_shadow == 1
    return red_flag
end


--- 神兵谱升级红点
__red_point[258] = function()
    local red_flag = false
    local season = UserDataManager:getCurSeason()
    if season < 2 then
        return false
    end
    local hig_lv = 0 --目前最高的等级
    if UserDataManager.m_thrones_upgrade == nil then
        return false
    end  
    if next(UserDataManager.m_thrones_upgrade) == nil then
        hig_lv = 0
    end
    if UserDataManager.m_thrones_upgrade.level then
        for k,v in pairs(UserDataManager.m_thrones_upgrade.level) do
            if v.lv > hig_lv then
                hig_lv = v.lv
            end
        end
    end

	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = UserDataManager.m_thrones_upgrade.evo or 0
	local cur_throne = tag_tab[evo]
	local lv_limit = cur_throne.limit --图鉴等级上限

    local m_cry_lv = UserDataManager.m_clv --我的练武场等级

    local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
    local quality = UserDataManager.m_thrones_upgrade.evo or 0
    local throne_cfg = tag_tab[quality]
    if throne_cfg == nil then
        return false
    end
    local cue_season = UserDataManager:getCurSeason()
    if cue_season < throne_cfg.season then --赛季控制
        return false
    end
    local cry_lv = throne_cfg.hero_level or 0 --进阶需要的练武场等级
    if hig_lv >= lv_limit then --检查是否可以升阶 
        for i = 1,6 do
            local lv_data = UserDataManager.m_thrones_upgrade.level[tostring(i)] or {lv = 0}
            local lv = lv_data.lv or 0
            if lv < lv_limit then
                return false
            end
        end
   
        if m_cry_lv >= cry_lv then
            local consume = throne_cfg.consume 
            local cons_data1 = RewardUtil:getProcessRewardData(consume[1])
            local cons_data2 = RewardUtil:getProcessRewardData(consume[2])
            if cons_data1.user_num >= cons_data1.data_num and cons_data2.user_num >= cons_data2.data_num then
                return true
            end 
        end
    else --检查是否可以升级
        local equip_throne_level_tab = ConfigManager:getCfgByName("equip_throne_level")
        if equip_throne_level_tab[hig_lv] == nil then
            return false
        end
        local consume = equip_throne_level_tab[hig_lv].consume 
        local cons_data1 = RewardUtil:getProcessRewardData(consume[1])
        local cons_data2 = RewardUtil:getProcessRewardData(consume[2])
        if cons_data1.user_num >= cons_data1.data_num and cons_data2.user_num >= cons_data2.data_num then
            return true
        end 
    end
    return false
end

--新年活动奖励
__red_point[261] = function()
    local red_flag = false
    local spring_festival_flag = UserDataManager:getRedDotByKey("spring_festival")
    red_flag = spring_festival_flag == 1
    return red_flag
end

--阖家团圆
__red_point[264] = function()
    local red_flag = false
    local spring_festival_flag = UserDataManager:getRedDotByKey("spring_festival")
    red_flag = spring_festival_flag == 1
    return red_flag
end


--岁岁平安
__red_point[265] = function()
    local red_flag = false
    local active_data = UserDataManager:getActivesDataByOpenId(265)
    if active_data == nil then
        return false
    end
    local start_ts = active_data.start_ts or 0
    local diff_time = start_ts - UserDataManager:getServerTime() + 2
    if diff_time > 0 then
        return false
    end
    local spring_festival_flag = UserDataManager:getRedDotByKey("spring_festival_shop") --需要主动清理
    red_flag = spring_festival_flag == 1
    if not red_flag then
        local reward_data = RewardUtil:getProcessRewardData({103,5365,1})
        if reward_data.user_num >= 10 then
            return true
        end
    end
    if not red_flag then
        return M:localRedPointJudge("spring_festival_shop_gift") --礼包一次性红点
    end
    return red_flag
end

--闲侠庙会
__red_point[267] = function()
    local red_flag = false
    local active_data = UserDataManager:getActivesDataByOpenId(267)
    if active_data == nil then
        return
    end
    local start_ts = active_data.start_ts or 0
    local diff_time = start_ts - UserDataManager:getServerTime() + 2
    if diff_time > 0 then
        return false
    end
    local mult_game_street_flag = UserDataManager:getRedDotByKey("mult_game_street_reward") --有奖励未领取
    red_flag = mult_game_street_flag == 1
    if not red_flag then
        local red_data = UserDataManager.red_dot["mult_game_street"]
        local actives_data = UserDataManager:getMultActivesByOpenId(267)
        if red_data and red_data.status == 1 and red_data.versions then
            for k,v in pairs(red_data.versions) do
                local click_bl = M:localRedPointJudge("mult_game_street_"..v)
                if click_bl == true then
                    return true
                end
            end
        end
    end
    return red_flag
end

--- 不负风流-花落谁家
__red_point[269] = function(ver)
    ver = ver or 0
    local red_flag = false
    local mood_shadow = UserDataManager:getRedDotByKey("hero_event_gacha")
    if mood_shadow ~= 0 then --没有数据默认是0
        for k, v in pairs(mood_shadow) do
            if v == ver then
                red_flag = k == 1
                break
            end
        end
    end
    return red_flag
end

--- 不负风流
__red_point[270] = function(ver)
    local red_flag = false
    local hero_event_gift = UserDataManager:getRedDotByKey("hero_event_gift")
    red_flag = __red_point[269](ver) or __red_point[249](ver) or hero_event_gift == 1
    return red_flag
end

--- 元宵节
__red_point[271] = function()
    local red_flag = false
    local lantern_flag = UserDataManager:getRedDotByKey("lantern")
    red_flag = lantern_flag == 1
    return red_flag
end

-- 元宵节集市一次性红点
__red_point[273] = function()
    local red_flag = false
    local lantern_market_once = RedPointUtil:localRedPointJudge("lantern_market_once")
    red_flag = lantern_market_once
    return red_flag
end

--- 元宵节免费礼包
__red_point[275] = function()
    local red_flag = false
    local lantern_flag = UserDataManager:getRedDotByKey("lantern_gift")
    red_flag = lantern_flag == 1
    return red_flag
end

__red_point[276] = function()
    local red_flag = false
    local huashan_flag = UserDataManager:getRedDotByKey("arena_mountain_hua")
    red_flag = huashan_flag == 1
    return red_flag
end

--夺宝奇兵
__red_point[287] = function()
    local red_flag = false
    local active_mining_team = UserDataManager:getRedDotByKey("active_mining_team") --有编队可用
    local active_mining_blog = UserDataManager:getRedDotByKey("active_mining_blog") --有奖励可用
    red_flag = active_mining_team == 1 or active_mining_blog == 1
    return red_flag
end

-- 华山论剑商店一次性红点
__red_point[27601] = function()
    local red_flag = false
    local huashan_shop_once = RedPointUtil:localRedPointJudge("huashan_shop_once")
    red_flag = huashan_shop_once
    return red_flag
end

--华山论剑段位奖励
__red_point[27602] = function()
    local red_flag = false
    local qs_high_arena = UserDataManager:getRedDotByKey("qs_arena_mountain_hua")
    red_flag = qs_high_arena == 1
    return red_flag
end

-- 华山论剑首页一次性红点
__red_point[27603] = function()
    local red_flag = false
    local huashan_shop_once = RedPointUtil:localRedPointJudge("huashan_index_once")
    red_flag = huashan_shop_once
    return red_flag
end

-- 华山论剑华山论剑被挑战 
__red_point[27604] = function()
    local red_flag = false
    local arena_mountain_hua_beat = RedPointUtil:localRedPointJudge("arena_mountain_hua_beat")
    red_flag = arena_mountain_hua_beat == 1
    return red_flag
end

-- 游戏人生红点
__red_point[285] = function()
    local red_flag = RedPointUtil:localRedPointJudge("simulate_everyDayRedDot")
    if not red_flag then
        local life_resetData = UserDataManager:getRedDotByKey("life_reset")
        red_flag = life_resetData == 1
    end
    return red_flag
end
-- 游戏人生红点
__red_point[319] = function()
    local red_flag = RedPointUtil:localRedPointJudge("simulate_everyDayRedDot")
    if not red_flag then
        local life_resetData = UserDataManager:getRedDotByKey("life_reset")
        red_flag = life_resetData == 1
    end
    return red_flag
end


-- 花朝佳节入口
__red_point[289] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(289)
    if not activeData then
        return false
    end
    local curServerTimer = UserDataManager:getServerTime()
    if curServerTimer > activeData.show_start_ts then
        return false
    end
    local red_flag = RedPointUtil:localRedPointJudge("flower_mainRedDot")
    if not red_flag then
        local curVersion = activeData.version
        local common_giftList = UserDataManager:getRedDotByKey("common_gift")
        if type(common_giftList) ~= "number" then
            for _, itemData in pairs(common_giftList) do
                -- 292是里边的礼包子活动
                if itemData[1] == 292 and itemData[2] == curVersion then
                    return true
                end
            end
        end
        local common_questData = UserDataManager:getRedDotByKey("common_quest")
        if type(common_questData) ~= "number" then
            for _, itemData in pairs(common_questData) do
                -- 290是里边的任务子活动
                if itemData[1] == 290 and itemData[2] == curVersion then
                    return true
                end
            end
        end
    end
    return red_flag
end

__red_point[294] = function()
    local red_flag = false
    local wdtower = UserDataManager:getRedDotByKey("wdtower")
    red_flag = wdtower == 1
    return red_flag
end

-- 极阴塔推送礼包一次性红点
__red_point[29401] = function()
    local red_flag = false
    local have_gift = GameUtil:getGiftStatusByOpenId(294)
    local dark_tower_reward_once = RedPointUtil:localRedPointJudge("wd_tower_reward_once")
    red_flag = dark_tower_reward_once  and have_gift
    return red_flag
end

--- 古剑奇谭入口红点
__red_point[280] = function()
    local red_flag = __red_point[281]()
    if red_flag == false then
        red_flag = __red_point[284]()
    end
    return red_flag
end

--- 古剑奇谭-煞剑出鞘
__red_point[281] = function()
    local gu_jian_draw = UserDataManager:getRedDotByKey("sword_sign")
    local red_flag = gu_jian_draw == 1
    return red_flag
end

--- 古剑奇谭-商铺
__red_point[284] = function()
    local active_data = UserDataManager:getActivesRechargeDataByOpenId(284)
    local red_flag = M:localRedPointJudge("GuJianQiTanGiftRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

--- 通用返利
__red_point[306] = function()
    local active_data = UserDataManager:getActivesRechargeDataByOpenId(306)
    local red_flag = M:localRedPointJudge("TongYongFanLiRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

--- 通用抽奖
__red_point[314] = function()
    --local red_flag = M:localRedPointJudge("TongYongGachaGift")
    local red_flag = false
    if not red_flag then
        local gacha_active = UserDataManager:getRedDotByKey("gacha_active")
        red_flag = gacha_active == 1
    end
    
    return red_flag
end

--- 古剑奇谭-煞剑出鞘
__red_point[320] = function()
    local myth_rank = UserDataManager:getRedDotByKey("myth_rank")
    local myth_rise = UserDataManager:getRedDotByKey("myth_rise")
    local red_flag = myth_rank == 1 or myth_rise == 1
    return red_flag
end

function M:getCommonGiftRedByOpenId(open_id, is_recharge)
    local activeData = nil
    if is_recharge then
        activeData = UserDataManager:getActivesRechargeDataByOpenId(open_id)
    else
        activeData = UserDataManager:getActivesDataByOpenId(open_id)
    end
    if not activeData then
        return false
    end
    local curServerTimer = UserDataManager:getServerTime()
    if curServerTimer > activeData.show_start_ts then
        return false
    end
    local curVersion = activeData.version
    local common_giftList = UserDataManager:getRedDotByKey("common_gift")
    if type(common_giftList) ~= "number" then
        for _, itemData in pairs(common_giftList) do
            if itemData[1] == open_id and itemData[2] == curVersion then
                return true
            end
        end
    end
    return false
end

--- 云鸢柳 
__red_point[311] = function()
    local red_flag = false
    local literature_task_once = RedPointUtil:localRedPointJudge("literature_task_once")
    red_flag = literature_task_once
    return red_flag
end

--- 翠柳轩 
__red_point[310] = function()
    local red_flag = false
    local literature_shop_once = RedPointUtil:localRedPointJudge("literature_shop_once")
    red_flag = literature_shop_once
    return red_flag
end

--- 文趣榜
__red_point[309] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(309)
    if not activeData then
        return false
    end
    
    local red_flag = false
    local common_war_order = UserDataManager:getRedDotByKey("common_war_order")
    if type(common_war_order) ~= "number" then
        for _, itemData in pairs(common_war_order) do
            if itemData[1] == 309 and itemData[2] == activeData.version then
                return true
            end
        end
    end
    local enjoy_spring_wenqu = UserDataManager:getRedDotByKey("enjoy_spring_wenqu")
    local literature_rank_task_once = RedPointUtil:localRedPointJudge("literature_rank_task_once")
    red_flag = enjoy_spring_wenqu == 1
    red_flag = red_flag or literature_rank_task_once
    return red_flag
end

--- 赏春阁 签到
__red_point[308] = function()
    local red_flag = RedPointUtil:localRedPointJudge("literature_signIn_once")
    if not red_flag then
        local gu_jian_draw = UserDataManager:getRedDotByKey("common_login")
        if gu_jian_draw and gu_jian_draw == 0 then
            return false
        end
        if type(gu_jian_draw) ~= "number" then
            for _, itemData in pairs(gu_jian_draw) do
                if itemData[1] == 308 and itemData[2] == 1 then
                    return true
                end
            end
        end
    end
    return red_flag 
end

--美团活动
__red_point[321] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(321)
    if not active_data or active_data.open_status ~= 1 then
        return false
    end
    if UserDataManager:getRedDotByKey("meituan") > 0 then
        return true
    else
        return RedPointUtil:getCommonGiftRedByOpenId(324, true)
    end
end
--
__red_point[336] = function()
    local red_flag = false
    local season = UserDataManager:getCurSeason()
    local flag = UserDataManager.local_data:getUserDataByKey("red_point_336_"..season, 1)
    red_flag = flag == 1
    return red_flag
end

-- 秘籍镶嵌
__red_point[337] = function()
    local red_flag = M:localRedPointJudge("sutra_depository")
    return red_flag
end


--半周年 商店
__red_point[329] = function()
    local red_flag = RedPointUtil:getCommonGiftRedByOpenId(329, true)
    return red_flag
end

--半周年 庆典装扮
__red_point[328] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(328)
    if not active_data or active_data.open_status ~= 1 then
        return false
    end
    return UserDataManager:getRedDotByKey("half_year_quest") > 0
end

--半周年 世界boss
__red_point[327] = function()
   local red_flag = RedPointUtil:getActiveBossRedByOpenId(327) 
    return red_flag
end

--半周年 蓬莱集市
__red_point[333] = function()
    local red_flag = false
    return red_flag
end

--半周年 彩票
__red_point[331] = function()
    local red_flag = false
    local lottery_tiket = UserDataManager:getRedDotByKey("lottery_tiket")
    red_flag = lottery_tiket == 1
    return red_flag
end

--半周年 秘境
__red_point[330] = function()
    local red_flag = false
    local monster = UserDataManager:getRedDotByKey("monster")
    red_flag = monster == 1
    return red_flag 
end

--半周年 签到
__red_point[334] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(334)
    if not active_data or active_data.open_status ~= 1 then
        return false
    end
    local red_flag = RedPointUtil:localRedPointJudge("half_year_signIn_once")
    if not red_flag then
        local data = UserDataManager:getRedDotByKey("common_login")
        if data and data ~= 0 then
            if type(data) ~= "number" then
                for _, itemData in pairs(data) do
                    if itemData[1] == 334 and itemData[2] == 1 then
                        red_flag = true
                    end
                end
            end
        end
    end
    return red_flag
end

--小浣熊
__red_point[339] = function()
    local raccon_chapter = UserDataManager:getRedDotByKey("raccon_chapter")
    local red_flag = raccon_chapter == 1
    return red_flag
end

--小浣熊麒麟现世
__red_point[340] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(340)
    if not active_data or active_data.open_status ~= 1 then
        return false
    end
    local cur_vsn = active_data.version
    local common_quest = UserDataManager:getRedDotByKey("common_quest")
    if common_quest and type(common_quest) == "table" then
        for i, v in pairs(common_quest) do
            if v[1] == 340 and v[2] == cur_vsn then
                return true
            end
        end
    end
    --local red_flag = RedPointUtil:getRedPointByCommonquestData(340, "lianliankan_quest")
    return false
end

__red_point[341] = function()
    local red_flag = RedPointUtil:localRedPointJudge("raccon_xkz_daily_once")
    local raccon_chapter = UserDataManager:getRedDotByKey("raccon_chapter")
    red_flag = red_flag or raccon_chapter == 1
    return red_flag
end

--小浣熊摇摇乐
__red_point[343] = function()
    local red_flag = false
    local active_data = UserDataManager:getActivesDataByOpenId(339	)
    if active_data == nil then
        return false
    end
    local start_ts = active_data.start_ts or 0
    local diff_time = start_ts - UserDataManager:getServerTime() + 2
    if diff_time > 0 then
        return false
    end

    if not red_flag then
        local reward_data = RewardUtil:getProcessRewardData({103,5445,1})
        if reward_data.user_num >= 1 then
            return true
        end
    end
    return red_flag
end

--集卡册
__red_point[344] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(339)
    if active_data == nil then
        return false
    end
    local cur_vsn = active_data.version
    local common_quest = UserDataManager:getRedDotByKey("common_quest")
    if common_quest and type(common_quest) == "table" then
        for i, v in pairs(common_quest) do
            if v[1] == 344 and v[2] == cur_vsn then
                return true
            end
        end
    end
    --local red_flag = RedPointUtil:getRedPointByCommonquestData(344, "lianliankan_quest")

    local raccon_card = ConfigManager:getCfgByName("raccon_card") or {}
    local cur_card_cfg = raccon_card[344] or {}
    local cur_vsn_card_cfg = cur_card_cfg[active_data.version] or {}
    local cost = cur_vsn_card_cfg.cost or {}
    local not_full = false
    for i, v in pairs(cost) do
        local reward = RewardUtil:getProcessRewardData(v)
        if reward.data_num > reward.user_num then
            not_full = true
            break
        end
    end
    local red_flag = not(not_full)
    return red_flag
end

--小浣熊麒麟每日礼包
__red_point[345] = function()
    local red_flag = RedPointUtil:getCommonGiftRedByOpenId(345, true)
    return red_flag
end

--小浣熊花落谁家
__red_point[346] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(346)
    if active_data == nil then
        return false
    end
    local cur_vsn = active_data.version
    local red_flag = false
    local common_lottery = UserDataManager:getRedDotByKey("common_lottery")
    if common_lottery and type(common_lottery) == "table" then
        for i, v in pairs(common_lottery) do
            local id = v[1] or 0
            local value = v[2] or 0
            if id == 346 and value == cur_vsn then
                red_flag = true
            end
        end
    end
    return red_flag
end


--通关好礼
__red_point[347] = function()
    local red_flag = RedPointUtil:getRedPointByCommonquestData(347, "lianliankan_quest")
    return red_flag
end

--小浣熊麒麟热力礼包
__red_point[348] = function()
    local red_flag = RedPointUtil:getCommonGiftRedByOpenId(348, true)
    return red_flag
end

-- 蓬莱集市入口红点
__red_point[349] = function()
    local red_flag = UserDataManager:getRedDotByKey("bazaar") == 1
    return red_flag
end

-- 宠物入口红点
__red_point[351] = function()
    local bazaarRed = RedPointUtil:hasRedPointById(349, nil)
    local petEntryRed = RedPointUtil:petEntryHasRedPoint()
    local res = bazaarRed or petEntryRed
    return res
end

-- 奇兽斋入口红点
function M:petEntryHasRedPoint()
    local res = false
    local isMaxReward = UserDataManager:getRedDotByKey("pet_factory") == 1
    local isBestTeam = UserDataManager:getRedDotByKey("pet_factory_best_team") ==1
    local petFactoryRedPoint = isMaxReward or isBestTeam
    local petBagRedPoint = self:checkPetBagRedPoint()
    local petEvoRedPoint = self:checkPetEvoRedPoint()
    local petArenaRedPoint = UserDataManager:getRedDotByKey("pet_pvp") > 0
    res = petFactoryRedPoint or petBagRedPoint or petEvoRedPoint or petArenaRedPoint
    return res
end

function M:checkPetBagRedPoint()
    local ids = table.copy(UserDataManager.pet_data:getPetsId())
    local data
    for k, v in ipairs(ids) do
        data = UserDataManager.pet_data:getPetDataById(v)
        if data and data.egg_ets then
            local cur_time = UserDataManager:getServerTime()
            if cur_time >= data.egg_ets then
                return true
            end
        end
    end
    return false
end

function M:checkPetEvoRedPoint()
    --local ids = table.copy(UserDataManager.pet_data:getPetsId())
    --local evoCfg = ConfigManager:getCfgByName("pet_evolution")
    --local typeList = {}
    --local cfg
    --for k, v in ipairs(ids) do
    --    local data
    --    data,cfg = UserDataManager.pet_data:getPetDataById(v)
    --    if typeList[cfg.pet_type] then
    --        table.insert(typeList[cfg.pet_type], data)
    --    else
    --        typeList[cfg.pet_type] = {}
    --        table.insert(typeList[cfg.pet_type], data)
    --    end
    --end
    --for k, v in pairs(typeList) do
    --    for i = 1, #v - 1 do
    --        if v[i] and v[i].lv >= evoCfg[v[i].evo].min_condition and v[i].lv <= evoCfg[v[i].evo].min_condition and not v[i].egg_ets then
    --            for j = i + 1, #v do
    --                if v[j] and v[j].lv >= evoCfg[v[i].evo].min_condition and v[j].lv <= evoCfg[v[i].evo].min_condition and not v[j].egg_ets then
    --                    return true
    --                end
    --            end
    --        end
    --    end
    --   
    --end
    return false
end

--- 端午活动(入口)
__red_point[352] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(352)
    if activeData == nil then
        return false
    end
    local activity_info = UserDataManager:getActivesDataByOpenId(353)
    if activity_info then
        local server_time = UserDataManager:getServerTime()
        if server_time >= activity_info.start_ts and server_time < activity_info.show_start_ts then
            
        elseif server_time >= activity_info.show_start_ts then
            return false --展示期
        end
    end
    local curVersion = activeData.version
    local common_questData = UserDataManager:getRedDotByKey("common_quest")
    if type(common_questData) ~= "number" then
        for _, itemData in pairs(common_questData) do
            -- 356是里边的任务子活动
            if itemData[1] == 356 and itemData[2] == curVersion then
                return true
            end
        end
    end
    if UserDataManager:getRedDotByKey("meituan") > 0 then
        return true
    else
        return RedPointUtil:getCommonGiftRedByOpenId(354, true) 
    end
end

--- 端午活动 签到
__red_point[353] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(353)
    if activeData == nil then
        return false
    end
    local red_flag = RedPointUtil:localRedPointJudge("dragonBoat_signIn_once")
    if not red_flag then
        local gu_jian_draw = UserDataManager:getRedDotByKey("common_login")
        if gu_jian_draw and gu_jian_draw == 0 then
            return false
        end
        if type(gu_jian_draw) ~= "number" then
            for _, itemData in pairs(gu_jian_draw) do
                if itemData[1] == 353 and itemData[2] == 1 then
                    return true
                end
            end
        end
    end
    return red_flag
end

--端午活动 曲水流觞
__red_point[356] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(356)
    if activeData == nil then
        return false
    end
    local curVersion = activeData.version
    local common_questData = UserDataManager:getRedDotByKey("common_quest")
    if type(common_questData) ~= "number" then
        for _, itemData in pairs(common_questData) do
            -- 290是里边的任务子活动
            if itemData[1] == 356 and itemData[2] == curVersion then
                return true
            end
        end
    end
    return false
end
--充值返利
__red_point[358] = function()
    local common_quest = UserDataManager:getRedDotByKey("common_quest")
    if common_quest and type(common_quest) == "table" then
        for i, v in pairs(common_quest) do
            if v[1] == 358 and v[2] == 1 then
                return true
            end
        end
    end
    return false
end

--神秘商店
__red_point[363] = function()
    local red_data = UserDataManager:getRedDotByKey("mystery_shop_reward")
    if red_data  then
        return red_data == 1
    end
    return false
end

--守卫清凉
__red_point[368] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(368)
    if not activeData then
        return false
    end
    --任务
    local flag_ = UserDataManager:getRedDotByKey("common_world_boss_quest")
    if type(flag_) =="table" then
        for k,v in ipairs(flag_) do
            if v[1] == 368 and v[2] == activeData.version then
                return true
            end
        end
    end
    --次数
    local curVersion = activeData.version
    local common_world_boss = UserDataManager:getRedDotByKey("common_world_boss")

    if type(common_world_boss) ~= "number" then
        for _, itemData in pairs(common_world_boss) do
            if itemData[1] == 368 and itemData[2] == curVersion then
                return true
            end
        end
    end
    --战令
    local common_war_order = UserDataManager:getRedDotByKey("common_war_order")
    if type(common_war_order) == "table" then
        for _, itemData in pairs(common_war_order) do
            if itemData[1] == 368 and itemData[2] == activeData.version then
                return true
            end
        end
    end
    
    return false
end

--清凉消暑
__red_point[367] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(367)
    if not active_data or active_data.open_status ~= 1 then
        return false
    end
    local red_flag = RedPointUtil:localRedPointJudge("half_year_signIn_once")
    if not red_flag then
        local data = UserDataManager:getRedDotByKey("common_login")
        if data and data ~= 0 then
            if type(data) == "table" then
                for _, itemData in pairs(data) do
                    if itemData[1] == 367 and itemData[2] == active_data.version then
                        red_flag = true
                    end
                end
            end
        end
    end
    return red_flag
end


--夏日夺宝
__red_point[369] = function()
    local red_flag = false
    local monster = UserDataManager:getRedDotByKey("monster")
    red_flag = monster == 1
    return red_flag
end

--清凉小集
__red_point[370] = function()
    local red_flag = RedPointUtil:getCommonGiftRedByOpenId(370, true)
    return red_flag
end
--清凉夏日排行榜
__red_point[371] = function()
    local flag= false
    local activeData = UserDataManager:getActivesDataByOpenId(368)
    if not activeData then
        return false
    end
    local flag_ = UserDataManager:getRedDotByKey("common_world_boss_quest")
    if type(flag_) =="table" then
        for k,v in ipairs(flag_) do
            if v[1] == 368 and v[2] == activeData.version then
                return true
            end
        end
    end
    local common_war_order = UserDataManager:getRedDotByKey("common_war_order")
    if type(common_war_order) == "table" then
        for _, itemData in pairs(common_war_order) do
            if itemData[1] == 368 and itemData[2] == activeData.version then
                return true
            end
        end
    end
    return flag
end

--七夕佳节
__red_point[373] = function()
    local red_flag = false
    red_flag = __red_point[374]() or __red_point[375]() or __red_point[376]() or __red_point[377]() or __red_point[378]()
    return red_flag
end

---七夕佳节-佳偶天成
__red_point[374] = function()
    local active_data = UserDataManager:getActivesRechargeDataByOpenId(374)
    local red_flag = false
    local curVersion = 0
    if active_data then
        curVersion = active_data.version or 0
    end
    local common_war_order = UserDataManager:getRedDotByKey("common_war_order")
    if type(common_war_order) ~= "number" then
        for _, itemData in pairs(common_war_order) do
            if itemData[1] == 374 and itemData[2] == curVersion then
                red_flag = true
                break
            end
        end
    end
    return red_flag and active_data and active_data.open_status == 1
end

---七夕佳节-团购狂欢
__red_point[375] = function()
    local active_data = UserDataManager:getActivesRechargeDataByOpenId(375)
    local red_flag = M:localRedPointJudge("QiXiShoppingRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

---七夕佳节-明月献礼
__red_point[376] = function()
    local red_flag = false
    local valentine = UserDataManager:getRedDotByKey("valentine_festival_moon")
    red_flag = valentine == 1
    return red_flag
end

---七夕佳节-明月兑换
__red_point[377] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(377)
    local red_flag = M:localRedPointJudge("QiXiExchangeRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

---七夕佳节-鹊桥礼包
__red_point[378] = function()
    local active_data = UserDataManager:getActivesRechargeDataByOpenId(378)
    local curVersion = 0
    if active_data then
        curVersion = active_data.version or 0
    end
    local red_flag = false
    local common_giftList = UserDataManager:getRedDotByKey("common_gift")
    if type(common_giftList) ~= "number" then
        for _, itemData in pairs(common_giftList) do
            if itemData[1] == 378 and itemData[2] == curVersion then
                red_flag = true
                break
            end
        end
    end
    return red_flag and active_data and active_data.open_status == 1
end

--龙胆相助
__red_point[381] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(381)
    if not activeData then
        return false
    end
    local flag_ = UserDataManager:getRedDotByKey("common_quest")
    if type(flag_) =="table" then
        for k,v in ipairs(flag_) do
            if v[1] == 381 and v[2] == activeData.version then
                return true
            end
        end
    end
    return false
end


--三侠五义-入口
__red_point[385] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(385)
    if not activeData then
        return false
    end
    local red_flag = false
    local flag_ = UserDataManager:getRedDotByKey("chivalrous_recv")
    red_flag = flag_ == 1
    return red_flag
end

--- 三侠五义-猫鼠游戏
__red_point[387] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(387)
    local red_flag = M:localRedPointJudge("ThreeHeroesFiveGallantsWhackGame")
    return red_flag and active_data and active_data.open_status == 1
end

--- 三侠五义-江湖行侠
__red_point[388] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(388)
    local red_flag_battle = M:localRedPointJudge("ThreeHeroesFiveGallantsBattle") 
    local flag_ = UserDataManager:getRedDotByKey("chivalrous_recv_train")
    local red_flag = false
    red_flag = red_flag_battle or flag_ == 1
    return red_flag and active_data and active_data.open_status == 1
end

---三侠五义-侠义献礼
__red_point[389] = function()
    local active_data = UserDataManager:getActivesRechargeDataByOpenId(389)
    local curVersion = 0
    if active_data then
        curVersion = active_data.version or 0
    end
    local red_flag = false
    local common_giftList = UserDataManager:getRedDotByKey("common_gift")
    if type(common_giftList) ~= "number" then
        for _, itemData in pairs(common_giftList) do
            if itemData[1] == 389 and itemData[2] == curVersion then
                red_flag = true
                break
            end
        end
    end
    return red_flag and active_data and active_data.open_status == 1
end

--
__red_point[295] = function()
    --local flag_ = UserDataManager:getRedDotByKey("guild_high_war_team_dispatch")
    --if flag_ == 1 then
    --    return true
    --end
    local flag_2 = UserDataManager:getRedDotByKey("guild_high_war_team_empty")
    if flag_2 == 1 then
        return true
    end
    return false
end

-- 鸿运礼包 红点
__red_point[178] = function()
    local red_flag = RedPointUtil:localRedPointJudge("hong_yun_li_bao")
    return red_flag
end
-- 群英礼包 红点
__red_point[453] = function()
    local red_flag = RedPointUtil:localRedPointJudge("qun_ying_li_bao")
    return red_flag
end
-- 蓬莱按钮入口红点
__red_point[350] = function()
    local bazaarRed = RedPointUtil:hasRedPointById(349, nil)
    local petEntryRed = RedPointUtil:petEntryHasRedPoint()
    local isWei1 = RedPointUtil:hasRedPointById(383, nil)
    local isWei2 = PrestigeUtil:hasNewBlock()
    local awaken_red = UserDataManager:getRedDotByKey("awaken")
    local awaken_flag = awaken_red > 0 
    local res = bazaarRed or petEntryRed or isWei1 or isWei2 or awaken_flag
    return res
end

---限时侠客
__red_point[384] = function()
    local red_flag = false
    local limit_hero = UserDataManager:getRedDotByKey("limit_hero")
    red_flag = limit_hero == 1
    return red_flag
end


--天赐祈福
__red_point[400] = function()   
    local red_flag = false
    local activeData = UserDataManager:getActivesDataByOpenId(400)
    if not activeData then
        red_flag =  false
        return red_flag
    end
    local quest_flag = RedPointUtil:getCommonQuestRedPointByOpenId(400)
    local once_flag = RedPointUtil:localRedPointJudge("heaven_bless_reward_once") --点击一次即消失的红点
    local weekendSevent_flag = UserDataManager:getRedDotByKey("weekendsevent")
    red_flag = weekendSevent_flag == 1 or quest_flag or once_flag
    return red_flag
end

--天赐祈福
__red_point[401] = function()
    local red_flag = false
    local activeData = UserDataManager:getActivesDataByOpenId(401)
    if not activeData then
        red_flag =  false
        return red_flag
    end
    local common_questData = UserDataManager:getRedDotByKey("luckybag")
    if type(common_questData) ~= "number" then
        for _, itemData in pairs(common_questData) do
            -- 290是里边的任务子活动
            if itemData[1] == 401 and itemData[2] == activeData.version then
                red_flag =  true
            end
        end
    end
    return red_flag
end

__red_point[418] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(418)
    if not activeData then
        return false
    end
    local flag_ = UserDataManager:getRedDotByKey("common_quest")
    if type(flag_) =="table" then
        for k,v in ipairs(flag_) do
            if v[1] == 418 and v[2] == activeData.version then
                return true
            end
        end
    end
    return false
end

--通过openId获取任务列表红点是否显示
function M:getCommonQuestRedPointByOpenId(openId)
    local result = false
    local common_quest = UserDataManager:getRedDotByKey("common_quest")
    if common_quest  and type(common_quest) == "table" then
        for i, v in pairs(common_quest) do
            if v[1] == openId and v[2] == 1 then
                result = true
            end
        end
    end
    return result
end

--风云际会-斗转星移
__red_point[404] = function()
    local active_data = UserDataManager:getActivesRechargeDataByOpenId(404)
    local red_flag = false
    local curVersion = 0
    if active_data then
        curVersion = active_data.version or 0
    end
    local common_war_order = UserDataManager:getRedDotByKey("common_war_order")
    if type(common_war_order) ~= "number" then
        for _, itemData in pairs(common_war_order) do
            if itemData[1] == 404 and itemData[2] == curVersion then
                red_flag = true
                break
            end
        end
    end
    return red_flag and active_data and active_data.open_status == 1
end

--风云际会-壮志凌云
__red_point[405] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(405)
    local red_flag = false
    local curVersion = 0
    if active_data then
        curVersion = active_data.version or 0
    end
    local diamond_rebate = UserDataManager:getRedDotByKey("diamond_rebate")
    if type(diamond_rebate) ~= "number" then
        for _, itemData in pairs(diamond_rebate) do
            if itemData[1] == 405 and itemData[2] == curVersion then
                red_flag = true
                break
            end
        end
    end
    return red_flag and active_data and active_data.open_status == 1
end

--- 风云际会-九天揽月
__red_point[406] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(406)
    local red_flag = M:localRedPointJudge("WindAndCloudMoon")
    return red_flag and active_data and active_data.open_status == 1
end

--- 风云际会-名扬四海
__red_point[407] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(407)
    local red_flag = false
    local curVersion = 0
    if active_data then
        curVersion = active_data.version or 0
    end
    local one_red = M:localRedPointJudge("WindAndCloudRedEnvelope")
    return  one_red
end

--- 活动世界boss
function M:getActiveBossRedByOpenId(open_id)
    local activeData = UserDataManager:getActivesDataByOpenId(open_id)
    if not activeData then
        return false
    end

    local curVersion = activeData.version
    local common_world_boss = UserDataManager:getRedDotByKey("common_world_boss")
    
    if type(common_world_boss) ~= "number" then
        for _, itemData in pairs(common_world_boss) do
            if itemData[1] == open_id and itemData[2] == curVersion then
                return true
            end
        end
    end

    local common_world_boss_like = UserDataManager:getRedDotByKey("common_world_boss_like")
    if type(common_world_boss_like) ~= "number" then
        for _, itemData in pairs(common_world_boss_like) do
            if itemData[1] == open_id and itemData[2] == curVersion then
                return true
            end
        end
    end

    local common_world_boss_reward = UserDataManager:getRedDotByKey("common_world_boss_reward")
    if type(common_world_boss_reward) ~= "number" then
        for _, itemData in pairs(common_world_boss_reward) do
            if itemData[1] == open_id and itemData[2] == curVersion then
                return true
            end
        end
    end
    return false
end

--侠客行-长歌行
__red_point[394] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(394)
    local red_flag = false
    local curVersion = 0
    if active_data then
        curVersion = active_data.version or 0
    end
    local common_war_order = UserDataManager:getRedDotByKey("common_war_order")
    if type(common_war_order) ~= "number" then
        for _, itemData in pairs(common_war_order) do
            if itemData[1] == 394 and itemData[2] == curVersion then
                red_flag = true
                break
            end
        end
    end
    return red_flag and active_data and active_data.open_status == 1
end

--侠客行-谪仙试炼
__red_point[395] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(395)
    if activeData then
        local common_train_challenge_data = UserDataManager:getRedDotByKey("common_train_challenge")
        if type(common_train_challenge_data) == "table" then
            for k, v in pairs(common_train_challenge_data) do
                if v[1] and v[1] == 395 and v[2] and v[2] == activeData.version then
                    return true
                end
            end
        end
    end
    return false
end

--侠客行-诗书绘卷-兑换商店
__red_point[396] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(396)
    local red_flag = M:localRedPointJudge("ChivalryFillExchangeShopRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

--侠客行-黄金屋
__red_point[397] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(397)
    local red_flag = M:localRedPointJudge("ChivalryCommonGiftTwoRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

--侠客行-翰林书院
__red_point[398] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(398)
    if not activeData then
        return false
    end
    local flag = UserDataManager:getRedDotByKey("fillword")
    return flag == 1
end

--幸运夺宝
__red_point[427] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(427)
    local red_flag = M:localRedPointJudge("LuckyDogRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

--国色天香-红袖天香
__red_point[409] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(409)
    local red_flag = false
    local curVersion = 0
    if active_data then
        curVersion = active_data.version or 0
    end
    local common_war_order = UserDataManager:getRedDotByKey("common_war_order")
    if type(common_war_order) ~= "number" then
        for _, itemData in pairs(common_war_order) do
            if itemData[1] == 409 and itemData[2] == curVersion then
                red_flag = true
                break
            end
        end
    end
    return red_flag and active_data and active_data.open_status == 1
end
--国色天香-巾帼红颜
__red_point[410] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(410)
    if activeData then
        local common_train_challenge_data = UserDataManager:getRedDotByKey("common_raccon_chapter")
        if type(common_train_challenge_data) == "table" then
            for k, v in pairs(common_train_challenge_data) do
                if v[1] and v[1] == 410 and v[2] and v[2] == activeData.version then
                    return true
                end
            end
        end
    end
    return false
end

--国色天香-郿坞试炼
__red_point[411] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(411)
    if activeData then
        local common_train_challenge_data = UserDataManager:getRedDotByKey("common_train_challenge")
        if type(common_train_challenge_data) == "table" then
            for k, v in pairs(common_train_challenge_data) do
                if v[1] and v[1] == 411 and v[2] and v[2] == activeData.version then
                    return true
                end
            end
        end
    end
    return false
end

--国色天香-天香群英榜
__red_point[412] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(412)
    local item_red = 0
    local favor = 0
    if activeData then
        local item_data = UserDataManager.item_data:getItemDataById("5602")
        if item_data.num > 0 and activeData.open_status == 1 then
            item_red = 1
        end
        local common_favor = UserDataManager:getRedDotByKey("common_favor")
        if type(common_favor) == "table" then
            for k, v in pairs(common_favor) do
                if v[1] and v[1] == 412 and v[2] and v[2] == activeData.version then
                    favor = 1
                end
            end
        end
    end
    return item_red == 1 or favor == 1
end

--国色天香-天香献礼
__red_point[413] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(413)
    local red_flag = M:localRedPointJudge("ChivalryCommonGiftTwoRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

--周年庆-风起神都
__red_point[420] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(420)
    if activeData then
        local common_train_challenge_data = UserDataManager:getRedDotByKey("common_raccon_chapter")
        if type(common_train_challenge_data) == "table" then
            for k, v in pairs(common_train_challenge_data) do
                if v[1] and v[1] == 420 and v[2] and v[2] == activeData.version then
                    return true
                end
            end
        end
    end
    return false
end

--周年庆-神都战令
__red_point[421] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(421)
    local red_flag = false
    local curVersion = 0
    if active_data then
        curVersion = active_data.version or 0
    end
    local common_war_order = UserDataManager:getRedDotByKey("common_war_order")
    if type(common_war_order) ~= "number" then
        for _, itemData in pairs(common_war_order) do
            if itemData[1] == 421 and itemData[2] == curVersion then
                red_flag = true
                break
            end
        end
    end
    return red_flag and active_data and active_data.open_status == 1
end

--周年庆-神都机关令
__red_point[422] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(422)
    if activeData then
        local common_train_challenge_data = UserDataManager:getRedDotByKey("common_train_challenge")
        if type(common_train_challenge_data) == "table" then
            for k, v in pairs(common_train_challenge_data) do
                if v[1] and v[1] == 422 and v[2] and v[2] == activeData.version then
                    return true
                end
            end
        end
    end
    return false
end

--周年庆-庆典集市
__red_point[424] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(424)
    local red_flag = M:localRedPointJudge("ChivalryCommonGiftTwoRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

--周年庆-神都群英榜
__red_point[426] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(426)
    local item_red = 0
    local favor = 0
    if activeData then
        local favor_event = ConfigManager:getCfgByName("favor_event") or {}
        local item_id = "5653"
        if favor_event and favor_event[426] and favor_event[426][activeData.version] then
            item_id = favor_event[426][activeData.version].favor_item
        end
        local item_data = UserDataManager.item_data:getItemDataById(item_id)
        if item_data.num > 0 and activeData.open_status == 1 then
            item_red = 1
        end
        local common_favor = UserDataManager:getRedDotByKey("common_favor")
        if type(common_favor) == "table" then
            for k, v in pairs(common_favor) do
                if v[1] and v[1] == 426 and v[2] and v[2] == activeData.version then
                    favor = 1
                end
            end
        end
    end
    return item_red == 1 or favor == 1
end

--瑞兔小斋
__red_point[433] = function()
    local rp_flag = false
    local active_data = UserDataManager:getActivesDataByOpenId(433)
    local cur_ts = UserDataManager:getServerTime()
    local is_show_date = false --展示期 ：不显示任何红点
    if active_data and not active_data["end"] then
        is_show_date = cur_ts > active_data.show_start_ts and cur_ts < active_data.end_ts
    end
    if is_show_date then
        return false
    end
    
    rp_flag = UserDataManager:getRedDotByKey("rabbit") == 1
    local red_flag = RedPointUtil:localRedPointJudge("luckyRabbit_gift")
    return rp_flag or red_flag
end
--江湖大富翁
__red_point[440] = function()
    local active_data = UserDataManager:getActivesRechargeDataByOpenId(440)
    local millionaire_red_flag = M:localRedPointJudge("MillionaireRedDot")
    return millionaire_red_flag and active_data and active_data.open_status == 1
end

--忠义无双-武圣试炼
__red_point[438] = function()
    local activeData = UserDataManager:getActivesDataByOpenId(438)
    if activeData then
        local common_train_challenge_data = UserDataManager:getRedDotByKey("common_train_challenge")
        if type(common_train_challenge_data) == "table" then
            for k, v in pairs(common_train_challenge_data) do
                if v[1] and v[1] == 438 and v[2] and v[2] == activeData.version then
                    return true
                end
            end
        end
    end
    return false
end

--忠义无双-武圣集市
__red_point[439] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(439)
    local red_flag = M:localRedPointJudge("ChivalryCommonGiftTwoRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

--- 忠义无双-福星高照
__red_point[437] = function()
    local active_data = UserDataManager:getActivesDataByOpenId(437)
    local red_flag = M:localRedPointJudge("HaveGoodLuckRedDot")
    return red_flag and active_data and active_data.open_status == 1
end

---侠客岛
__red_point[450]=function()
    local red_flag = UserDataManager:getRedDotByKey("hero_isle")

    local season=UserDataManager.m_season_data.season
    local hero_isle_visitor_cfg=ConfigManager:getCfgByName("hero_isle_visitor")
    local hero_isle_visitor_cfg_item=hero_isle_visitor_cfg[season]
    if hero_isle_visitor_cfg_item==nil then
        hero_isle_visitor_cfg_item=hero_isle_visitor_cfg[-1]
    end
    local quest_type=hero_isle_visitor_cfg_item.target_type
    if quest_type then
        local quest_data = UserDataManager:getChapterQuestSpecialData(quest_type)
        for i, v in pairs(quest_data) do
            ---存在未领取的
            if v.status==2 then
                return true
            end
        end
    end

    return red_flag == 1
end


--争锋联赛入口红点
__red_point[472] = function()
    local red_flag = false
    local race_arena = UserDataManager:getRedDotByKey("rise_arena_like") --前三名点赞
    local race_arena_reward = UserDataManager:getRedDotByKey("rise_arena_award") --奖励
    local can_advance = UserDataManager:getRedDotByKey("rise_arena_promote") --是否可晋升
    if race_arena_reward == 1 or race_arena == 1 or can_advance == 1 then
        return true
    end
    return red_flag
end

--争锋联赛点赞
__red_point[47201] = function()
    local red_flag = false
    local race_arena = UserDataManager:getRedDotByKey("rise_arena_like")
    red_flag = race_arena == 1
    return red_flag
end

-- 酒楼
__red_point[473] = function()
    local game_click = UserDataManager:getRedDotByKey("game_street_click") --小游戏当日是否点过[1, 3, 4]
    if type(game_click) == "table" then
        return true
    end
    local daily_reward = UserDataManager:getRedDotByKey("hotel_daily_award") --酒楼日常奖励
    if daily_reward and daily_reward == 1 then
        return true
    end
    local fate_gate_pass = UserDataManager:getRedDotByKey("hotel_clear_award") --酒楼通关奖励
    if fate_gate_pass and fate_gate_pass == 1 then
        return true
    end
    local fate_challenge_num = UserDataManager:getRedDotByKey("hotel_dare_num") --酒楼有挑战次数
    if fate_challenge_num and fate_challenge_num == 1 then
        return true
    end
    local game_mile = UserDataManager:getRedDotByKey("game_street_mile") --小游戏里程碑奖励[1, 3, 4]
    if type(game_mile) == "table" then
        return true
    end
    local gacha_times = UserDataManager:getRedDotByKey("hotel_gacha_num") --酒楼抽卡次数>5
    if type(gacha_times) == "table" then
        return true
    end
    return false
end

--天府夺刀
__red_point[475] = function()
    local red_flag = false
    local status = UserDataManager:getRedDotByKey("hero_boss")
    red_flag = status == 1
    return red_flag
end

--宝物
__red_point[479] = function()
    local red_flag = UserDataManager.jewel_data:checkAllRedPoint()
    return red_flag
end

--- 是否有小红点
function M:hasRedPointById(red_point_id, param, open_id)
    local func = __red_point[red_point_id or -1]
    if func then
        return func(param, open_id)
    end
    return false
end

-- 铸件大会，通过渠道判断是否显示直播按钮
function M:isShowCastingSwordSinatvRedDot(openId)
    local applicationId = SDKUtil.sdk_params.applicationId
    local sinatvChannelData = ConfigManager:getCfgByName("channel_id")
    local isShowSinatvBtn = false
    for channel, itemData in pairs(sinatvChannelData) do
        -- channel策划填的是包名，没改名字
        if channel == applicationId then
            if openId == 207 then
                isShowSinatvBtn = (itemData.status1 == 1) and (itemData.jump1 == 1)
            elseif  openId == 208 then
                isShowSinatvBtn = (itemData.status == 1) and (itemData.jump == 1)
            end
            break
        end
    end
    return isShowSinatvBtn
end

--- 是否有小红点
function M:isFuncRedPointById(button_id, ver)
    local cfg = BtnOpenUtil:getBtnCfg(button_id)
    if cfg == nil then
        return
    end
    local buttons = cfg.buttons or {}
    local open_flag = BtnOpenUtil:isBtnOpen(button_id, cfg)
    if open_flag then
        if #buttons > 0 then
            for i, v in ipairs(buttons) do
                if button_id ~= v then
                    if self:isFuncRedPointById(v, ver) then
                        return true
                    end
                else
                    Logger.logError("open_condition cfg error, key is " .. tostring(button_id))
                end
            end
        end
        return self:hasRedPointById(cfg.red_point, ver, cfg.open_id)
    else
        return false
    end
end

function M:localRedPointJudge(key)
    if key == nil then
        return false
    end
    local fresh_time = UserDataManager.local_data:getUserDataByKey(key, 0)
    local server_time = UserDataManager:getServerTime()
    if server_time >= fresh_time then
        return true
    end
    return false
end

function M:saveLocalRedPointFreshTime(key)
    if key == nil then
        return
    end
    local fresh_time = UserDataManager.local_data:getUserDataByKey(key, 0)
    local server_time = UserDataManager:getServerTime()
    if server_time >= fresh_time then
        local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
        UserDataManager.local_data:setUserDataByKey(key, next_fresh_time + 24 * 3600)
    end
end

function M:getRedPointByCommonquestData(open_id, quest_cfg_name)
    local red_flag = false
    local active = UserDataManager:getActivesDataByOpenId(open_id)
    if active and active.version then
        local quest_cfg = ConfigManager:getCfgByName(quest_cfg_name) or {}
        local cur_task_cfg = quest_cfg[open_id] or {}
        local cur_vsn_cfg = cur_task_cfg[active.version] or {}
        local task_id = 0
        for i, v in pairs(cur_vsn_cfg) do
            task_id = i
            if task_id > 0 then
                local common_quest_data = UserDataManager.m_common_quest[tostring(open_id)] or {}
                local cur_vsn = common_quest_data[tostring(active.version)] or {}
                for i, v in pairs(cur_vsn) do
                    if tostring(task_id) == i then
                        if v.status == 1 then
                            return true
                        end
                    end
                end
            end
        end

    end
    return red_flag
end
return M
