local M = class("TopUpGiftBagModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("payment_enter")
end

function M:onEnter()
    self.m_vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
    local vip_cfg = self:getVipCfg()
    self.vip_gift_times = vip_cfg.gift_times
    self.actives = self.m_params.actives
    local select_open_id = self.m_params.open_id or 0
    self.m_sel_tab_index = 1 --默认开启
    self.tag_table = self:getTagTabs(149)

    if select_open_id == -1 then --代金券进入
        self.is_tokens = true
    else
        self.is_tokens = false 
    end
    self:refreshDataTime()

end

function M:switchByOpenId(open_id)
    for k,v in pairs(self.tag_table) do
        if v.open_id == open_id then 
        return k
        end
    end
    return -1
end


--检查是否有司南礼包
function M:getActiveRecharge26()
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    for k,v in pairs(self.actives) do
        local c_cfg = active_tab[v.id]
        if c_cfg and v.open_status > 0 and c_cfg.name == "tid#ActiveRechargeName_26" then
            return v.id
        end
    end
end

function M:initData(url, call_back, data)
    self:getNetData(url, data, call_back)
end

--刷新接口请求
function M:refreshData(call_back)
    local function callFunc(data)
        if data then
            table.merge(self.m_data,data)
            self.tag_table = self:getTagTabs(149)
            self:refreshDataTime()
            call_back()
        end
    end
    self:getNetData("payment_enter",nil,callFunc,nil,true)
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
    local active_tab = ConfigManager:getCfgByName("active")
    for k,v in pairs(self.m_data.actives) do
        local bl = false
        for kk,vv in pairs(v.actives) do
            if vv and vv.open_status > 0 and vv.open_id == open_id then
                bl = true
            end
        end
        if open_id == 150 and v.open_id == 150 then
            bl = true
        end
        if bl == true then
            if url_name == "user_payment_recommend_index" then --推荐页
                self.m_recommend_data = v
            elseif url_name == "gift_off_index" then     --特惠礼包
                self.m_gift_off_data = v.gift_off
                self.m_gift_off_actives = v.actives
            elseif url_name == "gift_new_index" then     --新手礼包
                self.m_net_actives = v.actives
                self.m_gift_new_data = v.gift_new
            elseif url_name == "bright_bless_index" then     --新手福利
                self.m_bright_data = v    
                self.m_skin_gift_data = v.skin_gift or {}
            elseif url_name == "gift_supervalue_index" then      --超值礼包
                self.m_net_actives = v.actives
                self.m_supervalu_data = v.gift_data
            elseif url_name == "continuous_index" then      --连续充值
                self.m_continuous_data = v.continuous_payment
            elseif url_name == "skin_gift_index" then      --皮肤礼包数据
                self.m_skin_gift_data = v
            elseif url_name == "activity_limit_index" then      --限时礼包数据
                self.m_limit_data = v
            elseif url_name == "custom_gift_index" then      --定制礼包数据
                self.m_custom_data = v.custom_gift
                self.m_custom_actives = v.actives
            elseif url_name == "hero_gift_index" then      --英雄成长礼包数据
                self.m_hero_gift_data = v.gifts_detail
                self.m_hero_gift_actives= v.actives
            elseif url_name == "equip_gift_index" then      --神兵成长礼包数据
                self.m_equip_gift_data = v.gifts_detail
                self.m_equip_gift_actives = v.actives 
                self.m_equip_quality_num = v.equip_quality_num 
            elseif (url_name == "gift_value_index") or (url_name == "gift_value_limit_index")  then --阶梯礼包
                self.m_ladder_actives = v.actives
                self.m_ladder_data = v.data
                self.m_charge_sum = v.charge_sum
            elseif url_name == "gift_mould_index" then--多期阶梯礼包
                self.m_ladder_actives = v.actives
                self.m_ladder_data = v.gift_mould
                self.m_charge_sum = v.charge_sum
            elseif url_name == "gift_value_week_index" then --每周阶梯礼包
                self.m_everyWeek_ladder_actives = v.actives
                self.m_everyWeek_ladder_data = v.data
                self.m_everyWeek_charge_sum = v.charge_sum
                self.m_ladder_recommend_data = nil
            elseif url_name == "gift_value_daily_index" then --每日阶梯礼包
                self.m_everyDay_ladder_actives = v.actives
                self.m_everyDay_ladder_data = v.data
                self.m_everyDay_charge_sum = v.charge_sum
                -- 新增的每日阶梯礼包推荐礼包
                self.m_ladder_recommend_data = v.recommend or nil
            elseif url_name == "pay_shop_index" then
                self.m_charge_data = v
            elseif url_name == "growth_gift_index" then      --英雄成长礼包数据
                self.m_growth_gift_data = v.gifts_detail
                self.m_growth_gift_actives= v.actives
            end
        end
    end
end


--获取二级页签列表
function M:getTagTabs(open_id)
    local opne_tab = ConfigManager:getCfgByName("open_condition")
    local active_tab = opne_tab[open_id]
    local temp_tab = table.copy(active_tab.buttons)
    local remove_tab = {}
    --剔除未开启的
    if #temp_tab > 0 then
        for i,v in pairs(temp_tab) do
            --连续充值、累计充值没有页签
            if self:checkHaveActive(v) == false or v == 79 or v == 130  then
                remove_tab[i] = true
            end
        end
        for i = #temp_tab, 1,-1 do
            if remove_tab[i] == true then
                table.remove(temp_tab, i)
            end
        end
    end
    --检查多个
    local new_tab = {}
    for i =1, #temp_tab  do
        local open_id = temp_tab[i]
        local actives = self:checkHaveMoreActive(open_id)
        if #actives >= 1 then
            for i = 1, #actives do
                table.insert(new_tab, {open_id = open_id, id = actives[i] })
            end
        else
            table.insert(new_tab, {open_id = open_id})
        end
    end
    return new_tab
end

function M:checkRechargeActIsShow(cfg_name, cur_version)
    local show_cfg = ConfigManager:getCfgByName(cfg_name) or {}
    local cur_cfg = show_cfg[cur_version] or {}
    local is_show = true
    if cur_cfg.is_show ~= nil then
        is_show = cur_cfg.is_show == 1
    end
    return is_show
end

--检查是否开启当前活动
function M:checkHaveActive(open_id)
    if open_id == 150 then
        return true
    end
    local cfg = BtnOpenUtil:getBtnCfg(open_id)
    if cfg == nil then return false end
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

--检查是否开启多个相同活动
function M:checkHaveMoreActive(open_id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    local actives = {}
    for k,v in pairs(self.m_data.actives) do
        if v.open_id == open_id then
            local c_cfg = active_tab[v.id]
            table.insert(actives, v.id)
        end
    end
    return actives
end

function M:checkActive(open_id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    for k,v in pairs(UserDataManager.m_active_recharge) do
        if v.open_status > 0 then
            local c_cfg = active_tab[v.id]
            if c_cfg and open_id == c_cfg.open_id then
                return true
            end
        end
    end
    return false
end

function M:getActiveByOpenId(open_id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    for i,v in pairs(active_tab) do
        if v.open_id == open_id then
            return v
        end
    end
    return nil
end

--领取特惠礼包数据
function M:getGiftOffData(version, id)
    if self.m_gift_off_data[tostring(version)] then
        for k,v in pairs(self.m_gift_off_data[tostring(version)].gifts) do
            if id == v then
                return true
            end
        end
    end
    return false
end

function M:getVipCfg()
    local vip_tab = ConfigManager:getCfgByName("vip")
    return vip_tab[self.m_vip]
end


--日礼包
function M:get_gift_daily_cfg()
    local gift_daily_tab = ConfigManager:getCfgByName("gift_daily")
    local vsn = self.m_supervalu_data.version or 1
    local vsn_gift_daily_tab = gift_daily_tab[vsn] or {}
    local new_tab = {}
    for k,v in pairs(vsn_gift_daily_tab) do
        local cur_cfg = table.copy(v) 
        cur_cfg.id = k
        if cur_cfg.sort == 1 then
            if self:checkStageLimit(cur_cfg) == true then
                table.insert( new_tab, cur_cfg)
            end
        elseif self:readFestivalData(cur_cfg) == true then
            if self:checkStageLimit(cur_cfg) == true then
                table.insert( new_tab, cur_cfg)
            end
        end
    end
    local function sortFunc(id_one, id_two)
        local data_1 = self:getBagComData(id_one.id) 
        local data_2 = self:getBagComData(id_two.id)
        local time1 = 1
        local time2 = 1
        if id_one.time_limit > 0 and data_1 and data_1 >= id_one.time_limit then
            time1 = 0
        end
        if id_two.time_limit > 0 and data_2 and data_2 >= id_two.time_limit then
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

--周礼包
function M:get_gift_week_cfg()
    local gift_week_tab = ConfigManager:getCfgByName("gift_week")
    local vsn = self.m_supervalu_data.version or 1
    local vsn_gift_week_tab = gift_week_tab[vsn] or {}
    local new_tab = {}
    for k,v in pairs(vsn_gift_week_tab) do
        local cfg = table.copy(v) 
        if self:checkStageLimit(cfg) == true then
            cfg.id = k
            table.insert( new_tab, cfg)
        end
    end
    local function sortFunc(id_one, id_two)
        local data_1 = self:getBagComData(id_one.id) 
        local data_2 = self:getBagComData(id_two.id)
        local time1 = 1
        local time2 = 1
        if id_one.time_limit > 0 and data_1 and data_1 >= id_one.time_limit then
            time1 = 0
        end
        if id_two.time_limit >  0 and data_2 and data_2 >= id_two.time_limit then
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

--月礼包
function M:get_gift_month_cfg()
    local gift_month_tab = ConfigManager:getCfgByName("gift_month")
    local vsn = self.m_supervalu_data.version or 1
    local vsn_gift_month_tab = gift_month_tab[vsn] or {}
    local new_tab = {}
    for k,v in pairs(vsn_gift_month_tab) do
        local cfg = table.copy(v) 
        if self:checkStageLimit(cfg) == true then
            cfg.id = k
            table.insert( new_tab, cfg)
        end
    end
    local function sortFunc(id_one, id_two)
        local data_1 = self:getBagComData(id_one.id) 
        local data_2 = self:getBagComData(id_two.id)
        local time1 = 1
        local time2 = 1
        if id_one.time_limit > 0 and data_1 and data_1 >= id_one.time_limit then
            time1 = 0
        end
        if id_two.time_limit > 0 and data_2 and data_2 >= id_two.time_limit then
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

function M:getBagComData(id)
    return self.m_supervalu_data.detail[tostring(id)]
end

--检查时间
function M:readFestivalData(cfg)
    local cur_tim = UserDataManager:getServerTime()
    local star_tim = cfg.start_time
    local end_time = cfg.end_time
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    if #star_tim > 0 then
        local y, mon, d, h, min, s = star_tim:match(pattern)
        local e_y, e_mon, e_d, e_h, e_min, e_s = end_time:match(pattern)
        local timeChu = os.time({day=d, month=mon, year=y, hour=h, minute=min, second=s})
        local end_timeChu = os.time({day=e_d, month=e_mon, year=e_y, hour=e_h, minute=e_min, second=e_s})
        if cur_tim >= timeChu and cur_tim<= end_timeChu then
            return true
        end
    end
    return false
end

--检查关卡限制/vip限制
function M:checkStageLimit(cfg)
    local stage_id = UserDataManager:getCurStage()
    if cfg.stage and cfg.stage > 0 and stage_id < cfg.stage then
        return false
    end
    if cfg.stage_limit and next(cfg.stage_limit) ~= nil then
        if cfg.stage_limit[1] > stage_id or cfg.stage_limit[2] < stage_id then
            return false
        end
    end
    if cfg.vip and cfg.vip > 0 then
        return self.m_vip >= cfg.vip
    end
    return true
end


--元宝商店
function M:get_charge_cfg()
    local charge_tab = ConfigManager:getCfgByName("charge")
    local data = {}
    for k, v in pairs(charge_tab) do
        if v.sort == 0 then
            v.id = k
            table.insert(data, v)
        end
    end
    return data
end

--购买特惠礼包数据
function M:getBuyGiftOffData(version, id)
    if self.m_gift_off_data[tostring(version)] then
        for k,v in pairs(self.m_gift_off_data[tostring(version)].pays) do
            if id == v then
                return true
            end
        end
    end
    return false
end

--新手礼包配置数据
function M:get_gift_new_cfg(version)
    local gift_new_tab = ConfigManager:getCfgByName("gift_new")
    local version_tab = gift_new_tab[version]
    local new_tab = {}
    for k,v in pairs(version_tab) do
        v.id = k
        new_tab[k] = v
    end
    local function sortFunc(id_one, id_two)
        local data_1 = self:getNewComerData(id_one.id) 
        local data_2 = self:getNewComerData(id_two.id)
        local time1 = 1
        local time2 = 1
        if id_one.time_limit > 0 and data_1 and data_1 >= id_one.time_limit then
            time1 = 0
        end
        if id_two.time_limit > 0 and data_2 and data_2 >= id_two.time_limit then
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

function M:getLadderByVsn(version)
    for i, v in pairs(self.m_ladder_data or {}) do
        if tonumber(v.version) == tonumber(version) then
            return v.data
        end
    end
    return {}
end

--阶梯礼包配置数据
function M:get_ladderGiftData(version, open_id)
    local new_tab = {}
    local giftData = {}
    local gift_value_tab = {}
    if open_id == 202 then
        giftData = self.m_ladder_data or {}
        gift_value_tab = ConfigManager:getCfgByName("gift_sale") or {}
    elseif open_id == 259 then
        giftData = self:getLadderByVsn(version)
        gift_value_tab = ConfigManager:getCfgByName("gift_mould") or {}
    else
        giftData = self.m_ladder_data or {}
        gift_value_tab = ConfigManager:getCfgByName("gift_value") or {}
    end
    local version_tab = gift_value_tab[version] or {}
    local pastRechargeMoneyCount = self.m_charge_sum
    for index, data in pairs(giftData) do
        index = tonumber(index)
        local xlsxSeatGiftDatas = version_tab[index] or {}
        local cid = data.cid
        local curGiftData = xlsxSeatGiftDatas[cid]
        if curGiftData then
            -- 限购次数，VIP等级，累计金额，章节限制，章节范围限制
            local isCanBuy = true
            cid, isCanBuy = self:trimEveryDayLadderBagData(curGiftData, data, pastRechargeMoneyCount)
            -- <=0, 表示第一个礼包，第一个礼包不符合购买需求则隐藏礼包
            if cid > 0 then
                curGiftData = xlsxSeatGiftDatas[cid]
                table.insert(new_tab,{
                    xlsxData = curGiftData,
                    cid = data.cid,
                    buyCount = data.times,
                    isCanBuy = isCanBuy,
                    index = index,
                })
            end
        end
    end
    
    table.sort(new_tab,function(itemData1,itemData2)  
        local canBuyIndex1 = itemData1.isCanBuy and 1 or 2
        local canBuyIndex2 = itemData2.isCanBuy and 1 or 2
        if canBuyIndex1 ~= canBuyIndex2 then
            return canBuyIndex1 < canBuyIndex2
        else
            return itemData1.index < itemData2.index
        end
    end)
    
    return new_tab
end

--每日阶梯, 每周阶梯礼包配置数据
function M:get_everyDayLadderGiftData(version, open_Id)
    local isEveryDayBag = self:isEveryDayLadderGifBag(open_Id)
    local giftBagCfgName = isEveryDayBag and "gift_day" or "gift_package"
    local gift_value_tab = ConfigManager:getCfgByName(giftBagCfgName)
    local version_tab = gift_value_tab[version] or {}
    local new_tab = {}
    local giftData = isEveryDayBag and self.m_everyDay_ladder_data or self.m_everyWeek_ladder_data
    local pastRechargeMoneyCount = isEveryDayBag and self.m_everyDay_charge_sum or self.m_everyWeek_charge_sum
    for index, data in pairs(giftData) do
        index = tonumber(index)
        local xlsxSeatGiftDatas = version_tab[index] or {}
        local cid = data.cid
        local curGiftData = xlsxSeatGiftDatas[cid]
        if curGiftData then
            -- 限购次数，VIP等级，累计金额，章节限制，章节范围限制
            local isCanBuy = true
            cid, isCanBuy = self:trimEveryDayLadderBagData(curGiftData, data, pastRechargeMoneyCount)
            -- <=0, 表示第一个礼包，第一个礼包不符合购买需求则隐藏礼包
            if cid > 0 then
                curGiftData = xlsxSeatGiftDatas[cid]
                table.insert(new_tab, {
                    xlsxData = curGiftData,
                    cid = data.cid,
                    buyCount = data.times,
                    isCanBuy = isCanBuy,
                    index = index,
                    isSpecialPlace = false,
                })
            end
        end
    end
    if self.m_ladder_recommend_data and table.nums(self.m_ladder_recommend_data) > 0 then
        index = tonumber(self.m_ladder_recommend_data.pos)
        local xlsxSeatGiftDatas = version_tab[index] or {}
        local cid = self.m_ladder_recommend_data.cid
        local curGiftData = xlsxSeatGiftDatas[cid]
        if curGiftData then
            -- 限购次数，VIP等级，累计金额，章节限制，章节范围限制
            local isCanBuy = true
            cid, isCanBuy = self:trimEveryDayLadderBagData(curGiftData, self.m_ladder_recommend_data, pastRechargeMoneyCount)
            -- <=0, 表示第一个礼包，第一个礼包不符合购买需求则隐藏礼包
            if cid > 0 then
                curGiftData = xlsxSeatGiftDatas[cid]
                table.insert(new_tab, {
                    xlsxData = curGiftData,
                    cid = self.m_ladder_recommend_data.cid,
                    buyCount = self.m_ladder_recommend_data.times,
                    isCanBuy = isCanBuy,
                    index = index,
                    isSpecialPlace = true,
                })
            end
        end
    end
    table.sort(new_tab,function(itemData1,itemData2)
        local special1 = itemData1.isSpecialPlace and 1 or -1
        local special2 = itemData2.isSpecialPlace and 1 or -1
        local canBuyIndex1 = itemData1.isCanBuy and 1 or 2
        local canBuyIndex2 = itemData2.isCanBuy and 1 or 2
        if canBuyIndex1 ~= canBuyIndex2 then
            return canBuyIndex1 < canBuyIndex2
        else
            if special1 ~= special2 then
                return special1 < special2
            else
                return itemData1.index < itemData2.index
            end
        end
    end)
    return new_tab
end

-- 修改阶梯礼包数据，判断规则：限购次数，VIP等级，累计金额，章节限制，章节范围限制
function M:trimEveryDayLadderBagData(curGiftData, data, pastRechargeMoneyCount)
    local cid = data.cid
    local isCanBuy = true
    if (curGiftData.time_limit > 0) then
        isCanBuy = data.times < curGiftData.time_limit
    end
    local userDataManager = UserDataManager
    local curVipLevel = userDataManager.user_data:getUserStatusDataByKey("vip")
    if isCanBuy and (curGiftData.vip > 0) then
        isCanBuy = curVipLevel >= curGiftData.vip
    end
    if isCanBuy and (curGiftData.add_recharge > 0) then
        isCanBuy = pastRechargeMoneyCount >= curGiftData.add_recharge
    end
    local curChapterId = userDataManager:getCurStage()
    if isCanBuy and (curGiftData.stage > 0) then
        isCanBuy = curChapterId >= curGiftData.stage
    end
    if isCanBuy and curGiftData.stage_limit and #curGiftData.stage_limit > 0 then
        local chapterLimit = curGiftData.stage_limit
        isCanBuy = curChapterId >= chapterLimit[1] and curChapterId <= chapterLimit[2]
    end
    cid = isCanBuy and cid or (cid - 1)
    -- 1. 只有一层，买完后要显示已售罄
    -- 2. 只有一层，不符合条件要隐藏
    if cid <= 0 then
        cid = (data.times <= 0) and 0 or 1  --times 买没买过
    end
    return cid, isCanBuy
end

-- 推荐页指定cid的每日，每周阶梯礼包数据整理
function M:trimReCommendEveryWeekLadderBagData(version, cid, posIndex, residueCount,pastRechargeMoneyCount, openId)
    -- 201每周，200每日
    local cfgName = self:isEveryDayLadderGifBag(openId) and "gift_day" or "gift_package" 
    local gift_value_tab = ConfigManager:getCfgByName(cfgName)
    local version_tab = gift_value_tab[version] or {}
    local xlsxSeatGiftDatas = version_tab[posIndex] or {}
    local curGiftData = xlsxSeatGiftDatas[cid]
    if curGiftData then
        -- 限购次数，VIP等级，累计金额，章节限制，章节范围限制
        local isCanBuy = true
        cid, isCanBuy = self:trimEveryDayLadderBagData(curGiftData, {cid = cid, times = residueCount}, pastRechargeMoneyCount)
        -- <=0, 表示第一个礼包，推荐页是服务器发的可买的礼包，出现这种情况说明服务器推的有问题
        if cid > 0 then
            curGiftData = xlsxSeatGiftDatas[cid]
            return {
                xlsxData = curGiftData,
                cid = cid,
                buyCount = residueCount,
                isCanBuy = isCanBuy,
            }
        end
    end
    return nil
end

-- 不是每日阶梯礼包就是每周阶梯礼包
function M:isEveryDayLadderGifBag(open_Id)
    return (open_Id == 200)
end

--每日特惠配置数据
function M:get_gift_off_cfg(id)
    local gift_off_tab = ConfigManager:getCfgByName("gift_off")
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    local version = 1
    if active_tab[id] then 
        version = active_tab[id].version
    end
    local new_tab = {}
    if gift_off_tab[version or 1] == nil then 
        return new_tab
    end
    for k,v in pairs(gift_off_tab[version or 1]) do
        v.id = k
        table.insert( new_tab,v)
    end
    local function sortFunc(id_one, id_two)
        return id_one.id < id_two.id
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

--连续充值配置数据
function M:get_gontinuous_cfg()
    local recharge_tab = ConfigManager:getCfgByName("last_recharge")
    if self.m_continuous_data == nil then
        return
    end
    local new_tab = {}
    local server_tab = table.copy(self.m_continuous_data.config)
    for k,v in pairs(server_tab) do
        local version_tab = recharge_tab[self.m_continuous_data.version]
        local cfg = version_tab[tonumber(k)]
        cfg.id = tonumber(k)
        cfg.server_reward = v.reward
        table.insert(new_tab,cfg)
    end
    local function sortFunc(id_one, id_two)
        return id_one.id < id_two.id
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

--皮肤礼包配置数据
function M:get_skip_cfg()
    local skip_gift_tab = ConfigManager:getCfgByName("skin_gift")
    local version = self.m_skin_gift_data.version or 1
    local new_tab = table.copy(skip_gift_tab[version])
    for k,v in pairs(new_tab) do
        local num = self:getActivityGiftData(k)
        v.id = k
    end
    local function sortFunc(id_one, id_two)
        local data_one = self:getActivityGiftData(id_one.id) >= id_one.time_limit and 1 or 0
        local data_two = self:getActivityGiftData(id_two.id) >= id_two.time_limit and 1 or 0
        if data_one == data_two then
            return id_one.id < id_two.id
        else
            return data_one < data_two
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

--获得皮肤礼包配置数据
function M:getSkipCfgById(id)
    local skip_gift_tab = ConfigManager:getCfgByName("skin_gift")
    local version = self.m_skin_gift_data.version or 1
    local new_tab = table.copy(skip_gift_tab[version])
    return new_tab[id] or {}
end

--单笔充值奖励配置
function M:getGiftNewCfgById(version, id)
    local gift_tab = ConfigManager:getCfgByName("gift_new")
    local new_tab = gift_tab[version]
    if new_tab == nil then
        return {}
    end
    return new_tab[id] or {}
end

--私人定制礼包
function M:get_custom_made_cfg(verson)
    local custom_gift_tab = ConfigManager:getCfgByName("custom_gift")
    local version_tab = custom_gift_tab[verson or 1]
    local m_season = UserDataManager:getCurSeason()
    local new_tab = {}
    local m_vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
    for k,v in pairs(version_tab) do
        local can_vip = false 
        if v.vip and v.vip > 0 then 
            can_vip = m_vip >= v.vip
        else
            can_vip = true  
        end
        local can_season = false
        if v.season and v.season > 0 then --大于等于该赛季
            can_season = m_season >= v.season
        else
            can_season = true  
        end
        local can_season1 = false
        if v.season1 and v.season1 >= 0 then --等于该赛季
            can_season1 = m_season == v.season1
        else
            can_season1 = true  
        end
        if can_vip == true and can_season == true and can_season1 == true then 
            local data = v
            data.id = k
            table.insert(new_tab, data)
        end
    end

    -- local custom_tab = table.copy(custom_gift_tab[verson or 1])
    -- for k,v in pairs(custom_tab) do
    --     v.id = k
    -- end
    local function sortFunc(id_one, id_two)
        local custim_data1 = self:getCustomGiftData(verson, id_one.id)
        local custim_data2 = self:getCustomGiftData(verson, id_two.id)
        local num_1 = 1 
        if custim_data1 and id_one.times_limit - custim_data1.times <= 0 then
            num_1 = 0
        end
        local num_2 = 1
        if custim_data2 and id_two.times_limit - custim_data2.times <= 0 then
            num_2 = 0
        end
        if num_1 == num_2 then
            return id_one.id < id_two.id
        else
            return num_1 > num_2  
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

--英雄成长礼包
function M:get_grow_up_cfg(verson)
    local hero_gift_show_tab = ConfigManager:getCfgByName("hero_gift_show")
    local hero_gift_tab = ConfigManager:getCfgByName("hero_gift")
    local gift_tab = table.copy(hero_gift_tab[verson or 1]) or {}
    if gift_tab then
        for k,v in pairs(gift_tab) do
            v.id = k
        end
    end
    return hero_gift_show_tab[verson or 1], gift_tab
end

--成长礼包
function M:getGrowUpRewardData(version, id)
    if self.m_hero_gift_data == nil then
        return
    end
    local data = self.m_hero_gift_data[tostring(version)]
    local free_get = false
    if data and next(data) ~= nil then
        for k,v in pairs(data.free) do
            if id == v then
                free_get = true
            end
        end
        return free_get, data.pay[tostring(id)] or 0
    end
    return free_get, 0
end


--神兵成长礼包
function M:get_equip_grow_up_cfg(verson)
    local equip_gift_show_tab = ConfigManager:getCfgByName("equip_gift_show")
    local equip_gift_tab = ConfigManager:getCfgByName("equip_gift")
    local gift_tab = table.copy(equip_gift_tab[verson or 1])
    for k,v in pairs(gift_tab) do
        v.id = k
    end
    return equip_gift_show_tab[verson or 1], gift_tab
end

--神兵成长礼包
function M:geEquiptGrowUpRewardData(version, id)
    if self.m_equip_gift_data == nil then
        return
    end
    local data = self.m_equip_gift_data[tostring(version)]
    local free_get = false
    if data and next(data) ~= nil then
        for k,v in pairs(data.free) do
            if id == v then
                free_get = true
            end
        end
        return free_get, data.pay[tostring(id)] or 0
    end
    return free_get, 0
end

--多期通用成长礼包
function M:get_common_grow_up_cfg(version)
    local growth_gift_show_tab = ConfigManager:getCfgByName("growth_gift_show")
    local growth_gift_tab = ConfigManager:getCfgByName("growth_gift")
    local gift_tab = table.copy(growth_gift_tab[version or 1])
    for k,v in pairs(gift_tab) do
        v.id = k
    end
    return growth_gift_show_tab[version or 1], gift_tab
end

--多期通用成长礼包
function M:geCommonGrowUpRewardData(version, id)
    if self.m_growth_gift_data == nil then
        return
    end
    local data = self.m_growth_gift_data[tostring(version)]
    local free_get = false
    if data and next(data) ~= nil then
        for k,v in pairs(data.free) do
            if id == v then
                free_get = true
            end
        end
        return free_get, data.pay[tostring(id)] or 0
    end
    return free_get, 0
end

--定制礼包数据
function M:getCustomGiftData(version, id, index)
    local gift_tab = self.m_custom_data[tostring(version)] or {}
    return gift_tab[tostring(id)]
end

function M:getActiveData(actives, open_id)
    for k,v in pairs(actives) do
        if v.open_status > 0 then
            return v
        end
    end
    return nil
end

function M:getNewComerData(id)
    for i,v in pairs(self.m_gift_new_data) do
        if i == tostring(id) then
            return v
        end
    end
    return 0   
end

function M:checkNewWelfareGet()
    if self.m_bright_data == nil then
        return false
    end
    for k,v in pairs(self.m_bright_data.bless_received) do
        if self.m_bright_data.version == v then
            return true
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
    return {}
end

function M:canReceiveContinuous(index)
    local data = self:getRechargeById(index)
    if data then
        return data.status
    else
        return 0    
    end
end

function M:getContinuousItems(index)
    local  rech_tab = self:get_gontinuous_cfg()
    return rech_tab[index]
end

--累计充值
function M:get_recharge_cfg(verson)
    if self.m_cmlt_recharge_data == nil then
        return {}
    end
    local add_recharge_tab = ConfigManager:getCfgByName("add_recharge")
    local server_tab = self.m_cmlt_recharge_data.reward_config
    local version_tab = table.copy(add_recharge_tab[self.m_cmlt_recharge_data.version or 1])
    local new_tab = {}
    for k,v in pairs(server_tab) do
        local cfg = version_tab[tonumber(k)]
        cfg.id = tonumber(k)
        cfg.server_reward = v
        table.insert(new_tab, cfg)
    end
    local function sortFunc(id_one, id_two)
        local data_one = self:getCmltReceived(id_one.id) == true and 1 or 0
        local data_two = self:getCmltReceived(id_two.id) == true and 1 or 0
        if data_one == data_two then
            return id_one.id < id_two.id
        else
            return data_one < data_two
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

function M:getCmltReceived(id)
    if self.m_cmlt_recharge_data then
        for k,v in pairs(self.m_cmlt_recharge_data.received) do
            if id == v then
                return true
            end
        end
        return false
    end
    return false
end

--限时礼包
function M:get_limit_cfg(version, id)
    if self.m_limit_data == nil or self.m_limit_data.activity_limit == nil then
        return {}
    end
    local vip = UserDataManager.user_data:getUserStatusDataByKey("vip")
    local limit_tab = ConfigManager:getCfgByName("activity_limit")
    local limit_data = self.m_limit_data.activity_limit[tostring(version)]
    local exchange_reward_tab = ConfigManager:getCfgByName("exchange_reward")
    if limit_data == nil then
        return {}
    end
    local server_tab = limit_tab[version]
    local version_tab = limit_tab[version or 1]
    local new_tab = {}
    for k,v in pairs(server_tab) do
        local cfg = version_tab[tonumber(k)]
        cfg.id = tonumber(k)
        cfg.server_reward = v.reward
        
        if cfg.exchange > 0 and cfg.exchange_reward > 0 and UserDataManager.m_exchange_vsn > 0 then
            local ex_ver_tab = exchange_reward_tab[UserDataManager.m_exchange_vsn]
            if ex_ver_tab then
                local ex_cfg = ex_ver_tab[cfg.exchange_reward]
                if ex_cfg then
                    for i = 1, #ex_cfg.reward do
                        table.insert(cfg.server_reward, 4,ex_cfg.reward[i])
                    end
                end
            end
        end
        if cfg.vip then
            if vip >= cfg.vip then
                table.insert(new_tab, cfg)
            end
        else
            table.insert(new_tab, cfg)
        end
    end
    local function sortFunc(id_one, id_two)
        local data_one = 0
        if id_one.time_limit > 0 then
            data_one = self:getLimitData(version, id_one.id) >= id_one.time_limit and 1 or 0
        else
            data_one = id_one.time_limit
        end
        local data_two = 0
        if id_two.time_limit > 0 then
            data_two = self:getLimitData(version, id_two.id) >= id_two.time_limit and 1 or 0
        else
            data_two =  id_two.time_limit   
        end
        if data_one == data_two then
            return id_one.id < id_two.id
        else
            return data_one < data_two
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

function M:getLimitData(version,id)
    if self.m_limit_data and self.m_limit_data.activity_limit then
        local limit_data = self.m_limit_data.activity_limit[tostring(version)]
        return limit_data.detail[tostring(id)] or 0
    else
        return 0  
    end
end

function M:getActiveEndTime(actives, id)
    if actives == nil then
        return -1
    end
    for k,v in pairs(actives) do
        if v.open_status > 0 then
            if id then
                if v.id == id then
                    return v.end_ts
                end
            else
                return v.end_ts
            end 
        end
    end
    return -1
end

--获取比较接近的一个结束时间 **累计充值多期、选择近的
function M:getActiveNearEndTime(actives)
    if actives == nil then
        return -1
    end
    local end_ts = -1
    for k,v in pairs(actives) do
        if v.open_status > 0 then
            if end_ts == -1 then
                end_ts = v.end_ts
            else
                if v.end_ts < end_ts then
                    end_ts = v.end_ts
                end
            end
        end
    end
    return end_ts
end

function M:getActivityGiftData(id)
    if self.m_skin_gift_data ~= nil then
        return self.m_skin_gift_data.activity_log[tostring(id)] or 0
    end
    return 0
end

--成长礼包下一个可领的
function M:getGrowUpCanGetReward(version, evo)
    local hero_show_tab, gift_tab = self:get_grow_up_cfg(version)
    for i = 1, #gift_tab do
        local cell_data = gift_tab[i]
        local free_get, pay_num = self:getGrowUpRewardData(version, i)
        local can_get = evo >= cell_data.quality 
        if can_get == true then
            local pay_get = false
            if (cell_data.time - pay_num) > 0 then
                pay_get = true
            else
                pay_get = false    
            end
            if free_get == false or pay_get == true then
                return i
            end
        else
            return i    
        end
    end
    return 1
end

--装备成长礼包下一个可领的
function M:getEquipGrowUpCanGetReward(version)
    local hero_show_tab, gift_tab = self:get_equip_grow_up_cfg(version)
    for i = 1, #gift_tab do
        local cell_data = gift_tab[i]
        local free_get, pay_num = self:geEquiptGrowUpRewardData(version, i)
        local hv_num = self.m_equip_quality_num[tostring(cell_data.quality)] or 0
        local can_get = hv_num >= cell_data.num
        if can_get == true then
            local pay_get = false
            if (cell_data.time - pay_num) > 0 then
                pay_get = true
            else
                pay_get = false    
            end
            if free_get == false or pay_get == true then
                return i
            end
        else
            return i    
        end
    end
    return 1
end

--装备是否可领
function M:checkEquipCanGet(quality, num)
    local num = num or 1
    if num == 1 then
        for k,v in pairs(self.m_equip_quality_num) do
            if tonumber(k) >= quality then
                return true
            end 
        end
    else
        local hv_num = 0
        for k,v in pairs(self.m_equip_quality_num) do
            if tonumber(k) >= quality then
                hv_num = hv_num + v
            end 
        end
        return hv_num >= num
    end
    return false
end

--天命化星成长礼包下一个可领的
function M:getStarGrowUpCanGetReward(version)
    local hero_show_tab, gift_tab = self:get_common_grow_up_cfg(version)
    for i = 1, #gift_tab do
        local cell_data = gift_tab[i]
        local free_get, pay_num = self:geCommonGrowUpRewardData(version, i)
        local num = UserDataManager:getHeroCountByQuality(cell_data.quality)
        local can_get = num >= cell_data.num
        if can_get == true then
            local pay_get = false
            if (cell_data.time - pay_num) > 0 then
                pay_get = true
            else
                pay_get = false
            end
            if free_get == false or pay_get == true then
                return i
            end
        else
            return i
        end
    end
    return 1
end
-- 检查是否满足天命化星礼包领取条件
function M:checkCanGetGrowUpReward(show_type, quality, needNum)
    local can_get = false
    if show_type == 3 then
        local num = UserDataManager:getHeroCountByQuality(quality)
        can_get = num >= needNum
    elseif show_type == 4 then
        local num = UserDataManager:getHeroFatesNum()
        can_get = num >= needNum
    elseif show_type == 5 then
        local num = UserDataManager:getHeroSigDeepNum(quality)
        can_get = num >= needNum
    end
    return can_get
end

--是否还有双倍首充
function M:getDiamondData(id)
    for i,v in pairs(self.m_charge_data.double_pay) do
        if id == v then
            return true
        end
    end
    return false
end

function M:checkActiveCfgByOpenId(open_id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    for k,v in pairs(self.m_data.actives) do
        for kk,vv in pairs(v.actives) do
            if vv and vv.open_status > 0 then
                local c_cfg = active_tab[v.id]
                if c_cfg and open_id == c_cfg.open_id then
                    return c_cfg
                end
            end
        end
    end
    return nil
end

function M:getActivesById(id)
    for k,v in pairs(self.m_net_actives) do
        if v.id == id then
            return v
        end
    end    
end

function M:getActiveCfg(actives, id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    if actives and next(actives) then
        for k,v in pairs(actives) do
            if v.open_status > 0 then
                if id then
                    if v.id == id then
                        return active_tab[v.id]
                    end
                else
                    return active_tab[v.id]
                end
              
            end
        end
    end
    return nil
end

function M:checkActiveIsEnd(end_ts)
    return end_ts > UserDataManager:getServerTime()
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
    -- if data and data.actives then
    --     self:updateActivesData(data.actives)
    -- end
    if tag == "skin_gift_index" then
        self.m_skin_gift_data = data --锦囊礼包数据
    elseif tag == "activity_limit_index"  then --限时礼包
        self.m_limit_data = data
    elseif tag == "merchant_index" then
        self.m_war_merchant_data = data --普通商船数据
    elseif tag == "continuous_index" then
        --连续充值
        self.m_continuous_data = data.continuous_payment
    elseif tag == "gift_off_index" then
        --特惠礼包
        self.m_gift_off_data = data.gift_off
        self.m_gift_off_actives = data.actives
    elseif tag == "gift_new_index" then
        self.m_net_actives = data.actives
        --新手礼包
        self.m_gift_new_data = data.gift_new
    elseif tag == "gift_supervalue_index" then
        self.m_net_actives = data.actives
        --超值礼包
        self.m_supervalu_data = data.gift_data
    elseif (tag == "gift_value_index") or (tag == "gift_value_limit_index") or (tag == "gift_mould_index") then  
        --阶梯礼包
        self.m_ladder_actives = data.actives
        self.m_ladder_data = data.data
        self.m_charge_sum = data.charge_sum
    elseif tag == "gift_value_daily_index" then
        --每日阶梯礼包
        self.m_everyDay_ladder_actives = data.actives
        self.m_everyDay_ladder_data = data.data
        self.m_everyDay_charge_sum = data.charge_sum
        -- 新增的每日阶梯礼包推荐礼包
        self.m_ladder_recommend_data = data.recommend or nil
    elseif tag == "gift_value_week_index" then
        --每周阶梯礼包
        self.m_everyWeek_ladder_actives = data.actives
        self.m_everyWeek_ladder_data = data.data
        self.m_everyWeek_charge_sum = data.charge_sum
        self.m_ladder_recommend_data = nil
    elseif tag == "pay_shop_index" then
        self.m_charge_data = data
    elseif tag == "bright_bless_index" then --新手福利
        self.m_bright_data = data    
        self.m_skin_gift_data = data.skin_gift or {}
    elseif tag == "cmlt_recharge_index" then --累计充值
        self.m_cmlt_actives= data.actives
        self.m_cmlt_recharge_data = data.cmlt_recharge  
    elseif tag == "custom_gift_index" then --定制礼包
        self.m_custom_data = data.custom_gift
        self.m_custom_actives = data.actives
    elseif tag == "hero_gift_index" then --英雄成长礼包
        self.m_hero_gift_data = data.gifts_detail
        self.m_hero_gift_actives= data.actives
    elseif tag == "equip_gift_index" then--神兵成长礼包
        self.m_equip_gift_data = data.gifts_detail
        self.m_equip_gift_actives = data.actives 
        self.m_equip_quality_num = data.equip_quality_num
    elseif tag == "growth_gift_index" then  --英雄成长礼包数据
        self.m_growth_gift_data = data.gifts_detail
        self.m_growth_gift_actives= data.actives
    elseif tag == "user_payment_recommend_index" then --    推荐页
        self.m_recommend_data = data 
    end
end

function M:updateActivesData(actives)
    for k,v in pairs(actives) do
        if self:getHaveById(v.id) then
            for kk,vv in pairs(self.actives) do
                if v.id == vv.id then
                    vv = v
                end 
            end
        else
            self:removeOverActives(v.id)
            table.insert(self.actives, v)
            self.tag_table = self:getTagTabs(149)
        end
    end
end

function M:getHaveById(id)
    for k,v in pairs(self.actives) do
        if v.id == id then
            return true
        end
    end    
    return false
end

function M:removeOverActives(id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    local active_cfg = active_tab[id]
    if active_cfg then
        for k,v in pairs(self.actives) do
            local cfg = active_tab[v.id]
            if cfg.open_id == active_cfg.open_id and v.end_ts < UserDataManager:getServerTime() then
                v.open_status = -1
            end
        end
    end
end

--删除已结束的活动页签
--（新手礼包活动，领取完最后一个奖励后，后端会清除领取数据缓存，这种情况下，前端显示的最后一个奖励依旧为未领取状态，在活动关闭情况下，清楚该活动页签open_id，让该活动消失）
function M:deletActive(open_id)
    for i, v in ipairs(self.tag_table) do
        if v.open_id == open_id then
            table.remove(self.tag_table,i)
        end
    end
end

return M
