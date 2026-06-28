local M = class("JuBaoShanControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.JuBaoShan.Guide"
    SceneManager:changeScene(SceneManager.SceneID.JuBaoShanScene,self.m_model.m_data)
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    self.showZuobi = false;
    self.canRoll = true;
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(51, 2)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 41})
    elseif msg == "close_roll_nun_btn" then
        if self.showZuobi == true then
            self.showZuobi = false;
            self.m_view:hideZuoBiView();
        end
    elseif msg == "jubaoshan_time_end" then
        self:closeAllViewPop({ ["Loading.SyncLoadBigLoading"] = 1 })
    elseif msg == "load_scene_finish" then
        self.m_model:buildData();
    elseif msg == "update_red_point" then
        self.m_view:setObjectVisible("shop_red_point", RedPointUtil:hasRedPointById(11301))
    elseif msg == "refresh_ui" then
        local function netCallback(response)
            self.m_model.m_data = response;
            self.m_model:updateServerData();
            self.m_view:refreshUI();
            self:updateMsg("update_data", self.m_model.m_data, "JuBaoShan.JuBaoShanGiftBag")
        end
        self.m_model:getNetData("richman_index", {}, netCallback)
    elseif msg == "gift_bag_btn" then
        self:openView("JuBaoShan.JuBaoShanGiftBag", {data = self.m_model.m_data})
    elseif msg == "roll_btn" then
        if self.m_model.m_data.times <= 0 then
            self:updateMsg("btn_maskBtn")
            self:showBuyWindow();
            return;
        end
        if self.canRoll == true then
            self.canRoll = false;
            --开始roll点
            local function netCallback(response)
                if response ~= nil then
                    if not self.m_model.m_seriesThrow then
                        self.m_view:lockTouch()
                    end
                    audio:SendEvtUI("UI_Touz")
                    self.m_model:refreshData(response);
                    self.m_view:refreshUI();
                    self.m_view:showRollNum( response.point );
                    self:setOnceTimer(1,function()
                        self.m_view:hideRoleNum();
                        SceneManager:getCurSceneModel():Roll( response )
                    end)
                else
                    self.canRoll = true;
                end
            end
            local params = {
                vsn = self.m_model.m_version
            }
            self.m_model:getNetData("richman_roll", params, netCallback, true, true)
        end
        if self.showZuobi == true then
            self.showZuobi = false;
            self.m_view:hideZuoBiView();
        end
    elseif msg == "quest_special_btn" then
        --打开任务列表
        self:openView("Task.TaskMainChapter", {quest_type = 104, roll_data = self.m_model.m_data.quests, param = self.m_model.m_data.map_id} )
    elseif msg == "taskFinish" then
        --刷新作弊筛子
        self.m_model:refreshItemData()
        self.m_model:buildData();
        self.m_view:refreshUI();
    elseif msg == "unlockTouch" then
        self.canRoll = true;
        self.m_view:unlockTouch()
        if self.m_model.m_seriesThrow then
            self:updateMsg("roll_btn")
        end
    elseif msg == "rollInfo_bg" then
        local cells, minCell = self.m_model:buildData();
        self:openView("JuBaoShan.JuBaoShanSendPop", { cells = cells, cycle = self.m_model.cycle, lv_gifts = self.m_model.m_cell_lv_gift });
    elseif msg == "buildData" then
        self.m_model:buildData();
        self.m_view:refreshUI();
    elseif msg == "passiveCell_click" then
        local isShowPopWindow = (not self.m_model.m_autoDispatch)
        if self.m_model.m_seriesThrow then
            isShowPopWindow = false
        end
        self:cellClickEvent(data, isShowPopWindow)
    elseif msg == "cell_click" then
        --行脚商
        self:cellClickEvent(data, true)
    elseif msg == "roll_zuobi_btn" then
        if self:hasZuoBi() == false then
            return;
        end
        if self.showZuobi == true then
            self.showZuobi = false;
            self.m_view:hideZuoBiView();
        else
            self.showZuobi = true;
            self.m_view:showZuoBiView();
        end
    elseif msg == "roll_shop_btn" then
        self:openView("Shop", {shop_type = 11, pop_from_func_id = -1})
    elseif msg == "add_remain_time_btn" then
        self:showBuyWindow();
    elseif msg == "roll_num_1" then
        self:zuoBiRoll(1);
    elseif msg == "roll_num_2" then
        self:zuoBiRoll(2);
    elseif msg == "roll_num_3" then
        self:zuoBiRoll(3);
    elseif msg == "roll_num_4" then
        self:zuoBiRoll(4);
    elseif msg == "roll_num_5" then
        self:zuoBiRoll(5);
    elseif msg == "roll_num_6" then
        self:zuoBiRoll(6);
    elseif msg == "refreshData" then
        local remainTimes = self.m_model:getRemainBuyTimes() - data.num;
        local msg = Language:getTextByKey("jubaoShan_str_005",self.m_model.m_vip, self.m_model:getRemainBuyTimes());
        local cost = self:getCost(data.num)
        self:updateMsg("updateMsgInfo",{ msg= msg, cost = cost },"JuBaoShan.JuBaoShanBuyPop");
    elseif msg == "btn_autoDispatchBtn" then
        -- 自动派遣
        self.m_model:modifyAutoDispatch(not self.m_model.m_autoDispatch)
        self.m_view:refreshAutoDispatch()
    elseif msg == "btn_seriesThrow" then
        -- 连续投掷
        if not self.m_model.m_autoDispatch then
            local params =
            {
                on_ok_call = function(msg)
                    self.m_model:modifyAutoDispatch(true)
                    self.m_view:refreshAutoDispatch()
                    self:openSeriesThrow()
                end,
                on_cancel_call = function(msg)
                    self:openSeriesThrow()
                end,
                no_close_btn = false,
                tow_close_btn = true,
                ok_text = Language:getTextByKey("jubaoShan_str_033"),
                cancel_text = Language:getTextByKey("jubaoShan_str_034"),
                text = Language:getTextByKey("jubaoShan_str_032"),
            }
            self:openView("Pops.CommonPop", params)
        else
            self:openSeriesThrow()
        end
    elseif msg == "btn_maskBtn" then
        -- 终止连续投掷
        self.m_model:modifySeriesThrow(false)
        self.m_view:refreshSeriesThrow()
    elseif msg == "got_jubaoshanAward" then
        if self.m_model.m_seriesThrow then
            if table.nums(data.awardData) > 0 then
                RewardUtil:rewardTipsByData(data.awardData)
                self:setOnceTimer(0.8,function()
                    self:closeView("Pops.CommonRewardPop")
                    self.canRoll = true;
                    self.m_view:unlockTouch()
                    data.callBack()
                    --self:updateMsg("roll_btn")
                end)
            else
                data.callBack()
            end
        else
            RewardUtil:rewardTipsByData(data.awardData, { } , data.callBack,data.rewardCallBack)
        end
    end
