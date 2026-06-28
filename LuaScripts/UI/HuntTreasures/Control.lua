local M = class("HuntTreasuresControl",LikeOO.OOControlBase)

local __scene_id = 102

function M:onEnter()
    self.m_guide_file_name = "UI.HuntTreasures.Guide"
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    audio:SendEvtBGM("Set_State_MiaoJiang")
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(57, 0)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 85})
    elseif msg == "battle_log_btn" then
        self:openView("HuntTreasures.HuntTreasuresLogPop")
    elseif msg == "area_btn" then
        local sub_id = self.m_model:getCurSubId()
        self:openView("HuntTreasures.HuntTreasuresAreaPop", {region_id = self.m_model.m_region_id,sub_id = sub_id})
    elseif msg == "big_map_btn" then
        self:openView("HuntTreasures.HuntTreasuresBigMapPop")
    elseif msg == "my_area_btn" then
        self:openView("HuntTreasures.HuntTreasuresMyTeamPop")
    elseif msg == "change_HuntTreasures_scene" then
        --SceneManager:changeScene(SceneManager.SceneID.JiaoWai)
        self.m_view:refreshUI()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "guide_check" then
        self.m_guide:checkGuide()
    elseif msg == "battle_end_refresh_ui" or msg == "refresh_cur_page" then
        local region_id = self.m_model.m_region_id
        local location_id =  self.m_model.m_location_id
        if msg == "battle_end_refresh_ui" then
            audio:SendEvtBGM("Set_State_MiaoJiang")
        end
        if data and data.region_id then
            region_id = data.region_id
            location_id = data.location_id
        end
        self:requestLocationIndex(region_id, location_id, nil, function()
            if data and data.occupy_success then
                audio:SendEvtUI("UI_KuangDongZL")
            end
            self.m_guide:checkGuide()
        end )
    elseif msg == "update_buy_plunder" then
        local buy_plunder = data and data.buy_plunder or  self.m_model.m_data.buy_plunder
        self.m_model.m_data.buy_plunder = buy_plunder
        self.m_view:refreshRobTimes()
    elseif msg == "left_btn" or msg == "right_btn" then
        local next_page = self.m_model:getNextPage(msg)
        if next_page == self.m_model.m_cur_page then
            GameUtil:lookInfoTips(self, {msg = "到头了，别点了", delay_close = 2})
        else
            local region_id, location_id = self.m_model.m_region_id, self.m_model:getLocationIdByPage(next_page)
            self:requestLocationIndex(region_id, location_id, msg)
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "hunt_treasure_str_028"
        params.content = "tid#mining_dec_01"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "buy_plunder_times_btn" then
        self:showBuyWindow()
    elseif msg == "refreshData" then
        local buy_times = data.num == 1 and 0 or data.num
        local remainTimes = self.m_model:getRemainBuyTimes() - buy_times;
        local msg = Language:getTextByKey("hunt_treasure_str_031", remainTimes)
        local cost = self.m_model:getBuyCost(data.num)
        self:updateMsg("updateMsgInfo",{ msg= msg, cost = cost[3] },"Pops.CommonBuyPop");
    elseif msg == "click_mine" then
        local mine_index = data
        local params = self.m_view.m_area_node:getOpenMineParams(mine_index)
        self:openView("HuntTreasures.HuntTreasuresAreaInfoPop", {
                                                                 plunder_times = params.plunder_times,
                                                                 buy_plunder = params.buy_plunder,
                                                                 area_index = mine_index,
                                                                 mines_data = params.mines_data,
                                                                 mine_img_name = params.mine_img_name
        })
    elseif msg == "change_area" then
        local region_id, location_id, close_view_name = data.region_id, data.location_id, data.close_view_name
        self:requestLocationIndex(region_id, location_id, nil, function()
            if data.callFunc then
                data.callFunc()
            end
            self:closeView("HuntTreasures." .. close_view_name)
            self.m_guide:checkGuide()
        end )
    elseif msg == "shop_btn" then
        self:openView("Shop", {shop_type = 25})
    end
end

function M:showBuyWindow()
    local remainTimes = self.m_model:getRemainBuyTimes();
    if remainTimes <= 0 then
        remainTimes = 0;
    end
    local cost_data = self.m_model:getBuyCost(1)
    --点击购买骰子
    local params =
    {
        --内容
        msg = Language:getTextByKey("hunt_treasure_str_031", remainTimes-1),
        --标题
        title = Language:getTextByKey("hunt_treasure_str_032"),
        --通知的类名
        className = "HuntTreasures",
        --最大购买次数
        m_max_buyNum = remainTimes,
        --消耗类型
        cost_data = cost_data,
        --点击购买
        clickBuy = function( num )
            local function netCallback(response)
                self.m_model.m_data.buy_plunder = response.buy_plunder;
                self.m_view:refreshUI();
            end
            self.m_model:getNetData("mining_buy_plunder_times", { times = num } , netCallback)
        end
    }
    self:openView("Pops.CommonBuyPop", params)
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:requestLocationIndex(region_id, location_id, msg, callFunc)
    local region_id, location_id = region_id, location_id
    local function callfunc(response)
        self.m_model:initData(response)
        --self.m_model.m_cur_page = response.location_id
        local direction = msg and (msg == "left_btn" and "right_to_left" or "left_to_right") or nil
        self.m_view:refreshUI()
        self.m_view:refreshAreaNode(direction)
        if callFunc then
            callFunc()
        end
    end
    self.m_model:getNetData("mining_location_index", { region_id = region_id, location_id = location_id }, callfunc)
end

function M:dataUpdateEvent(event, data)
    if data.event == "remove_red_dot" or data.event == "red_dot_update" then
        self.m_view:refreshRedPoint()
    end
end

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
    end
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    audio:SendEvtBGM("Set_State_TianXia")
    M.super.destroy(self)
end

return M;
