local M = class("GiftBagModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("welfare_enter")
end

function M:onEnter()
    self.m_draw_data = {}
    self.m_seven_tour_data = {}
    self.m_treasure_data = {}
    self.m_exchange_data = {}
    self.m_month_exchange_data = {}
    self.m_month_card_data = {}
    self.m_rechargeAndRebate_data = {}
    self.m_tiktok_data = {}
    self.m_kongMingLight_Data = {}
    self.m_rechargeRebata_Data = {}
    self.m_heavenBless_data = {}    --天赐祈福
    --------------------------------------------------------------------
    self.is_refresh_bl = false --检查是否在刷新请求中
    self.actives = self.m_params.actives
    self.m_sel_tab_index = 1 --默认开启
    self.mode = self.m_params.mode
    self.tag_table = self:getTagTabs(23)
    self:refreshDataTime()
    self:dayCompute()
end

--刷新接口请求
function M:refreshData(call_back)
    local function callFunc(data)
        if data then
            table.merge(self.m_data,data)
            local select_open_id = 0
            local last_index = self.m_sel_tab_index or 1
            if self.tag_table[self.m_sel_tab_index] then
                select_open_id = self.tag_table[self.m_sel_tab_index].id
            end
            self.tag_table = self:getTagTabs(23)
            local active_have = false --活动是否还存在
            for k, v in pairs(self.tag_table) do
                if v.id and v.id == select_open_id then
                    active_have = true
                    self.m_sel_tab_index = k
                end
            end
            if active_have == false then
                self.m_sel_tab_index = last_index > #self.tag_table and 1 or last_index
            end
            self:refreshDataTime()
            self:dayCompute()
            call_back()
        end
    end
    self:getNetData("welfare_enter",nil,callFunc,nil,true)
end

--记录一个最近的需要刷新的时间
function M:refreshDataTime()
    self.m_refresh_time = 0
    if self.m_refresh_time == 0 then
        local server_time = UserDataManager:getServerTime()
        local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
        self.m_refresh_time = next_fresh_time + 24 * 3600
    end
end


--检查刷新单个页签的数据
function M:refreshTabData(open_id, url_name)
    if open_id == nil or url_name == nil then
        return
    end
    --local active_tab = ConfigManager:getCfgByName("active")
    for k,v in pairs(self.m_data.actives) do
        local bl = false
        for kk,vv in pairs(v.actives) do
            if vv and vv.open_status > 0 and vv.open_id == open_id then
                bl = true
            end
        end
        if bl == true then
            if url_name == "hero_rank_index" then
                self:setOpenServerRankData(v)
            elseif url_name == "draw_index" then
                --卦签
                self.m_draw_data = v
            elseif url_name == "seven_tour" then
                --七日
                self.m_seven_tour_data = v
            elseif url_name == "treasure_index" then
                --侠影绘卷
                self.m_treasure_data = v or {} 
            elseif url_name == "exchange_index" then
                --限时兑换
                self.m_exchange_data = v or {} 
            elseif url_name == "hero_gather_received" then
                --绿林集结
                self.hero_gather_received = v.hero_gather_received or {} --绿林
            elseif url_name == "hero_gather_active_received" then
                --侠客集结
                self.hero_gather_active_received = v.hero_gather_active or {} --侠客
            elseif url_name == "month_exchange_index" then
                --满月兑换
                self.m_month_exchange_data = v or {} 
            elseif url_name == "eat_exchange_index" then
                --神飨兑换
                self.m_eat_exchange_data = v or {} 
            elseif url_name == "month_card" then
                --月卡
                self.m_month_card_data =v
            elseif url_name == "bowl_index" then
                --聚宝盆
                self.m_rechargeAndRebate_data = v or {}
            elseif url_name == "tiktok_data" then
                if v and v.tiktok_record then
                    self.m_tiktok_data = v.tiktok_record
                else
                    self.m_tiktok_data = {}
                end
            elseif url_name == "card_exchange_index" then
                --英雄兑换
                self.m_hero_exchange_data = v or {}               
            elseif url_name == "wish_index" then
                ---- 鸿运祈福入口
                self.m_kongMingLight_Data = v or {}
            elseif url_name == "recharge_rebate" then
                ---- 充值返利口
                self.m_rechargeRebata_Data = v or {}
            elseif url_name == "weekend_sevent_index" then
                --天赐祈福
                self.m_heavenBless_data = v or {}
            end
        end
    end
end

function M:initData2(url, call_back)
    self:getNetData(url, nil, call_back, nil, true)
end

function M:refreshActiveEnd()
    self.tag_table = self:getTagTabs(23)
    self:dayCompute()
    if self.m_sel_tab_index > 1 then
        self.m_sel_tab_index = self.m_sel_tab_index - 1
    end
end

function M:removeCurActives()
    local active_tab = ConfigManager:getCfgByName("active")
    local data = self.tag_table[self.m_sel_tab_index]
    for k, v in pairs(UserDataManager.m_actives) do
        if v.open_status > 0 and v.id == data.id then
            v.open_status = -1
            break
        end
    end
end

--七日前端跨期、 前端移出 --根据version
function M:replaceActives(version)
    local active_tab = ConfigManager:getCfgByName("active")
    for k, v in pairs(UserDataManager.m_actives) do
        if v.open_status > 0 and active_tab[v.id] and 
            active_tab[v.id].version == version and 
            active_tab[v.id].open_id == 72 then
            table.remove(UserDataManager.m_actives, k)
            return
        end
    end
end

function M:dayCompute()
    local reg_ts = UserDataManager.reg_ts
    local server_ts = UserDataManager:getServerTime()
    local ms = server_ts - reg_ts
    local day = GameUtil:NumberOfDaysInterval(server_ts, reg_ts, 0)
    self.m_day = day + 1
end

function M:getActiveByOpenId(open_id)
    local active_tab = ConfigManager:getCfgByName("active")
    for k,v in pairs(self.m_data.actives) do
        local bl = false
        for kk,vv in pairs(v.actives) do
            if vv and vv.open_status > 0 and vv.open_id == open_id then
                local c_cfg = active_tab[vv.id]
                return c_cfg
            end
        end
    end
    return nil
end

function M:getIndexBySevenDay(id)
    if self.m_seven_tour_data == nil then
        return 1
    end
    local active_tab = ConfigManager:getCfgByName("active")
    local active_cfg = active_tab[id]
    local seven_tour = self.m_seven_tour_data.seven_tour[tostring(active_cfg.version)]
    if seven_tour then
        local day = GameUtil:NumberOfDaysInterval(UserDataManager:getServerTime(), seven_tour.stime, 0)
        day = day + 1
        return day
    else
        return self.m_day
    end
    return 1
end

function M:getSevenDayVersion(id)
    local active_tab = ConfigManager:getCfgByName("active")
    if id then
        local active_cfg = active_tab[id]
        return active_cfg.version
    else
        for k,v in pairs(self.m_data.actives) do
            local bl = false
            for kk,vv in pairs(v.actives) do
                if vv and vv.open_status > 0 and vv.remain_ts > 0 then
                    local active_cfg = active_tab[v.id]
                    return active_cfg.version
                end
            end
        end
    end
    return 1
end

function M:getActivityEndTime(id)
    for k,v in pairs(self.m_data.actives) do
        local bl = false
        for kk,vv in pairs(v.actives) do
            if vv and vv.id == id then
                return vv.end_ts
            end
        end
    end
    return 0
end

function M:getSevenDayEndTime(id)
    
    local active_tab = ConfigManager:getCfgByName("active")
    local active_cfg = active_tab[id]
    if active_cfg.version == 1 then
        return 0
    else
        for k, v in pairs(self.m_data.actives) do
            for kk,vv in pairs(v.actives) do
                if vv.id == id then
                    return v.end_ts
                end
            end
        end
    end
    return 1
end

--根据id获取活动结束时间
function M:getActiveEndTimeByOpenId(open_id)
    --local active_tab = ConfigManager:getCfgByName("active")
    for k, v in pairs(self.m_data.actives) do
        for kk,vv in pairs(v.actives) do
            if vv.open_id == open_id then
                return vv.end_ts
            end
        end
    end
    return 0
end


--检查界面开启的活动按钮
function M:getShowActive()
    local opne_tab = ConfigManager:getCfgByName("open_condition")
    local active_tab = opne_tab[23]
    local temp_tab = table.copy(active_tab.buttons)
    local remove_tab = {}
    for i, v in pairs(temp_tab) do
        if self:checkHaveActive(v) == false then
            remove_tab[i] = true
        end
    end
    for i = #temp_tab, 1, -1 do
        if remove_tab[i] == true then
            table.remove(temp_tab, i)
        end
    end
    return temp_tab
end

function M:getTagTabs(open_id)
    local opne_tab = ConfigManager:getCfgByName("open_condition")
    local active_tab = opne_tab[open_id]
    local temp_tab = table.copy(active_tab.buttons)
    local remove_tab = {}
    --剔除未开启的
    if #temp_tab > 0 then
        for i, v in pairs(temp_tab) do
            if self:checkHaveActive(v) == false then
                remove_tab[i] = true
            end
        end
        for i = #temp_tab, 1, -1 do
            if remove_tab[i] == true then
                table.remove(temp_tab, i)
            end
        end
        
    end
    --检查多个
    local new_tab = {}
    for i = 1, #temp_tab do
        new_tab[i] = {open_id = temp_tab[i]}
    end
    for k, v in pairs(temp_tab) do
        local actives = self:checkHaveMoreActive(v)
        if #actives > 1 then
            for i = 2, #actives do
                table.insert(new_tab, k, {open_id = v})
            end
            for kk, vv in pairs(actives) do
                for k1, v1 in pairs(new_tab) do
                    if v == v1.open_id and v1.id == nil then
                        v1.id = vv
                        break
                    end
                end
            end
        elseif #actives == 1 then
            for kk, vv in pairs(actives) do
                for k1, v1 in pairs(new_tab) do
                    if v == v1.open_id and v1.id == nil then
                        v1.id = vv
                        break
                    end
                end
            end
        end
    end
    return new_tab
end

function M:getTagCfg(ID)
    for _, item in pairs(self.tag_table or {}) do
        if item.id == ID then
            return item
        end
    end
    return {}
end

-- 侠客争锋开服活动，最强战力榜数据
function M:setHeroBattleOpenServerAllRankData(data, rankType)
    -- 排行榜类型 5战力
    self.m_openServerAllRank_data = self:trimRankData(data,rankType)
end

-- 侠客争锋开服活动，最高进度榜数据
function M:setHeroBattleOpenServerAllProgressData(data, rankType)
    -- 排行榜类型 1关卡
    self.m_openServerAllProgress_data = self:trimRankData(data,rankType)
end

-- 赛季冲榜活动，天下演武榜
--function M:setWorldRehearsalRankData(data, rankType)
--    self.m_worldRehearsalRank_data = nil
--    if data == nil or (table.nums(data) <= 0) then
--        return
--    end
--    -- 排行榜类型 7 天下演武
--    self.m_worldRehearsalRank_data = self:trimRankData(data,rankType)
--end

-- 赛季冲榜活动，通用排行榜
function M:setGeneralRankData(data, rankType)
    self.m_generalRank_data = nil
    if data == nil or table.nums(data) <= 0 then
        return
    end
    -- 排行榜类型 8 秘籍积分
    self.m_generalRank_data = self:trimRankData(data,rankType)
end

--- 整理侠客争锋开服战力数据
function M:trimRankData(data, rankType)
    local rank_effectData = ConfigManager:getCfgByName("rank_effect")
    local versionRankAwardData = rank_effectData[self.m_hero_battle_version]
    local userData = UserDataManager.user_data:getOwnRankData({ rank = data.rank, score = data.score })
    rankType = (rankType <= 0) and 1 or rankType
    local awardInfoData = versionRankAwardData[rankType] or {}
    local awardId, awardData, curItemName = self:getAwardByRank(data.rank, awardInfoData)
    local tempData = {
        myRankData = {
            rank = data.rank,
            score = data.score,
            time = 0,
            user = userData.user,
            awardData = awardData,
            awardId = awardId,
            itemName = curItemName,
        },
        allRankData = {}
    }
    for _, itemData in pairs(data.ranks) do
        local itemAwardId, itemAwardData, itemAwardItemName = self:getAwardByRank(itemData.rank, awardInfoData)
        table.insert(tempData.allRankData, {
            rank = itemData.rank,
            score = itemData.score,
            time = itemData.time,
            user = itemData.user,
            awardData = itemAwardData,
            awardId = itemAwardId,
            itemName = itemAwardItemName,
        })
    end
    return tempData
end


function M:setGotTaskData(taskType, id)
    local data = self.m_hero_battle_data.hero_rank.quests[tostring(taskType)]
    if id > data.id then
        local tempId = data.id
        table.insert(data.done, tempId)
        data.id = id
    else
        table.insert(data.done, tempId)
    end
end

-- 个人积分,                  -- 1 演武，2 秘籍， 3 个人评分
function M:setMyDashRankScoreData(taskType)
    if not self.m_hero_battle_data then
        return 
    end
    -- 3是评分
    local myFightServerData = self.m_hero_battle_data.hero_rank.quests[tostring(taskType)]
    local rank_effectData = ConfigManager:getCfgByName("hero_effect")
    local versionRankAwardData = rank_effectData[self.m_hero_battle_version]
    local awardXlsxData = versionRankAwardData[taskType]
    local tempData = {}
    for id, itemData in pairs(awardXlsxData) do
        table.insert(tempData,{
            xlsxData = itemData,
            isCanGot = (myFightServerData.value >= (itemData.target_value)),
            isGot = self:isGotTask(id, myFightServerData),
            id = id,
            taskType = taskType,
        })
    end
    table.sort(tempData, function(itemData1, itemData2)
        local got1 = itemData1.isGot and 1 or -1
        local got2 = itemData2.isGot and 1 or -1
        if got1 ~= got2 then
            return got1 < got2
        else
            return itemData1.id < itemData2.id
        end
    end)
    self.m_myDashRankScore_data = tempData
end

function M:setHeroBattleOpenServerMyFightData()
    if (not self.m_hero_battle_data) then
        return
    end
    -- 1个人战力，2个人进度
    local taskType = 1
    local myFightServerData = self.m_hero_battle_data.hero_rank.quests[tostring(taskType)]
    local rank_effectData = ConfigManager:getCfgByName("hero_effect")
    local versionRankAwardData = rank_effectData[self.m_hero_battle_version]
    local awardXlsxData = versionRankAwardData[taskType]
    local tempData = {}
    for id, itemData in pairs(awardXlsxData) do
        table.insert(tempData,{
            xlsxData = itemData,
            isCanGot = (myFightServerData.value >= (itemData.target_value - 1)),
            isGot = self:isGotTask(id, myFightServerData),
            id = id,
            taskType = taskType,
        })
    end
    table.sort(tempData, function(itemData1, itemData2)
        local got1 = itemData1.isGot and 1 or -1
        local got2 = itemData2.isGot and 1 or -1
        if got1 ~= got2 then
            return got1 < got2
        else
            return itemData1.id < itemData2.id
        end
    end)

    self.m_openServerMyFight_data = tempData
end

function M:sortData(data)
    table.sort(data, function(itemData1, itemData2)
        local got1 = itemData1.isGot and 1 or -1
        local got2 = itemData2.isGot and 1 or -1
        if got1 ~= got2 then
            return got1 < got2
        else
            return itemData1.id < itemData2.id
        end
    end)
end

function M:sortMyFightData()
    table.sort(self.m_openServerMyFight_data, function(itemData1, itemData2)
        local got1 = itemData1.isGot and 1 or -1
        local got2 = itemData2.isGot and 1 or -1
        if got1 ~= got2 then
            return got1 < got2
        else
            return itemData1.id < itemData2.id
        end
    end)
end

-- 侠客争锋，是否领取指定id任务
function M:isGotTask(id, data)
    if id <= data.id then
        return true
    end
    for _, gotId in pairs(data.done) do
        if id == gotId then
            return true
        end
    end
    return false
end

function M:setHeroBattleOpenServerMyChapterData()
    -- 1个人战力，2个人进度
    local taskType = 2
    local myStageServerData = self.m_hero_battle_data.hero_rank.quests[tostring(taskType)]
    local rank_effectData = ConfigManager:getCfgByName("hero_effect")
    local versionRankAwardData = rank_effectData[self.m_hero_battle_version]
    local awardXlsxData = versionRankAwardData[taskType]
    local tempData = {}
    for id, itemData in pairs(awardXlsxData) do
        table.insert(tempData,{
            xlsxData = itemData,
            isCanGot = (myStageServerData.value >= itemData.target_value),
            isGot = self:isGotTask(id, myStageServerData),
            id = id,
            taskType = taskType,
        })
    end
    table.sort(tempData, function(itemData1, itemData2)
        local got1 = itemData1.isGot and 1 or -1
        local got2 = itemData2.isGot and 1 or -1
        if got1 ~= got2 then
            return got1 < got2
        else
            return itemData1.id < itemData2.id
        end
    end)

    self.m_openServerMyChapter_data = tempData
end

function M:getAwardByRank(rank, awardData)
    local curAwardId, curAwardData, curItemName = nil, nil
    for awardId, itemData in pairs(awardData) do
        if not curItemName then
            curItemName = itemData.item_name
        end
        local rankLimit = itemData.rank
        if #rankLimit > 1 then
            if rank >= rankLimit[1] and rank <= rankLimit[2] then
                curAwardId = awardId
                curAwardData = itemData.reward
                break
            end
        else
            if rank == rankLimit[1] then
                curAwardId = awardId
                curAwardData = itemData.reward
                break
            end
        end
    end
    return curAwardId, curAwardData, curItemName
end

--检查是否开启多个相同活动
function M:checkHaveMoreActive(open_id)
    local active_tab = ConfigManager:getCfgByName("active")
    local actives = {}
    for k,v in pairs(UserDataManager.m_actives) do
        if v.open_id == open_id then
            local c_cfg = active_tab[v.id]
            table.insert(actives, v.id)
        end
    end
    return actives
end

--检查是否开启当前活动
function M:checkHaveActive(open_id)
    if open_id == 176 then
        if M.__getIsDBChannle == nil then
            M.__getIsDBChannle = false
            if SDKUtil.is_gmsdk then
                local application_Id = SDKUtil.sdk_params.applicationId
                if application_Id == "com.hermes.wl" or SDKUtil.sdk_params.app == 2 then
                    M.__getIsDBChannle = true
                end
            end
        end

        if M.__getIsDBChannle then
            return true
        else
            return false
        end

    end

    local cfg = BtnOpenUtil:getBtnCfg(open_id)
    if cfg == nil then
        return false
    end
    local buttons = cfg.buttons or {}
    if #buttons > 0 then
        for i, v in ipairs(buttons) do
            if open_id ~= v then
                if self:checkHaveActive(v) then
                    return true
                end
            else
                Logger.logError("open_condition cfg error, key is " .. tostring(open_id))
            end
        end
    end
    return self:checkActive(open_id)
end

function M:checkActive(open_id)
    local active_tab = ConfigManager:getCfgByName("active")
    for k,v in pairs(UserDataManager.m_actives) do
        local actives = v.actives or {}
        if v.open_status > 0 then
            local c_cfg = active_tab[v.id]
            if c_cfg and open_id == c_cfg.open_id then
                if open_id == 217 then
                    return (SDKUtil.sdk_params.app == 2)
                else
                    return true
                end
            end
        end
   
    end
    return false
end

function M:getRechargeById(day_id)
    if next(self.m_continuous_data) ~= nil then
        local days = self.m_continuous_data.days
        if next(days) then
            local data = days[tostring(day_id)] or {}
            return data
        end
    end
    return nil
end

function M:checkActiveCfgByOpenId(open_id)
    local active_tab = ConfigManager:getCfgByName("active")
    for k, v in pairs(UserDataManager.m_actives) do
        if v.open_status > 0 then
            local c_cfg = active_tab[v.id]
            if open_id == c_cfg.open_id then
                return c_cfg, v
            end
        end
    end
    return nil
end

-- [策划会配两个相同的openId]
function M:checkActiveById(id)
    local active_tab = ConfigManager:getCfgByName("active")
    return active_tab[id]
end

function M:checkActiveDataByOpenId(open_id)
    local active_tab = ConfigManager:getCfgByName("active")
    for k, v in pairs(UserDataManager.m_actives) do
        if v.open_status > 0 then
            local c_cfg = active_tab[v.id]
            if c_cfg and open_id == c_cfg.open_id then
                return v
            end
        end
    end
    return nil
end

--双倍收益数据
function M:getDoubleCfg()
    return self:checkActiveCfgByOpenId(77)
end

--14日数据
function M:getStatus(version, day)
    if self.m_seven_tour_data.seven_tour and day ~= nil then
        local m_seven_tour = self.m_seven_tour_data.seven_tour[tostring(version)]
        if not m_seven_tour then
            return false
        end
        for k, v in pairs(m_seven_tour.received) do
            if day == v then
                return true
            end
        end
        return false
    else
        return false
    end
end

-- 获取当前应该得到奖励的天数
function M:getCurCanGotAwardDay(version, select_index)
    local curIndex = 0
    if not select_index then
        return curIndex
    end
    for i = 1,select_index do
        if self:getStatus(version,i) == false then
            curIndex = i
            break
        end
    end
    return curIndex
end

function M:canGetIndex(version, day)
    if self.m_seven_tour_data and day ~= nil then
        local m_seven_tour = self.m_seven_tour_data.seven_tour[tostring(version)]
    end
    if #self.m_seven_tour_data.seven_tour_received > 0 then
        local last_get = self.m_seven_tour_data.seven_tour_received[#self.m_seven_tour_data.seven_tour_received]
        if self.m_day >= last_get then
            return last_get + 1
        else
            return -1
        end
    else
        return 1
    end
end

--签到双倍
function M:getDailyDoubleData(id)
    for k, v in pairs(self.m_sign_daily_data.sign_daily_reward.recharge) do
        if id == v then
            return v
        end
    end
    return nil
end

--签到双倍
function M:getDailyRechargeData(id)
    for k, v in pairs(self.m_sign_daily_data.sign_daily_reward.recharge_receive) do
        if id == v then
            return v
        end
    end
    return nil
end

--每日宝箱
function M:getDailyBoxData(id)
    for k, v in pairs(self.m_sign_daily_data.sign_daily_reward.box) do
        if id == v then
            return v
        end
    end
    return nil
end

function M:getDailyExtraReward(id)
    if id > 31 then
        return nil
    end
    return self.m_sign_daily_data.sign_daily_reward.config[tostring(id)].extra_reward
end

--绿林集结
function M:getHeroCadeStatus(index)
    if self.hero_gather_received == nil then
        return 0
    end
    local hero_gather = ConfigManager:getCfgByName("hero_gather")
    local cfg = hero_gather[index]
    for i, v in ipairs(self.hero_gather_received) do
        if v == index then
            return 2 -- 已领取
        end
    end
    if UserDataManager.elite_hero_nums < cfg.num then
        return 0 -- 未完成
    end

    return 1 -- 可领取
end

--侠客集结
function M:getHeroActiveCadeStatus(hero_num, version, ID)
    if self.hero_gather_active_received == nil then
        return 0
    end
    local hero_gather_active = ConfigManager:getCfgByName("hero_gather_active")
    local hero_gather_active_version = hero_gather_active[version] or {}
    local cfg = hero_gather_active_version[ID] or {}
    local hero_gather_active_received = self.hero_gather_active_received[tostring(version)] or {}
    local hero_gather_active_received_version = hero_gather_active_received.received or {}
    for i, v in ipairs(hero_gather_active_received_version) do
        if v == ID then
            return 2 -- 已领取
        end
    end
    if hero_num < cfg.num then
        return 0 -- 未完成
    end
    return 1 -- 可领取
end

function M:getCurOnlineCfg()
    local tab = self:get_online_tab()
    if self.m_online_reward_data.online_reward.config == -1 then
        return nil
    end
    local cur_cfg = nil
    for k, v in pairs(tab) do
        if v.id == self.m_online_reward_data.online_reward.config then
            cur_cfg = v.cfg
        end
    end
    if cur_cfg then
        local now_tim = UserDataManager:getServerTime()
        local s_time = self.m_online_reward_data.online_reward.stime
        local interval = now_tim - s_time
        return (cur_cfg.time * 60) - interval
    end
    return nil
end

--卦签任务
function M:get_task_data()
    return self.m_draw_data.quests or {}
end

function M:get_task_shop()
    return self.m_draw_data.shop_done or {}
end

function M:get_task_login()
    return self.m_draw_data.login_done or {}
end

--抽到过的卦签
function M:getDrawRewardData(id)
    if self.m_draw_data then
        for k, v in pairs(self.m_draw_data.recv_list) do
            if id == v then
                return true
            end
        end
    end
    return false
end

function M:getGuaRedPoint()
    local consume_data = self:getDrawConsume()
    if self:checkGuaAllGet() == true then
        return false
    end
    if consume_data.user_num >= consume_data.data_num then
        return true
    else
        for k, v in pairs(UserDataManager.m_actives) do
            if v.id == 7 then
                v.can_draw = false
            end
        end
        return false
    end
end

function M:checkGuaAllGet()
    local draw_tab_1 = self:getDrawRewardCfg(1)
    local draw_tab_2 = self:getDrawRewardCfg(2)
    local draw_tab_3 = self:getDrawRewardCfg(3)
    for i = 1, #draw_tab_1 do
        local reward_cfg = draw_tab_1[i]
        local draw_get = self:getDrawRewardData(reward_cfg.id)
        if draw_get == false then
            return false
        end
    end
    for i = 1, #draw_tab_2 do
        local reward_cfg = draw_tab_2[i]
        local draw_get = self:getDrawRewardData(reward_cfg.id)
        if draw_get == false then
            return false
        end
    end
    for i = 1, #draw_tab_3 do
        local reward_cfg = draw_tab_3[i]
        local draw_get = self:getDrawRewardData(reward_cfg.id)
        if draw_get == false then
            return false
        end
    end
    return true
end

function M:getReceived(m_type, id)
    if m_type == 1 then
        return self.m_war_older_data.valor_received.free[id], self.m_war_older_data.valor_received.payment[id]
    elseif m_type == 2 then
        return self.m_war_older_data.heroic_received.free[id], self.m_war_older_data.heroic_received.payment[id]
    end
end

--锦囊玉轴消耗
function M:getCostNum()
    local scroll_tab = ConfigManager:getCfgByName("scroll")
    local cfg = scroll_tab[self.m_scroll_data.version]
    return cfg.score[1]
end

--锦囊玉轴配置
function M:getScrollCfg()
    local scroll_tab = ConfigManager:getCfgByName("scroll")
    local cfg = scroll_tab[self.m_scroll_data.version]
    return cfg
end

--锦囊玉轴配置数据
function M:get_scroll_cfg()
    local fund_tab = ConfigManager:getCfgByName("scroll_reward")
    return fund_tab[self.m_scroll_data.version][self.m_scroll_data.layer]
end

--锦囊玉轴首次进入
function M:get_check_scroll_first()
    if self.m_scroll_data == nil then
        return false
    end
    local status = UserDataManager.local_data:getUserDataByKey("active_scroll" .. self.m_scroll_data.version, 0)
    return status == 0
end

function M:set_scroll_first()
    UserDataManager.local_data:setUserDataByKey("active_scroll" .. self.m_scroll_data.version, 1)
end

function M:checkBigRcvd()
    local reward_library = ConfigManager:getCfgByName("big_reward_library")
    return reward_library[self.m_scroll_data.big_gift_id]
end

function M:getScrollRcvdGift(index)
    local data = self.m_scroll_data.rcvd_gifts[tostring(index)]
    return data or {}
end

--卦签数据
function M:get_draw_cfg()
    local draw_tab = ConfigManager:getCfgByName("draw_reward")
    local version_draw = draw_tab[self.m_draw_data.version]
    return version_draw[self.m_draw_data.layer]
end

--卦签消耗品
function M:getDrawConsume()
    local draw_tab = ConfigManager:getCfgByName("draw")
    local draw_cfg = draw_tab[self.m_draw_data.version]
    local hv_num = self.m_draw_data.recv_num + 1
    if hv_num > #draw_cfg.score then
        hv_num = #draw_cfg.score
    end
    local data_num = draw_cfg.score[hv_num]
    local consume_data = RewardUtil:getProcessRewardData({103, draw_cfg.item_id, data_num})
    return consume_data
end

--卦签展示侠客id
function M:getDrawHeroID()
    local draw_tab = ConfigManager:getCfgByName("draw")
    local draw_cfg = draw_tab[self.m_draw_data.version]
    local hero_id = draw_cfg.hero_id
    return hero_id
end

function M:getScrollConsume()
    if self.m_scroll_data == nil then
        return nil
    end
    local scroll_tab = ConfigManager:getCfgByName("scroll")
    local scroll_cfg = scroll_tab[self.m_scroll_data.version]
    local data_consume = scroll_cfg.score[1]
    local consume_data = RewardUtil:getProcessRewardData(data_consume)
    return consume_data
end

function M:getDrawRewardCfg(type)
    local draw_tab = self:get_draw_cfg()
    local new_tab = {}
    for k, v in pairs(draw_tab) do
        if type == v.sort then
            v.id = k
            table.insert(new_tab, v)
        end
    end
    local function sortFunc(id_one, id_two)
        return id_one.id < id_two.id
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

function M:getMaxFloor()
    local scroll_tab = ConfigManager:getCfgByName("scroll_reward")
    local scroll_list = scroll_tab[self.m_scroll_data.version] or {}
    return #scroll_list
end

--藏宝图奖励
function M:getTreasureRewardCfg(index, version)
    local treasure_tab = ConfigManager:getCfgByName("treasure_reward")
    return treasure_tab[version or 1][index]
end

--藏宝图任务
function M:getTreasureQuestCfg(index, version)
    local treasure_tab = ConfigManager:getCfgByName("treasure_quest")
    return treasure_tab[version or 1][index]
end

--藏宝图版本
function M:getTreasureByVersion(version)
    local treasure_tab = ConfigManager:getCfgByName("treasure")
    return treasure_tab[version or 1]
end

--成长基金配置数据
function M:get_fund_cfg()
    local fund_tab = ConfigManager:getCfgByName("growth_fund_reward")
    return fund_tab
end

--皇家战令配置数据
function M:get_royal_cfg()
    local royal_tab = ConfigManager:getCfgByName("royal_reward")
    return royal_tab
end

--勇者战令配置数据
function M:get_warrior_cfg()
    local warrior_tab = ConfigManager:getCfgByName("warrior_reward")
    return warrior_tab
end

--连续充值配置数据
function M:get_gontinuous_cfg()
    local recharge_tab = ConfigManager:getCfgByName("last_recharge")
    return recharge_tab[1]
end

--每日特惠配置数据
function M:get_gift_off_cfg()
    local gift_off_tab = ConfigManager:getCfgByName("gift_off")
    return gift_off_tab
end

--新手礼包配置数据
function M:get_gift_new_cfg()
    local gift_new_tab = ConfigManager:getCfgByName("gift_new")
    return gift_new_tab
end

--日礼包
function M:get_gift_daily_cfg()
    local gift_daily_tab = ConfigManager:getCfgByName("gift_daily")
    return gift_daily_tab
end

--周礼包
function M:get_gift_week_cfg()
    local gift_week_tab = ConfigManager:getCfgByName("gift_week")
    return gift_week_tab
end

--月礼包
function M:get_gift_month_cfg()
    local gift_month_tab = ConfigManager:getCfgByName("gift_month")
    return gift_month_tab
end

--月卡
function M:get_month_card_cfg()
    local month_card_tab = ConfigManager:getCfgByName("month_card")
    return month_card_tab
end

--基金
function M:get_fund_reward_cfg()
    local fund_reward_tab = ConfigManager:getCfgByName("growth_fund_reward")
    return fund_reward_tab
end

--基金购买项
function M:get_growth_fund()
    local growth_fund_tab = ConfigManager:getCfgByName("growth_fund")
    return growth_fund_tab
end

--限时兑换
function M:get_exchange_cfg(version)
    local exchange_tab = ConfigManager:getCfgByName("exchange")
    return exchange_tab[version or 1]
end

--限时兑换奖励列表
function M:get_exchange_limit_cfg(version)
    local exchange_limit_tab = ConfigManager:getCfgByName("exchange_limit")
    local version_tab = exchange_limit_tab[version]
    local new_tab = {}
    for i = 1, #version_tab do
        local cur_cfg = version_tab[i]
        cur_cfg.id = i
        table.insert(new_tab, cur_cfg)
    end
    local function sortFunc(id_one, id_two)
        local data_1 = self:getExchangeData(version, id_one.id)
        local data_2 = self:getExchangeData(version, id_two.id)
        local time1 = 1
        local time2 = 1
        if id_one.times > 0 and data_1 >= id_one.times then
            time1 = 0
        end
        if id_two.times > 0 and data_2 >= id_two.times then
            time2 = 0
        end
        if time1 == time2 then
            return id_one.id < id_two.id
        else
            return time1 > time2
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

function M:getExchangeData(ver, id)
    if self.m_exchange_data.exchange.times ~= nil then
        for k, v in pairs(self.m_exchange_data.exchange.times) do
            if k == tostring(id) then
                return v
            end
        end
    end
    return 0
end

function M:get_heaven_bless_reward_cfg(version) --获取天赐祈福配表数据
    local result_tab = {}
    local weekend_gacha_reward_cfg = ConfigManager:getCfgByName("weekend_gacha_reward")  --所有奖励
    local lottery_count_reward_cfg = ConfigManager:getCfgByName("lottery_count_reward")     --轮次奖励
    local lottery_cfg = ConfigManager:getCfgByName("lottery")       --轮次使用的灵石数量
    
    if version then
        result_tab.version = version 
        result_tab.reward_cfg = weekend_gacha_reward_cfg[400][version]
        result_tab.round_reward_cfg = lottery_count_reward_cfg[400][version]
        --result_tab.needStoneNum_cfg = lottery_cfg[400][version][1].score
        result_tab.needStoneNum_cfg = lottery_cfg[400][version].score
        
    end
    return result_tab
end

function M:get_heaven_bless_reward_data(version) --获取天赐祈福服务器数据
    local params = {
        open_id = 400,
        vsn = 1,
    }
    local getheaven = function (response)
        self.m_heavenBless_data = response
    end
    self:getNetData("weekend_sevent_index",params,getheaven)

end

--满月兑换
function M:get_month_exchange_cfg(version)
    local exchange_tab = ConfigManager:getCfgByName("month_exchange")
    if exchange_tab[version] then
        return exchange_tab[version or 1]
    end
    return exchange_tab[1]
end

--满月兑换奖励列表
function M:get_month_exchange_limit_cfg(version)
    local exchange_limit_tab = ConfigManager:getCfgByName("month_exchange_limit")
    local version_tab = exchange_limit_tab[version]
    local new_tab = {}
    local cur_season = UserDataManager:getCurSeason()
    local self_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    local season_condition_flag = false
    for i = 1, #version_tab do
        local cur_cfg = version_tab[i]
        cur_cfg.id = i
        season_condition_flag = false
        if cur_cfg.season1 and cur_cfg.season and cur_cfg.vip then
            if cur_cfg.season1 == -1 then
                if cur_cfg.season <= cur_season and cur_cfg.vip <= self_vip then
                    season_condition_flag = true
                end
            elseif cur_cfg.season1 == cur_season and cur_cfg.vip <= self_vip then
                season_condition_flag = true
            end
        end
        if season_condition_flag == true then
            table.insert(new_tab, cur_cfg)
        end
    end
    local function sortFunc(id_one, id_two)
        local data_1 = self:getMonthExchangeData(version, id_one.id)
        local data_2 = self:getMonthExchangeData(version, id_two.id)
        local time1 = 1
        local time2 = 1
        if id_one.times > 0 and data_1 >= id_one.times then
            time1 = 0
        end
        if id_two.times > 0 and data_2 >= id_two.times then
            time2 = 0
        end
        if time1 == time2 then
            return id_one.id < id_two.id
        else
            return time1 > time2
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

function M:getMonthExchangeData(ver, id)
    if self.m_month_exchange_data.exchange.times ~= nil then
        for k, v in pairs(self.m_month_exchange_data.exchange.times) do
            if k == tostring(id) then
                return v
            end
        end
    end
    return 0
end


--神飨兑换
function M:get_eat_exchange_cfg(version)
    local exchange_tab = ConfigManager:getCfgByName("active_exchange")
    if exchange_tab[version] then
        return exchange_tab[version or 1]
    end
    return exchange_tab[1]
end

--神飨兑换奖励列表
function M:get_eat_exchange_limit_cfg(version)
    local exchange_limit_tab = ConfigManager:getCfgByName("active_exchange_limit")
    local version_tab = exchange_limit_tab[version]
    local new_tab = {}
    local cur_season = UserDataManager:getCurSeason()
    local self_vip = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    local season_condition_flag = false
    for i = 1, #version_tab do
        local cur_cfg = version_tab[i]
        cur_cfg.id = i
        season_condition_flag = false
        if cur_cfg.season1 and cur_cfg.season and cur_cfg.vip then
            if cur_cfg.season1 == -1 then
                if cur_cfg.season <= cur_season and cur_cfg.vip <= self_vip then
                    season_condition_flag = true
                end
            elseif cur_cfg.season1 == cur_season and cur_cfg.vip <= self_vip then
                season_condition_flag = true
            end
        end
        if season_condition_flag == true then
            table.insert(new_tab, cur_cfg)
        end
    end
    local function sortFunc(id_one, id_two)
        local data_1 = self:getEatExchangeData(version, id_one.id)
        local data_2 = self:getEatExchangeData(version, id_two.id)
        local time1 = 1
        local time2 = 1
        if id_one.times > 0 and data_1 >= id_one.times then
            time1 = 0
        end
        if id_two.times > 0 and data_2 >= id_two.times then
            time2 = 0
        end
        if time1 == time2 then
            return id_one.id < id_two.id
        else
            return time1 > time2
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

function M:getEatExchangeData(ver, id)
    if self.m_eat_exchange_data.exchange ~= nil and self.m_eat_exchange_data.exchange[tostring(ver)] then
        for k, v in pairs(self.m_eat_exchange_data.exchange[tostring(ver)]) do
            if k == tostring(id) then
                return v
            end
        end
    end
    return 0
end

--紫卡兑换
function M:get_hero_exchange_cfg(version)
    local exchange_tab = ConfigManager:getCfgByName("card_exchange")
    if exchange_tab then
        return exchange_tab[version or 1]
    else
        return {}
    end
end

--紫卡兑换奖励列表
function M:get_hero_exchange_limit_cfg(version)
    local exchange_limit_tab = ConfigManager:getCfgByName("card_exchange_limit")
    if exchange_limit_tab == nil then 
        return {}
    end
    local version_tab = exchange_limit_tab[version]
    local new_tab = {}
    local cur_vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
    local cur_season = UserDataManager:getCurSeason()
    for i = 1, #version_tab do
        local cur_cfg = version_tab[i]
        cur_cfg.id = i
        if cur_cfg.season and cur_season >= cur_cfg.season then
            if cur_vip >= cur_cfg.vip then
                table.insert(new_tab, cur_cfg)
            end
        end
    end
    local function sortFunc(id_one, id_two)
        local data_1 = self:getHeroExchangeData(version, id_one.id)
        local data_2 = self:getHeroExchangeData(version, id_two.id)
        local time1 = 1
        local time2 = 1
        if id_one.times > 0 and data_1 >= id_one.times then
            time1 = 0
        end
        if id_two.times > 0 and data_2 >= id_two.times then
            time2 = 0
        end
        if time1 == time2 then
            return id_one.id < id_two.id
        else
            return time1 > time2
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end


function M:getHeroExchangeData(ver, id)
    if self.m_hero_exchange_data == nil or next(self.m_hero_exchange_data) == nil then
        return 0
    end 
    if self.m_hero_exchange_data.exchange.times ~= nil then
        for k, v in pairs(self.m_hero_exchange_data.exchange.times) do
            if k == tostring(id) then
                return v
            end
        end
    end
    return 0
end


--元宝商店
function M:get_charge_cfg()
    local charge_tab = ConfigManager:getCfgByName("charge")
    local data = {}
    for k, v in pairs(charge_tab) do
        if v.sort == 0 then
            table.insert(data, v)
        end
    end
    return data
end

--14日登录
function M:get_seven_tour(version)
    local seven_tour_tab = ConfigManager:getCfgByName("seven_tour")
    return seven_tour_tab[version or 1]
end

--每日签到
function M:get_sign_daily()
    local sign_daily_tab = ConfigManager:getCfgByName("sign_daily_reward")
    return sign_daily_tab
end

--绿林集结
function M:get_hero_gather()
    local hero_gather_tab = ConfigManager:getCfgByName("hero_gather")
    for k, v in pairs(hero_gather_tab) do
        v.id = k
    end
    local temp_tab_get = {}
    local temp_tab_noget = {}
    local new_tab = {}
    for i = 1, #hero_gather_tab do
        local type = self:getHeroCadeStatus(i)
        if type == 2 then
            table.insert(temp_tab_get, hero_gather_tab[i])
        else
            table.insert(temp_tab_noget, hero_gather_tab[i])
        end
    end
    for i = 1, #temp_tab_noget do
        table.insert(new_tab, temp_tab_noget[i])
    end
    for i = 1, #temp_tab_get do
        table.insert(new_tab, temp_tab_get[i])
    end
    return new_tab
end

--侠客集结
function M:get_hero_gather_active(hero_num, version)
    local hero_gather_tab = ConfigManager:getCfgByName("hero_gather_active")
    local hero_gather_tab_version = hero_gather_tab[version] or {}
    for k, v in pairs(hero_gather_tab_version) do
        v.id = k
    end
    local temp_tab_get = {}
    local temp_tab_noget = {}
    local new_tab = {}
    local vip_self = UserDataManager.user_data:getUserStatusDataByKey("vip")
    for i = 1, #hero_gather_tab_version do
        if hero_gather_tab_version[i].vip and hero_gather_tab_version[i].vip <= vip_self then
            local type = self:getHeroActiveCadeStatus(hero_num, version, i)
            if type == 2 then
                table.insert(temp_tab_get, hero_gather_tab_version[i])
            else
                table.insert(temp_tab_noget, hero_gather_tab_version[i])
            end
        end
    end
    for i = 1, #temp_tab_noget do
        table.insert(new_tab, temp_tab_noget[i])
    end
    for i = 1, #temp_tab_get do
        table.insert(new_tab, temp_tab_get[i])
    end
    return new_tab
end

--在线奖励
function M:get_online_tab()
    local index = self.m_online_reward_data.online_reward.config or 1
    local new_tab = {}
    local old_tab = {}
    local all_tab = {}
    local online_reward_tab = ConfigManager:getCfgByName("online_reward")
    for i = 1, #online_reward_tab do
        if i >= index then
            table.insert(new_tab, {id = i, cfg = online_reward_tab[i]})
        else
            table.insert(old_tab, {id = i, cfg = online_reward_tab[i]})
        end
    end
    for i = 1, #new_tab do
        table.insert(all_tab, new_tab[i])
    end
    for i = 1, #old_tab do
        table.insert(all_tab, old_tab[i])
    end
    return all_tab
end

--在线奖励
function M:get_double_tab(version)
    local double_tab = ConfigManager:getCfgByName("double_reward")
    local ver_tab = double_tab[version]
    local new_tab = {}
    for i, v in pairs(ver_tab) do
        v.id = i
        table.insert(new_tab, v)
    end
    return new_tab
end

function M:getJump(id)
    local jump_tab = ConfigManager:getCfgByName("jump")
    return jump_tab[id]
end

function M:getTreasureQuests(index)
    return self.m_treasure_data.quests[tostring(index)] or 0
end

function M:updateTreasureQuests(data)
    for k, v in pairs(data.quests) do
        self.m_treasure_data.quests[k] = v
    end
end

function M:getTresureNum()
    local num = 0
    for k, v in pairs(self.m_treasure_data.quests) do
        if v.status == 2 then
            num = num + 1
        end
    end
    return num
end

function M:getTreasureReceived(index)
    if self.m_treasure_data == nil then
        return false
    end
    for k, v in pairs(self.m_treasure_data.received) do
        if index == v then
            return true
        end
    end
    return false
end

function M:getHeroTrainCfg(version)
    local hero_train_tab = ConfigManager:getCfgByName("train_challenge")
    local c_version = version or self.m_hero_train_data.version
    Logger.logError(" c_version " .. c_version .. " version " .. self.m_hero_train_data.version)
    return hero_train_tab[c_version]
end

function M:getHeroTrainRankReward()
    local hero_train_tab = ConfigManager:getCfgByName("train_rank_reward")
    local c_version = self.m_hero_train_data.version
    local c_id = self.m_hero_train_data.rank_id or 0
    local cur_cfg = hero_train_tab[c_version][c_id]
    if cur_cfg then
        return cur_cfg.reward
    end
    return {}
end

function M:checkActiveIsEnd(open_id)
    if open_id == 132 then
        for k, v in pairs(self.m_hero_train_data.actives) do
            if v.open_status > 0 then
                return v.end_ts - UserDataManager:getServerTime()
            end
        end
    end
    return 0
end

function M:getActiveEndTime(actives, open_id)
    if actives and next(actives) ~= nil then
        for k, v in pairs(actives) do
            if v.open_status > 0 then
                return v.end_ts
            end
        end
    end
    return -1
end

-- 设置开服排行榜相关数据（侠客争锋）
function M:setOpenServerRankData(data)
    if data["end"] == 1 then
        return
    end
    self.m_hero_battle_version = data.hero_rank.version
    self.m_hero_battle_data = data
    self.m_hero_battle_curValue = {}
    self.m_hero_battle_openId = data.actives[1].open_id
    -- 1战力，2章节，3秘籍积分，对应hero_effect表type
    for index, itemData in pairs(data.hero_rank.quests) do
        local curValue = itemData.value
        -- 序章不算
        if index == "2" then
            curValue = (itemData.value - 1) > 0 and (itemData.value - 1) or 0
        end
        self.m_hero_battle_curValue[tonumber(index)] = curValue
    end
end

-- 设置赛季冲榜按钮信息
function M:initDashRankTabData(version)
    -- 排行是1类型，任务是2类型
    local tabList = {}
    local rankTabList = {}
    local taskTabList = {}
    local rankData = ConfigManager:getCfgByName("rank_effect")
    local rankVersionData = rankData[version]
    local tabType = 1
    for _, itemVersionData in pairs(rankVersionData) do
        for _, itemData in pairs(itemVersionData) do
            if not rankTabList[itemData.type] then
                tabType = 1
                rankTabList[itemData.type] = {
                    tabType = tabType,
                    rankType = itemData.type,
                    taskType = -1,
                    order = itemData.order,
                    name = itemData.tab_name,
                }
            end
        end
    end

    local taskData = ConfigManager:getCfgByName("hero_effect")
    local taskVersionData = taskData[version]
    for _, itemVersionData in pairs(taskVersionData) do
        for _, itemData in pairs(itemVersionData) do
            if not taskTabList[itemData.type] then
                tabType = 2
                taskTabList[itemData.type] = {
                    tabType = tabType,
                    taskType = itemData.type,
                    rankType = -1,
                    order = itemData.order + tabType * 10,
                    name = itemData.tab_name,
                }
            end
        end
    end
    for _, itemData in pairs(rankTabList) do
        table.insert(tabList,itemData)
    end
    for _, itemData in pairs(taskTabList) do
        table.insert(tabList,itemData)
    end
    table.sort(tabList, function(itemData1, itemData2)
        if itemData1.tabType ~= itemData2.tabType then
            return itemData1.tabType < itemData2.tabType
        else
            return itemData1.order < itemData2.order
        end
    end)
    self.m_TabListData = tabList
end

--满月活动数据--------------------------------------------------------------------------------------------------
function M:getMonthExCfg(version)
    local exchange_limit_tab = ConfigManager:getCfgByName("month_exchange_limit")
    local c_version = version or self.m_hero_train_data.version
    return exchange_limit_tab[c_version]
end

--满月活动数据END--------------------------------------------------------------------------------------------------

--英雄兑换活动数据--------------------------------------------------------------------------------------------------
function M:getHeroDataList()
    local hero_data_list = {}
    for k,v in pairs(UserDataManager.hero_data.m_ids) do
        local hero_data,hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        if hero_data.lv == 1 and hero_data.clv == 0 then
            if hero_data_list[hero_data.id] then
                if hero_data_list[hero_data.id][hero_data.evo] then
                    hero_data_list[hero_data.id][hero_data.evo] = hero_data_list[hero_data.id][hero_data.evo] + 1
                else
                    hero_data_list[hero_data.id][hero_data.evo] = 1
                end
            else
                local new_tab = {}
                new_tab[hero_data.evo]  = 1
                hero_data_list[hero_data.id] = new_tab
            end
        end
    end
    self.hero_data_list = hero_data_list
end

function M:getHeroNumByEvo(data)
    if self.hero_data_list then
        if self.hero_data_list[data[1]] and self.hero_data_list[data[1]][data[2]] then
            return self.hero_data_list[data[1]][data[2]]
        end
    end
    return 0
end

--英雄兑换END数据--------------------------------------------------------------------------------------------------


--- 网络数据回调，需要复写
function M:netData(data, tag)
    if tag == "draw_index" then
        --卦签
        self.m_draw_data = data
    elseif tag == "scroll_index" then
        self.m_scroll_data = data or {} --锦囊
    elseif tag == "active_hero_gather_index" then
        self.m_hero_gather_data = data or {} --绿林
    elseif tag == "active_hero_gather_active_index" then
        self.m_hero_gather_active_data = data or {} --侠客
    elseif tag == "active_seven_tour_index" then --14日
        self.m_seven_tour_data = data or {}
    elseif tag == "sign_daily_index" then --签到
        self.m_sign_daily_data = data or {}
    elseif tag == "treasure_index" then --藏宝图
        self.m_treasure_data = data or {}
    elseif tag == "hero_train_index" then --侠客试炼
        self.m_hero_train_data = data or {}
    elseif tag == "exchange_index" then --限时兑换
        self.m_exchange_data = data or {}
    elseif tag == "month_card" then
        self.m_month_card_data = data --月卡数据
    elseif tag == "hero_rank_index" then -- 侠客争锋 --- 赛季冲榜活动
        self:setOpenServerRankData(data)
    elseif tag == "producer_index" then -- 制作人赠礼
        -- 0未领取 1已领取
        self.m_isGotProducer_data = (data.producer == 1)
    elseif tag == "tiktok_data" then
        if data and data.tiktok_record then
            self.m_tiktok_data = data.tiktok_record
        else
            self.m_tiktok_data = {}
        end
    elseif tag == "bowl_index" then     ---- 聚宝盆，充值返利
        self.m_rechargeAndRebate_data = data
    elseif tag == "wish_index" then     ---- 鸿运祈福入口
        self.m_kongMingLight_Data = data
    elseif tag == "recharge_rebate" then     ---- 充值返利入口
        self.m_rechargeRebata_Data = data
    elseif tag == "weekend_sevent_index" then                   --天赐祈福入口
        if data.weekendsevent then
            self.m_heavenBless_data.weekendsevent = data.weekendsevent
        end
    end
end




return M