end

-- 开启连续投掷
function M:openSeriesThrow()
    if self.m_model.m_data.times > 0 then
        self.m_model:modifySeriesThrow(true)
        self.m_view:refreshSeriesThrow()
        self:updateMsg("roll_btn")
    else
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("jubaoShan_str_031"), delay_close = 2})
    end
end

function M:cellClickEvent(data, isShowPopWindow)
    if data.clickCellInfo.cell_config.interface_id == 1 then
        self:openView("Shop", {shop_type = 11, fixed_shop_type = self.m_model.race_shop_type})
    elseif data.clickCellInfo.cell_config.interface_id == 2 then
        if isShowPopWindow then
            --- 都不勾 弹出
            -- 勾1  
            self:showSelectPopWindow(data)
        else
            if self.m_model.m_autoDispatch then
                local cell_data = data.clickCellInfo
                local cellType = cell_data.cell_type
                local function callback(serverData)
                    local soltPlayers = {}
                    if serverData then
                        --已经雇佣的人
                        if serverData.team ~= nil then
                            for i, v in ipairs(serverData.team) do
                                soltPlayers[i] = v;
                            end
                        end
                    end
                    self:sendDispatch(cell_data, soltPlayers)
                end
                if cellType == 2 then
                    self.m_model:getNetData("richman_bank_dispatch_view", {pos = cell_data.cell_index}, callback, nil, true)
                else
                    local soltPlayers = {}
                    --已经雇佣的人
                    if data.team ~= nil then
                        for i, v in ipairs(data.team) do
                            soltPlayers[i] = v;
                        end
                    end
                    self.m_model:getNetData("richman_building_dispatch_view", { pos = cell_data.cell_index, team = soltPlayers}, callback, nil, true)
                end
            else
                self:autoRefreshJuBaoShanSceneCell()
            end
        end
       
    end
end

-- 自动派遣逻辑相关
function M:autoRefreshJuBaoShanSceneCell(data)
    if data ~= nil then
        SceneManager:getCurSceneModel():updateCellInfoBySendServerData(data);
        static_rootControl:updateMsg("buildData",nil,"JuBaoShan")
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("jubaoShan_str_030"), delay_close = 2})
    end
end

