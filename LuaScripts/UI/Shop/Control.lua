---@class ShopControl:OOControlBase
---@field m_model ShopModel
---@field m_view ShopView
local M = class("ShopControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("Amb_2D_indoor_fire")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:clearRedPoint()
        self:updateMsg("refresh_red_point", nil, "parent")
        self:closeView()
    elseif msg == "clearRedPoint" then
        self:clearRedPoint()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 12})
    -- 1商铺、2遣散商店、3迷宫商店、4公会商店
    elseif type(msg) == "number" and msg >= 1 and msg <= #(self.m_model:getTabBtnNode()) then
        self:switchTabBtn(msg)
    elseif msg == "shop_detail_btn" then
        local open_flag, _ = self.m_model:getShopCellOpenFlag(data.cell_data)
        local caution = self.m_model:isCaution(data.cell_data)
        self.is_today = false
        if open_flag or self.m_model.m_shop_type == 37 then
            self:shopDetailPop(data.index, data.cell_data)
        end
    elseif msg == "shop_buy_btn" then
        local open_flag, _ = self.m_model:getShopCellOpenFlag(data.cell_data)
        local caution = self.m_model:isCaution(data.cell_data)
        self.is_today = caution == 1
        self:getIsToday()
        if open_flag then
            if caution == 1 and self.m_model.toDay_active then
                self:shopDetailPop(data.index, data.cell_data)
            else
                self:readyToBuy(data.index, data.cell_data)
            end
        end
    elseif msg == "refresh_btn" then -- 刷新
        self:refreshShopTips()
    elseif msg == "refresh" then
        self.m_model.m_refresh_flag = true
        self:shopIndex(self.m_model.m_sel_tab_index)
    elseif msg == "race_tab_btn" then
        self:raceScreen(data)
    end
end

function M:raceScreen(index)
    self.m_model.m_select_race_index = index
    self.m_view:refreshShopLoopScroll()
end

function M:refreshShopTips()
    local cost = nil
    if self.m_model.m_shop_type == 1 then
        -- 普通商店先免费，再使用刷新道具
        local free_refresh_flag = self.m_model:getFreeRefreshFlag()
        if free_refresh_flag then -- 有免费刷新
            self:shopRefresh()
        else
            cost = self.m_model:getOrdinaryShopRefreshCost()
        end
    else
        cost = self.m_model:getRefreshCost()
    end
    if cost then
        local shop_refresh_tips_time = UserDataManager.local_data:getUserDataByKey("shop_refresh_tips_time" ..  self.m_model.m_shop_type, 0)
        local save_time_tab = TimeUtil.gmTime(shop_refresh_tips_time)
        local server_time = UserDataManager:getServerTime()
        local server_time_tab = TimeUtil.gmTime(server_time)
        local is_max = self.m_model:isMaxTime()
        local cur_times = self.m_model:getCurTimes()
        local max_times = self.m_model:getMaxTimes()
        if shop_refresh_tips_time == 0 or save_time_tab.day ~= server_time_tab.day then
            local params =
            {
                on_ok_call = function(params)
                    self:shopRefresh()
                    if params.isToday then
                        UserDataManager.local_data:setUserDataByKey("shop_refresh_tips_time" .. self.m_model.m_shop_type, UserDataManager:getServerTime())
                    end
                end,
                text = Language:getTextByKey("new_str_0036"),
                cost = cost,
                consume = cost,
                is_show_limit = self.m_model.shop_type ~= 1,
                is_max = is_max,
                cur_times = cur_times,
                max_times = max_times,
                istoday = true
            }
            self:openView("Pops.CommonPop", params)
        else
            if is_max and self.m_model.shop_type ~= 1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
                return
            end
            local data = RewardUtil:getProcessRewardData(cost)
            if data.user_num < data.data_num then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0098", data.name), delay_close = 2})
            else
                self:shopRefresh()
            end
        end
    end
end

