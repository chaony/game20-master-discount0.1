---@class OperateActivityModel:OODataBase
local M = class("OperateActivityModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("active_enter")
end

function M:onEnter()
    self.m_war_older_actives = {}
    self.m_war_older_data = {}
    self.m_month_card_data = {}
    self.m_fund_data = {}
    self.m_sign_daily_data = {}
    self.m_tiktok_data = {}
    --------------------------
    self.m_net_actives = {}
    self.rechare_actives = self.m_params.actives
    local select_open_id = self.m_params.open_id or 0
    self.is_refresh_bl = false
    self.m_sel_tab_index = 1 --一级页签
    self.m_sel_tab_index2 = 1 --二级页签
    self.tag_table = self:getShowActive()
    self:refreshDataTime()
    if select_open_id == -1 then --代金券进入
        self.is_tokens = true
    else
        self.is_tokens = false    
    end
    if select_open_id > 0 then
        for k, v in pairs(self.tag_table) do
            local tab_buttons = self:getTagTabs(v)
            if next(tab_buttons) ~= nil then
                for kk,vv in pairs(tab_buttons) do
                    if vv.open_id == select_open_id then
                        self.m_sel_tab_index = k
                        self.m_sel_tab_index2 = kk
                    end
                end
            else
                if v == select_open_id then
                    self.m_sel_tab_index = k
                end
            end
        end
    end
    self:dayCompute()
end


--刷新接口请求
function M:refreshData(call_back)
    local function callFunc(data)
        if data then
            table.merge(self.m_data,data)
            self.tag_table = self:getShowActive()
            self:refreshDataTime()
            self:dayCompute()
            call_back()
        end
    end
    self:getNetData("active_enter",nil,callFunc,nil,true)
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
            if vv and vv.open_status > 0 then
                if vv.open_id == open_id then
                    bl = true    
                elseif (open_id == 137 or open_id == 85 or open_id == 5000) and (vv.open_id == 85 or vv.open_id == 143 or vv.open_id == 144 or vv.open_id >= 5000)  then --成长基金、签到基金合并到一起
                    bl = true 
                end
            end
        end
        if bl == true then
            if url_name == "war_order_valor_index" or url_name == "war_order_index" or url_name == "war_goal_common_index" then
                self.m_war_older_actives = v.actives[1]
                self:setWarOlderData(v)
            elseif url_name == "month_card" then
                --月卡数据
                self.m_month_card_data = v 
            elseif url_name == "fund_index" then
                self.m_fund_data = v --成长基金数据
            elseif url_name == "sign_daily_index" then
                self.m_sign_daily_data = v or {} --签到 
            elseif url_name == "tiktok_data" then
                if v and v.tiktok_record then
                    self.m_tiktok_data = v.tiktok_record
                else
                    self.m_tiktok_data = {}
                end
            end
        end
    end
end

function M:refreshActiveEnd()
    local data = self.tag_table[self.m_sel_tab_index]
    local tab_buttons = self:getTagTabs(data)
    if next(tab_buttons) ~= nil and #tab_buttons > 0 then
        if self.m_sel_tab_index2 > 1 then
            self.m_sel_tab_index2 = self.m_sel_tab_index2 - 1
        end
        if self.m_sel_tab_index2 > #tab_buttons then
            self.m_sel_tab_index2 = #tab_buttons
        end
    else
         if self.m_sel_tab_index > 1 then
            self.m_sel_tab_index = self.m_sel_tab_index - 1
         end
    end
    self.tag_table = self:getShowActive()
    self:dayCompute()
end

function M:getActivesById(id)
    for k,v in pairs(self.m_net_actives) do
        if v.id == id then
            return v
        end
    end    
end

--当前活动已经结束、移除掉
function M:removeCurActives()
    local data = self.tag_table[self.m_sel_tab_index]
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    local tab_buttons = self:getTagTabs(data)
    local remove_open_id = data
    local remove_id = 0
    if next(tab_buttons) ~= nil then
        local tag_data = tab_buttons[self.m_sel_tab_index2]
        remove_open_id = tag_data.open_id
        remove_id = tag_data.id
    end 
    if remove_id and remove_id > 0 then
        for k,v in pairs(UserDataManager.m_active_recharge) do
            if v.open_status > 0 and v.id > remove_id then
                v.open_status = -1
                break
            end
        end
    elseif remove_open_id > 0 then
        for k,v in pairs(UserDataManager.m_active_recharge) do
            if v.open_status > 0 then
                local c_cfg = active_tab[v.id]
                if c_cfg.open_id == remove_open_id then
                    v.open_status = -1
                    break
                end
            end
        end
    end
end

--检查界面开启的活动按钮
function M:getShowActive()
    local opne_tab = ConfigManager:getCfgByName("open_condition")
    local active_tab = opne_tab[88]
    local temp_tab = table.copy(active_tab.buttons)
    local remove_tab = {}
    for i,v in pairs(temp_tab) do
        if self:checkHaveActive(v) == false then
            remove_tab[i] = true
        end
    end
    for i = #temp_tab, 1,-1 do
        if remove_tab[i] == true then
            table.remove(temp_tab, i)
        end
    end
    return temp_tab
end

--检查是否开启当前活动
function M:checkHaveActive(open_id)
    if open_id == 176 then
        local chn = ""
        for k,v in pairs(UserDataManager.server_data.all_server_data) do
            chn = v.ChannelID
            break
        end

        if chn ~= "bsdk" then
            return false
        end
    -- elseif open_id == 145 then     
    --     return true
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

function M:checkActiveCfgByOpenId(open_id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    for k,v in pairs(self.m_data.actives) do
        for kk,vv in pairs(v) do
            if open_id == vv.open_id then
                local c_cfg = active_tab[vv.id]
                return c_cfg
            end
        end
    end
    return nil
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
            if self:checkHaveActive(v) == false then
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
        new_tab[i] = {open_id = temp_tab[i]}
    end
    for k,v in pairs(temp_tab) do
        local actives = self:checkHaveMoreActive(v)
        if #actives > 1 then
            for i = 2, #actives do
                table.insert(new_tab, k, {open_id = v})
            end
            for kk,vv in pairs(actives) do
                for k1,v1 in pairs(new_tab) do
                    if v == v1.open_id and v1.id == nil then
                        v1.id = vv
                        break
                    end
                end
            end
        elseif #actives == 1 then 
            for kk,vv in pairs(actives) do
                for k1,v1 in pairs(new_tab) do
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

--检查是否开启多个相同活动
function M:checkHaveMoreActive(open_id)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    local actives = {}
    -- for k,v in pairs(self.rechare_actives) do
    --     if v.open_status > 0 then
    --         local c_cfg = active_tab[v.id]
    --         if open_id == c_cfg.open_id then
    --             table.insert(actives, v.id)
    --         end
    --     end
    -- end
    for k,v in pairs(self.m_data.actives) do
        if v.open_id == open_id then
            local c_cfg = active_tab[v.id]
            table.insert(actives, v.id)
        end
    end
    return actives
end

function M:initData(url, call_back, data)
    self:getNetData(url, data, call_back)
end

function M:dayCompute()
    local reg_ts = UserDataManager.reg_ts
    local server_ts = UserDataManager:getServerTime()
    local ms = server_ts - reg_ts
    local day = GameUtil:NumberOfDaysInterval(server_ts, reg_ts, 0)
    self.m_day = day + 1
end

function M:getDayDiff(tim_ts)
    local server_ts = UserDataManager:getServerTime()
    local day = GameUtil:NumberOfDaysInterval(tim_ts, server_ts, 0)
    return GameUtil:formatNum(day + 1)
end


function M:FindDuplicate(tab, sort)
    for k,v in pairs(tab) do
        if tab.sort == sort then
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

function M:getHeroById(id)
    return UserDataManager.hero_data:getHeroConfigByCid(id)    
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


--
function M:getBagComData(id)
    return self.m_supervalu_data[tostring(id)]
end

function M:getLimitData(version,id)
    if self.m_limit_data and self.m_limit_data.activity_limit then
        local limit_data = self.m_limit_data.activity_limit[tostring(version)]
        return limit_data.detail[tostring(id)] or 0
    else
        return 0  
    end
end

function M:getNewComerData(id)
    for i,v in pairs(self.m_gift_new_data) do
        if i == tostring(id) then
            return v
        end
    end
    return 0   
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

--领取特惠礼包数据
function M:getGiftOffData(id)
    for k,v in pairs(self.m_gift_off_data.gifts) do
        if id == v then
            return true
        end
    end
    return false
end

--购买特惠礼包数据
function M:getBuyGiftOffData(id)
    for k,v in pairs(self.m_gift_off_data.pays) do
        if id == v then
            return true
        end
    end
    return false
end

function M:checkIsOpen(index)
    if self.m_war_older_data.end_ts and self.m_war_older_data.end_ts > 0 then
        return true
    else
        return false
    end
end

--基金开启
function M:getFundOpen()
    if self.m_fund_data == nil then
        return false
    end
    return self.m_fund_data.fund_status == 0
end

function M:getFundData(id)
    if self.m_fund_data == nil or self.m_fund_data.fund_quests == nil then
        return nil
    end
    return self.m_fund_data.fund_quests[tostring(id)]
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

function M:getReceived(m_type, id)
    if self.m_war_older_data.free_received then
        for k, v in pairs(self.m_war_older_data.free_received) do
            if v == id then
                return true
            end
        end
        return false
    end
    return false
end

function M:getPayReceived(m_type, id)
    if self.m_war_older_data.pay_received then
        for k, v in pairs(self.m_war_older_data.pay_received) do
            if v == id then
                return true
            end
        end
        return false
    end
end



function M:getRoyalShowLv(id)
    local tab = self:get_royal_cfg(id)
    local c_lv = 1
    for i = 1, table.nums(tab) do
        local c_cfg = tab[i]
        if self.m_war_older_data.num and self.m_war_older_data.num >= c_cfg.condition then
            c_lv = i
        end
    end
    return c_lv
end



--战令进度
function M:getTokenSlider(id, lv)
    local tab = self:get_royal_cfg(id)
    local c_cfg = tab[lv]
    local n_cfg = tab[lv+1]
    if n_cfg then
        return (self.m_war_older_data.num - c_cfg.condition), (n_cfg.condition - c_cfg.condition)
    else
        return c_cfg.condition, c_cfg.condition
    end
end

--战令表
function M:get_war_order(index)
    local war_tab = ConfigManager:getCfgByName("war_order")
    return war_tab[index]
end

--武林行侠令配置数据
function M:get_royal_cfg(id)
    local tabName = "royal_reward"
    if id == 109 then
        tabName = "warrior_reward"
    elseif id == 452 then
        tabName = "hero_isle_reward"
    end
    local valor_tab = ConfigManager:getCfgByName(tabName)
    if self.m_war_older_data.lv == 0 then
        self.m_war_older_data.lv = 1
    end
    return valor_tab[self.m_war_older_data.lv or 1]
end


--战令奖励
function M:getAllReward(m_token_lv,id)
    id = id and id or 0
	local war_table = self:get_royal_cfg(id)
	local c_lv = m_token_lv > 0 and m_token_lv or 1
	local rewards = {}
	for i = 1, #war_table do
		local m_cfg = table.copy(war_table[i]) 
		if m_cfg then
			for k,v in pairs(m_cfg.fee_incentives) do
				if self:checkWarInTab(rewards, v) == true then
					self:checkInRewards(rewards, v)
				else	
					table.insert( rewards, v)
				end
			end
		end
	end
    local function sortFunc(id_one, id_two)
        local bl_1 = (id_one[1] == 101 or id_one[1] == 130) and 1 or 0
        local bl_2 = (id_two[1] == 101 or id_two[1] == 130) and 1 or 0
        return bl_1 > bl_2
    end
    table.sort(rewards, sortFunc)
	return rewards
end
--战令购买可领
function M:getCanHaveReward(m_token_lv,id)
    id = id and id or 0
    local war_table = self:get_royal_cfg(id)
	local c_lv = m_token_lv > 0 and m_token_lv or 1
	local rewards = {}
	for i = 1, m_token_lv do
		local m_cfg = table.copy(war_table[i])
		if m_cfg then
			for k,v in pairs(m_cfg.fee_incentives) do
				if self:checkWarInTab(rewards, v) == true then
					self:checkInRewards(rewards, v)
				else	
					table.insert( rewards, v)
				end
			end
		end
	end
    local function sortFunc(id_one, id_two)
        local bl_1 = (id_one[1] == 101 or id_one[1] == 130) and 1 or 0
        local bl_2 = (id_two[1] == 101 or id_two[1] == 130) and 1 or 0
        return bl_1 > bl_2
    end
    table.sort(rewards, sortFunc)
	return rewards
end

function M:checkWarInTab(rewards, data)
	for k,v in pairs(rewards) do
		if v[1] == data[1] and v[2] == data[2] then
			return true
		end
	end	
	return false
end

function M:checkInRewards(rewards, data)
	for k,v in pairs(rewards) do
		if v[1] == data[1] and v[2] == data[2] then
			v[3] = v[3] + data[3]
		end
	end	
	return rewards
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

--订阅特权配置数据
function M:get_subscribe_cfg()
    local subscribe_tab = ConfigManager:getCfgByName("auto_subscribe")
    return subscribe_tab
end

--签到基金
function M:get_sign_cfg(index)
    local sign_fund_tab = ConfigManager:getCfgByName("sign_fund")
    return sign_fund_tab[index]
end

--签到基金奖励配置
function M:get_sign_fund_cfg(version, max_day)
    local sig_fund_tab = ConfigManager:getCfgByName("sign_fund_reward")
    local c_version = version or 1
    local version_tab = sig_fund_tab[c_version]
    local new_tab = {}
    for i = 1, max_day do
        new_tab[i] = version_tab[i]
    end
    return new_tab
end

--合并所有奖励 超值基金
function M:getCanAllNormalReward(version, max_day)
    local new_reward = self:get_noormal_fund_cfg(version, max_day)
    local sum_reward = {}
    for k,v in pairs(new_reward) do
        local c_reward = v.reward[1]
        if self:checkInTab(c_reward, sum_reward) == false then
            table.insert(sum_reward, c_reward)
        else
            for k1,v1 in pairs(sum_reward) do
                if c_reward[1] == v1[1] and c_reward[2] == v1[2] then
                    v1[3] = c_reward[3] + v1[3]
                end
            end
        end
    end
    return sum_reward
end

--合并指定天数奖励 超值基金
function M:getDaysNormalReward(days,version, max_day)
    local new_reward = self:get_noormal_fund_cfg(version, max_day)
    local have_tab = {}
    for k,v in pairs(days) do
        have_tab[tonumber(v)] = true
    end
    local sum_reward = {}
    for k,v in pairs(new_reward) do
        if have_tab[k] == true then
            local c_reward = v.reward[1]
            if self:checkInTab(c_reward, sum_reward) == false then
                table.insert(sum_reward, c_reward)
            else
                for k1,v1 in pairs(sum_reward) do
                    if c_reward[1] == v1[1] and c_reward[2] == v1[2] then
                        v1[3] = c_reward[3] + v1[3]
                    end
                end
            end
        end
    end
    return sum_reward
end

--合并所有奖励 豪华基金
function M:getCanAllHighReward(version, max_day)
    local new_reward = self:get_high_fund_cfg(version, max_day)
    local sum_reward = {}
    for k,v in pairs(new_reward) do
        local c_reward = v.reward[1]
        if self:checkInTab(c_reward, sum_reward) == false then
            table.insert(sum_reward, c_reward)
        else
            for k1,v1 in pairs(sum_reward) do
                if c_reward[1] == v1[1] and c_reward[2] == v1[2] then
                    v1[3] = c_reward[3] + v1[3]
                end
            end
        end
    end
    return sum_reward
end

--合并指定天数奖励 豪华基金
function M:getDaysHighReward(days,version, max_day)
    local new_reward = self:get_high_fund_cfg(version, max_day)
    local have_tab = {}
    for k,v in pairs(days) do
        have_tab[tonumber(v)] = true
    end
    local sum_reward = {}
    for k,v in pairs(new_reward) do
        if have_tab[k] == true then
            local c_reward = v.reward[1]
            if self:checkInTab(c_reward, sum_reward) == false then
                table.insert(sum_reward, c_reward)
            else
                for k1,v1 in pairs(sum_reward) do
                    if c_reward[1] == v1[1] and c_reward[2] == v1[2] then
                        v1[3] = c_reward[3] + v1[3]
                    end
                end
            end
        end
    end
    return sum_reward
end

function M:checkInTab(data, tab)
    for k,v in pairs(tab) do
        if v[1] == data[1] and v[2] == data[2] then
            return true
        end
    end
    return false
end

--豪华基金
function M:get_high_fund_cfg(version, max_day)
    local high_fund_tab = ConfigManager:getCfgByName("high_fund_reward")
    local c_version = version or 1
    local version_tab = table.copy(high_fund_tab[c_version])
    local new_tab = {}
    for i = 1, max_day do
        new_tab[i] = version_tab[i]
    end
    return new_tab
end

--每日特惠配置数据
function M:get_gift_off_cfg(version)
    local gift_off_tab = ConfigManager:getCfgByName("gift_off")
    return gift_off_tab[version or 1]
end

--新手礼包配置数据
function M:get_gift_new_cfg()
    local gift_new_tab = ConfigManager:getCfgByName("gift_new")
    return gift_new_tab
end

--锦囊配置数据
function M:get_scroll_shop_cfg()
    local scroll_shop_tab = ConfigManager:getCfgByName("activity_gift")
    local version = self.m_war_activity_data.version or 1
    local new_tab = table.copy(scroll_shop_tab[version])
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

--日礼包
function M:get_gift_daily_cfg()
    local gift_daily_tab = ConfigManager:getCfgByName("gift_daily")
    local new_tab = {}
    for i = 1, #gift_daily_tab do
        local cur_cfg = gift_daily_tab[i]
        if cur_cfg.sort == 1 then
            table.insert( new_tab, cur_cfg)
        elseif self:readFestivalData (cur_cfg) == true then
            table.insert( new_tab, cur_cfg)
        end
    end
    return new_tab
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

--限时礼包
function M:get_limit_cfg(version, id)
    if self.m_limit_data == nil then
        return {}
    end
    local limit_tab = ConfigManager:getCfgByName("activity_limit")
    local limit_data = self.m_limit_data.activity_limit[tostring(version)]
    local server_tab = limit_data.reward_config
    local version_tab = limit_tab[version or 1]
    local new_tab = {}
    for k,v in pairs(server_tab) do
        local cfg = version_tab[tonumber(k)]
        cfg.id = tonumber(k)
        cfg.server_reward = v.reward
        table.insert(new_tab, cfg)
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

--月卡
function M:get_month_card_cfg()
    local month_card_tab = ConfigManager:getCfgByName("month_card")
    return month_card_tab
end

--私人定制礼包
function M:get_custom_made_cfg(verson)
    local custom_gift_tab = ConfigManager:getCfgByName("custom_gift")
    local custom_tab = table.copy(custom_gift_tab[verson or 1])
    for k,v in pairs(custom_tab) do
        v.id = k
    end
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
    table.sort(custom_tab, sortFunc)
    return custom_tab
end

--英雄成长礼包
function M:get_grow_up_cfg(verson)
    local hero_gift_show_tab = ConfigManager:getCfgByName("hero_gift_show")
    local hero_gift_tab = ConfigManager:getCfgByName("hero_gift")
    local gift_tab = table.copy(hero_gift_tab[verson or 1])
    for k,v in pairs(gift_tab) do
        v.id = k
    end
    return hero_gift_show_tab[verson or 1], gift_tab
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

function M:get_linshi_fund(id)
    local all_tab = ConfigManager:getCfgByName("growth_fund_reward")
    local fund_reward_tab = all_tab[id]
    local new_tab = {}
    for k,v in pairs(fund_reward_tab) do
        v.id = k
        if self:getFundData(k) then
            table.insert(new_tab, v)
        else
            Logger.logWarning(" fund data is null  ,id is  " .. v.id)
        end
    end
    local function sortFunc(id_one, id_two)
        local data_one = self:getFundData(id_one.id)
        local data_two = self:getFundData(id_two.id)
        local get_1 = data_one.status == 2 and 1 or 0
        local get_2 = data_two.status == 2 and 1 or 0
        if get_1 == get_2 then
            return id_one.id < id_two.id
        else
            return get_1 < get_2
        end
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end


--基金
function M:get_fund_reward_cfg(id)
    local all_tab = ConfigManager:getCfgByName("growth_fund_reward")
    local fund_reward_tab = all_tab[id]
    local temp_tab_get = {}
    local temp_tab_noget = {}
    local new_tab = {}
    for k,v in pairs(fund_reward_tab) do
        local fund_data = self:getFundData(tostring(k))
        if fund_data then
            if fund_data.status == 2 then
                v.id = k
                table.insert(temp_tab_get, v)
            else
                v.id = k
                table.insert(temp_tab_noget, v)
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

function M:getCanGetAll(fund_quests)
    local all_tab = ConfigManager:getCfgByName("growth_fund_reward")
    local fund_reward_tab = all_tab[85]
    local sum_num = 0
    for k,v in pairs(fund_quests) do
        local cfg = fund_reward_tab[tonumber(k)]
        if v.status == 1 then
            sum_num = sum_num + cfg.reward[1][3]
        end
    end
    return sum_num
end

--基金购买项
function M:get_growth_fund(id)
    local growth_fund_tab = ConfigManager:getCfgByName("growth_fund")
    return growth_fund_tab[id]
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

function M:getChargeById(id)
    local charge_tab = ConfigManager:getCfgByName("charge")
    return charge_tab[id]
end

--定制礼包数据
function M:getCustomGiftData(version, id, index)
    local gift_tab = self.m_custom_data[tostring(version)] or {}
    return gift_tab[tostring(id)]
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


--成长礼包下一个可领的
function M:getGrowUpCanGetReward(version)
    local hero_show_tab, gift_tab = self:get_grow_up_cfg(version)
    for i = 1, #gift_tab do
        local free_get, pay_num = self:getGrowUpRewardData(version, i)
        if free_get == false then
            return i
        end
    end
    return 1
end

function M:getActiveEndTime(actives, id)
    if actives == nil then
        return -1
    end
    for k,v in pairs(actives) do
        if v.open_status > 0 then
            if id and v.id == id then
                return v.end_ts
            else
                return v.end_ts
            end 
        end
    end
    return -1
end

function M:getActiveEndTimeByOpenID(actives, open_id)
    if actives == nil then
        return -1
    end
    local charge_tab = ConfigManager:getCfgByName("active_recharge")
    for k,v in pairs(actives) do
        if v.open_status > 0 then
            local c_cfg = charge_tab[v.id]
            if c_cfg.open_id == open_id then
                return v.end_ts
            end
        end
    end
    return 0
end

function M:getActiveData(actives, open_id)
    for k,v in pairs(actives) do
        if v.open_status > 0 then
            return v
        end
    end
    return nil
end

function M:getActivityGiftData(id)
    if self.m_war_activity_data ~= nil then
        return self.m_war_activity_data.activity_log[tostring(id)] or 0
    end
    return 0
end

function M:getChapterNum()
    local stage_tab = ConfigManager:getCfgByName("stage")
    local stage_cfg = stage_tab[UserDataManager:getCurStage()] 
    local num = stage_cfg.chapter_id - 1
    return num
end

function M:getAddRechargeNumByOpenId(open_id)
    local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
    for k,v in pairs(active_recharge_tab) do
        if v.open_id == open_id then
            return v.add_recharge or 0
        end
    end
    return 0
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
    if tag == "war_order_valor_index" or tag == "war_order_index" or tag == "war_goal_common_index" then
        self.m_war_older_actives = data.actives[1]
        self:setWarOlderData(data)
    elseif tag == "month_card" then
        self.m_month_card_data = data --月卡数据
    elseif tag == "fund_index" then
        self.m_fund_data = data --成长基金数据
    elseif tag == "activity_gift_index" then
        self.m_war_activity_data = data --锦囊礼包数据
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
    elseif tag == "gift_new_index" then
        self.m_net_actives = data.actives
        --新手礼包
        self.m_gift_new_data = data.gift_new
    elseif tag == "gift_supervalue_index" then
        self.m_net_actives = data.actives
        --超值礼包
        self.m_supervalu_data = data.gift_data
    elseif tag == "pay_shop_index" then
        self.m_charge_data = data
    elseif tag == "bright_bless_index" then --新手福利
        self.m_bright_data = data    
    elseif tag == "cmlt_recharge_index" then --累计充值
        self.m_cmlt_actives= data.actives
        self.m_cmlt_recharge_data = data.cmlt_recharge  
    elseif tag == "custom_gift_index" then --定制礼包
        self.m_custom_data = data.custom_gift
        self.m_custom_actives = data.actives
    elseif tag == "hero_gift_index" then --成长礼包
        self.m_hero_gift_data = data.gifts_detail
        self.m_hero_gift_actives= data.actives
    elseif tag == "sign_fund_index" then --签到基金
        self.m_sign_data = data
    elseif tag == "sign_daily_index" then --签到
        self.m_sign_daily_data = data or {}
    elseif tag == "tiktok_data" then
        if data and data.tiktok_record then
            self.m_tiktok_data = data.tiktok_record
        else
            self.m_tiktok_data = {}
        end
    end
end

function M:setWarOlderData(data)
    if data.valor_end_ts ~= nil then
        self.m_war_older_data = {
                                actives = data.actives,
                                id = data.id,
                                open_id = data.open_id,
                                is_open = data.is_valor_open,
                                 num = data.valor_medals,
                                 end_ts = data.valor_end_ts,
                                 free_received = data.vm_free_received,
                                 pay_received = data.vm_pay_received,
                                 payment_status = data.valor_payment_status,
                                 lv = data.vm_lv,
                                 vsn = data.vsn}--战令数据
    elseif data.heroic_end_ts ~= nil then
        self.m_war_older_data = {
                                actives = data.actives,
                                id = data.id,
                                open_id = data.open_id,
                                is_open = data.is_heroic_open,
                                 num = data.heroic_merit,
                                 end_ts = data.heroic_end_ts,
                                 free_received = data.hm_free_received,
                                 pay_received = data.hm_pay_received,
                                 payment_status = data.heroic_payment_status,
                                 lv = data.hm_lv,
                                 vsn = data.vsn} --江湖行侠令数据
    elseif data.end_ts ~= nil then
        self.m_war_older_data = {
            actives = data.actives,
            id = data.id,
            open_id = data.open_id,
            is_open = data.is_heroic_open,
            num = data.num,
            end_ts = data.end_ts,
            free_received = data.free_recv,
            pay_received = data.pay_recv,
            payment_status = data.pay_state,
            lv = data.vsn,
            vsn = data.vsn} --江湖行侠令数据
    end
end

function M:mergeWarOlderData(data)
    if data.actives ~= nil then
        self.m_war_older_data.actives = data.actives
    end
    if data.id ~= nil then
        self.m_war_older_data.id = data.id
    end
    if data.open_id ~= nil then
        self.m_war_older_data.open_id = data.open_id
    end
    if data.vsn ~= nil then
        self.m_war_older_data.vsn = data.vsn
    end
    if data.is_heroic_open ~= nil then
        self.m_war_older_data.is_open = data.is_heroic_open
    elseif data.is_valor_open ~= nil then
        self.m_war_older_data.is_open = data.is_valor_open
    end
    if data.heroic_merit ~= nil then
        self.m_war_older_data.num = data.heroic_merit
    elseif data.valor_medals ~= nil then
        self.m_war_older_data.num = data.valor_medals
    elseif data.num ~= nil then
        self.m_war_older_data.num = data.num
    end
    if data.heroic_end_ts ~= nil then
        self.m_war_older_data.end_ts = data.heroic_end_ts
    elseif data.valor_end_ts ~= nil then
        self.m_war_older_data.end_ts = data.valor_end_ts
    elseif data.end_ts ~= nil then
        self.m_war_older_data.end_ts = data.end_ts
    end
    if data.hm_free_received ~= nil then
        self.m_war_older_data.free_received = data.hm_free_received
    elseif data.vm_free_received ~= nil then
        self.m_war_older_data.free_received = data.vm_free_received
    elseif data.free_recv ~= nil then
        self.m_war_older_data.free_received = data.free_recv
    end
    if data.hm_pay_received ~= nil then
        self.m_war_older_data.pay_received = data.hm_pay_received
    elseif data.vm_pay_received ~= nil then
        self.m_war_older_data.pay_received = data.vm_pay_received
    elseif data.pay_recv ~= nil then
        self.m_war_older_data.pay_received = data.pay_recv
    end
    if data.heroic_payment_status ~= nil then
        self.m_war_older_data.payment_status = data.heroic_payment_status
    elseif data.valor_payment_status ~= nil then
        self.m_war_older_data.payment_status = data.valor_payment_status
    elseif data.pay_state ~= nil then
        self.m_war_older_data.payment_status = data.pay_state
    end
    if data.hm_lv ~= nil then
        self.m_war_older_data.lv = data.hm_lv
    elseif data.vm_lv ~= nil then
        self.m_war_older_data.lv = data.vm_lv
    end
end

function M:getNotGetRoyalReward()
    local old_cur_lv = self:getRoyalShowLv(80)
    local not_tab = {}
    for i = 1, old_cur_lv do
        if not(self:getReceived(80, i)) then
            not_tab[#not_tab + 1] = i
        end
    end
    return not_tab
end

return M