function M:sendDispatch(cell_data, soltPlayers)
    --派遣
    local function callfunc(data)
       self:autoRefreshJuBaoShanSceneCell(data)
    end
    local params = {
        pos = cell_data.cell_index,
        team = soltPlayers,
    }
    if cell_data.cell_type == 2 then
        --钱庄
        self.m_model:getNetData("richman_bank_dispatch", params, callfunc,false,nil, GlobalConfig.POST)
    else
        --建筑
        self.m_model:getNetData("richman_building_dispatch", params, callfunc,false,nil, GlobalConfig.POST)
    end
end

function M:showSelectPopWindow(data)
    local gift = self.m_model:getGift(data.clickCellInfo.id, data.clickCellInfo.lv);
    local params = {
        --奖励
        cell_data = data.clickCellInfo,
        buildingPlayers = data.buildingPlayers,
        lv_gift = gift,
    }
    self:openView("JuBaoShan.JuBaoShanHeroSelectPop", params)
end

function M:showBuyWindow()
    local remainTimes = self.m_model:getRemainBuyTimes();
    if remainTimes <= 0 then
        remainTimes = 0;
    end
    local cost_index = 1;
    for i, v in ipairs(self.m_model.m_cost_config.count_list) do
        if self.m_model.m_buy_times < v then
            cost_index = i;
            break;
        end
    end
    local cur_remainTimes = remainTimes - 1
    if cur_remainTimes < 0 then
        cur_remainTimes = 0
    end
    --点击购买骰子
    local params =
    {
        --内容
        msg = Language:getTextByKey("jubaoShan_str_005",self.m_model.m_vip, self.m_model:getRemainBuyTimes()),
        --标题
        title = "goumai_touzi",
        --通知的类名
        className = "JuBaoShan",
        --最大购买次数
        m_max_buyNum = self.m_model:getRemainBuyTimes(),
        --消耗类型
        cost_data = self.m_model.m_cost_config.cost[cost_index],
        --消耗
        cost = self:getCost(1),
        --点击购买
        clickBuy = function( num )
            local function netCallback(response)
                self.m_model.m_data.times = response.times;
                self.m_model.m_buy_times = response.buy_times;
                self.m_view:refreshUI();
            end
            self.m_model:getNetData("richman_buy_times", { times = num } , netCallback)
        end
    }
    self:openView("JuBaoShan.JuBaoShanBuyPop", params)
end


--获取消耗
function M:getCost(num)
    --真正购买次数
    --7
    local real_num = num;
    local cost = 0
    local last_config = nil
    for i, v in pairs(self.m_model.m_cost_config.cost) do
        last_config = v;
    end
    -- 1,2,3,4,5,99999
    for i = 1, real_num do
        local costData = self.m_model.m_cost_config.cost[i]
        if costData ~= nil then
            cost = cost + costData[3];
        else
            cost = cost + last_config[3];
        end
    end
    return cost;
end


function M:hasZuoBi()
    local sell = {
        RewardUtil.REWARD_TYPE_KEYS.ITEM,
        1609,
        1,
    }
    local data = RewardUtil:getProcessRewardData(sell)
    if data.user_num < data.data_num then
        local flag = QuickOpenFuncUtil:hasCostsTips({sell})
        if not flag then
            local text = Language:getTextByKey("new_str_0098", data.name)
            if data.item_cfg.gain and data.item_cfg.gain ~= "" then
                text = text .. "\n" .. Language:getTextByKey(data.item_cfg.gain)
            end
            GameUtil:lookInfoTips(self, {msg = text, delay_close = 2})
        end
        return false;
    end
    return true;
end


function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "richman_update" or curEvent == "stage_update" then
        self.m_view:refreshUI();
    end
end

--坐标Roll
function M:zuoBiRoll( point )
    if self:hasZuoBi() == false then
        return;
    end
    
    local function netCallback(response)
        --Logger.logError(response," 揉点返回数据 ")
        self.m_model:refreshItemData();
        self.m_model:refreshData(response);
        self.m_view:refreshUI();
        self.m_view:lockTouch()
        SceneManager:getCurSceneModel():Roll( response )
        --self.m_view:showRollNum( response.point );
        self:setOnceTimer(3,function()
            self.m_view:hideRoleNum();
        end)
    end
    local params = {
        special = 1,
        point = point,
        vsn = self.m_model.m_version,
    }
    self.m_model:getNetData("richman_roll", params, netCallback)
    self.showZuobi = false;
    self.m_view:hideZuoBiView();
end


function M:closeViewEvent(event, data)
    local view_name = data.name or ""
    if view_name == "Shop" then
        self.m_model:refreshItemData()
        self.m_view:refreshUI()
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    M.super.destroy(self)
end

return M