function M:shopDetailPop(index, cell_data)
    local data = cell_data
    local remain = data.data.remain or 0
    if remain < 1 then
        return
    end
    self.m_model.m_refresh_flag = false
    local item = data.data.item
    local sell = data.data.sell
    local show_data = RewardUtil:getProcessRewardData(item)
    local function okCallFunc(msg)
        if msg ~= nil and msg.cur_server_ts ~= nil then
            self.m_model.callback_time = msg.cur_server_ts
            UserDataManager.local_data:setUserDataByKey("shop_tips", self.m_model.callback_time or nil)
        end
        UserDataManager.local_data:setUserDataByKey("shop_tips_is_first", 1)
        self:readyToBuy(index, cell_data)
    end
    self:getIsToday()
    local is_first = UserDataManager.local_data:getUserDataByKey("shop_tips_is_first", 0)
    local show_yes = true
    if is_first == 1 and self.m_model.callback_time == nil then
        show_yes = false
    end
    if show_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
        self:openView("HeroInfo.EquipmentPop", {equip_cfg_id = show_data.data_id, cost = sell, ok_call_func = okCallFunc, look_model = 2, hero_ids = data.hero_ids,isToday = self.is_today,today_btn_value = show_yes, race = show_data.race})
    elseif show_data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
        self:openView("SutraDepository.DepositoryPop", {oid = show_data.data_id, look_model = 3, cost = sell, ok_call_func = okCallFunc,isToday = self.is_today,today_btn_value = show_yes})
    elseif show_data.data_type == RewardUtil.REWARD_TYPE_KEYS.TITLE then
        self:openView("Title.TitleDetail", {show_data = show_data, look_model = 3, cost = sell, ok_call_func = okCallFunc,isToday = self.is_today,today_btn_value = show_yes})
    elseif show_data.data_type == RewardUtil.REWARD_TYPE_KEYS.SEAL_CHARACTER then
        self:openView("Item.ItemDetail.ItemDetailTalins", {show_data = show_data, cost = sell, ok_call_func = okCallFunc,isToday = self.is_today,today_btn_value = show_yes})
    else
        self:openView("Item.ItemDetail", {show_data = show_data, cost = sell, ok_call_func = okCallFunc,isToday = self.is_today,today_btn_value = show_yes})
    end
end

--判断是否可以弹提示窗
function M:getIsToday()
    self.m_model.callback_time = UserDataManager.local_data:getUserDataByKey("shop_tips", nil)
    self.m_model.toDay_active = true
    if self.m_model.callback_time ~= nil then
        local server_ts = UserDataManager:getServerTime()
        local day = GameUtil:NumberOfDaysInterval(self.m_model.callback_time,server_ts)
        if day >= 1 then
            self.m_model.toDay_active = true
        else
            self.m_model.toDay_active = false
        end
    end
end

function M:readyToBuy(index, cell_data)
    local remain = cell_data.data.remain or 0
    if remain < 1 then
        return
    end
    if self.m_model.m_refresh_flag then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0099"), delay_close = 2})
        return
    end
    local sell = {}
    if self.m_model.m_shop_type == 25 or self.m_model.m_shop_type == 28 or self.m_model.m_shop_type == 30 then
        sell = cell_data.data.sell
    else
        table.insert(sell,cell_data.data.sell)
    end
    for i, v in pairs(sell) do
        local data = RewardUtil:getProcessRewardData(v)
        if data.user_num < data.data_num then
            local flag = QuickOpenFuncUtil:hasCostsTips({v})
            if not flag then
                local text = Language:getTextByKey("new_str_0098", data.name)
                if data.item_cfg.gain and data.item_cfg.gain ~= "" then
                    text = text .. "\n" .. Language:getTextByKey(data.item_cfg.gain)
                end
                GameUtil:lookInfoTips(self, {msg = text, delay_close = 2})
            end
            return
        end
    end
    if (self.m_model.m_shop_type == 25 or self.m_model.m_shop_type == 28 or self.m_model.m_shop_type == 30 ) and self.m_model:getIsCaution(cell_data.data.goods_id or 0) == 1 then --苗疆商店弹窗限制
        self:popTips(index, cell_data)
    else
        self:shopBuy(index, cell_data)
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        local shop_type = self.m_model:getShopTypeByIndex(index)
        if self.m_model:cacheExist(shop_type) then
            self.m_model.m_shop_type = shop_type
            self.m_model.m_sel_tab_index = index
            self.m_view:switchTabNode(index, true)
            self:clearRedPoint()
        else
            self:shopIndex(index, true)
        end
    end
end

-- shop_type: 商店类型,1:普通商铺，2：工会商店，3：遣散商店，4：迷宫商店
function M:shopIndex(index, reset_race)
    local shop_type = self.m_model:getShopTypeByIndex(index)
    local function netCallback(response)
        if response and self.m_model then
            self.m_model.m_shop_type = shop_type
            self.m_model.m_sel_tab_index = index
            self.m_model:initDataByType(response, self.m_model.m_shop_type)
            self.m_view:switchTabNode(index, reset_race)
            self:clearRedPoint()
        end
    end
    local params = {shop_type = shop_type}
    self.m_model:getNetData("shop_index", params, netCallback)
end

-- 商店刷新 shop_type: 商店类型,1:普通商铺，2：工会商店，3：遣散商店，4：迷宫商店
function M:shopRefresh()
    local function netCallback(response)
        self.m_model:initDataByType(response, self.m_model.m_shop_type)
        self.m_view:switchTabNode(self.m_model.m_sel_tab_index)
    end
    local params = {shop_type = self.m_model.m_shop_type}
    self.m_model:getNetData("shop_refresh", params, netCallback)
end

-- -- 商店购买 shop_type: 商店类型,1:普通商铺，2：工会商店，3：遣散商店，4：迷宫商店 pos: 物品位置，从1开始
function M:shopBuy(index, cell_data)
    local data = cell_data
    local function netCallback(response)
        self.m_model:initDataByType(response, self.m_model.m_shop_type)
        self.m_view:switchTabNode(self.m_model.m_sel_tab_index)
        if self.m_model.m_shop_type == 31 then 
            RewardUtil:rewardTipsByData(response.reward)
        else
            RewardUtil:rewardLookInfoTipsByData(response.reward)
        end
        
    end
    local params = {shop_type = cell_data.shop_type or self.m_model.m_shop_type, pos = data.id}
    self.m_model:getNetData("shop_buy", params, netCallback)
end

function M:popTips(index, cell_data)
    local tips = Language:getTextByKey("new_str_0971")
    local tips_str, target_str = "", ""
    for i, v in pairs(cell_data.data.sell) do
        local coin_data =  RewardUtil:getProcessRewardData(v)
        tips_str = tips_str .. tostring(coin_data.data_num)  .. coin_data.name  .. (i < #(cell_data.data.sell) and "," or "")
    end
    local target_item = RewardUtil:getProcessRewardData(cell_data.data.item)
    target_str = target_item.data_num .. target_item.name
    local content = Language:getTextByKey("hunt_treasure_str_059", tips_str, target_str)
    local params =
    {
        on_ok_call = function(msg)
            self:shopBuy(index, cell_data)
        end,
        new_cancel_call = function(msg)
        end,
        tow_close_btn = true,
        cancel_text = Language:getTextByKey("new_str_0007"),
        title = Language:getTextByKey("new_str_0970"),
        --no_close_btn = true,
        text = content,
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

function M:clearRedPoint()
    local tab_btn = self.m_model:getTabBtnByShopType(self.m_model.m_shop_type)
    if tab_btn and tab_btn.red_point_id and tab_btn.red_point_key then
        local red_flag = RedPointUtil:hasRedPointById(tab_btn.red_point_id)
        if red_flag then
            local red_point_key = tab_btn.red_point_key
            local function clearRedCall()
                self.m_view:refreshRedPoint()
            end
            self.m_model:getNetData("red_dot_clear", {red_dot_type = {red_point_key}}, clearRedCall)
        end
    end
end

function M:destroy()
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    M.super.destroy(self)
end

return M
