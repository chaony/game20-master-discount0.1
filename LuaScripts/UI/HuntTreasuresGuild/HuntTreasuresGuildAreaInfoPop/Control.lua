local M = class("HuntTreasuresGuildAreaInfoPop",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model:isNeedRefreshMain() then
            self:updateMsg("refresh_cur_page",nil,"HuntTreasuresGuild")
        end
        self:closeView()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg == "click_hero" or msg == "team_edit_btn" then
        local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
        if self_uid == self.m_model.m_data.def_uid then
            local region_id =  math.modf(self.m_model.m_oid / 10000)
            local races = GameUtil:getActiveRacesByRegionId(region_id, self.m_model.m_version)
            local team_id = self.m_model.m_data.team_id
            self:openView("Formation",{ races = races, mode = GlobalConfig.BATTLE_MODE.ACTIVE_MINING_DEFENSE, formation_index = team_id})
        end
    elseif msg == "refresh_data" then
        self:freshNetData() 
    elseif msg == "reward_btn" then
        if self.m_model.m_status == self.m_model.m_status_code.IS_SELF then
            self:requestRecall()
        end
    elseif msg == "challenge_btn" then
        if self.m_model.m_mines_data.is_guild == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("hunt_treasure_str_050"), delay_close = 2})
            return
        end
        local cur_time = TimeUtil.gmTime(UserDataManager:getServerTime())  --服务器时间    
        if cur_time.hour >= 0 and cur_time.hour < 6 and self.m_model.m_robot_id == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("hunt_treasure_str_047"), delay_close = 2})
            return
        end
        if self.m_model.m_status == self.m_model.m_status_code.IS_SELF then
            self:requestRecall()
        elseif self.m_model:isInAtkCd() then
            local _, cd_time = self.m_model:isInAtkCd()
            local tim_str = GameUtil:formatTimeBySecond(cd_time, 999)
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("hunt_treasure_str_062", tim_str), delay_close = 2})
            return
        elseif self.m_model.m_status == self.m_model.m_status_code.NEED_BUY and self.m_model.m_robot_id == 0 then --可购买次数
            self:showBuyWindow()
        elseif self.m_model.m_status == self.m_model.m_status_code.NO_TIMES and self.m_model.m_robot_id == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("hunt_treasure_str_049"), delay_close = 2})
            return
        elseif self.m_model:getOccupyOverTimeTips() ~= "" and self.m_model.m_robot_id == 0 then
            GameUtil:lookInfoTips(self, {msg = self.m_model:getOccupyOverTimeTips(), delay_close = 2})
            return
        else
            local function toBattle()
                local region_id =  math.modf(self.m_model.m_oid / 10000)
                local races = GameUtil:getActiveRacesByRegionId(region_id, self.m_model.m_version)
                local def_data = {heros = self.m_model.m_data.heros,
                                  team = self.m_model:getDataByKey("team"),
                                  user = self.m_model.m_user,
                                  deployment = 1,
                                  combat = self.m_model:getDataByKey("combat"),
                                  combat_repress = self.m_model.m_data.combat_repress,
                }
                self:openView("Formation",{region_id = region_id,
                                           def_data = def_data,
                                           races = races,
                                           mode = GlobalConfig.BATTLE_MODE.ACTIVE_MINING,
                                           mine_oid = self.m_model.m_oid,
                                           defend_uid = "",
                                           version = self.m_model.m_version})
            end
            if self.m_model.m_status == self.m_model.m_status_code.CAN_ROB then
                local region_name =  Language:getTextByKey(self.m_model:getRegionName())
                local tips = Language:getTextByKey("hunt_treasure_str_048", region_name)
                local params =
                {
                    on_ok_call = function(msg)
                        toBattle()
                    end,
                    on_cancel_call = function(msg)
                    end,
                    no_close_btn = false,
                    tow_close_btn = true,
                    text = tips,
                }
                static_rootControl:openView("Pops.CommonPop", params, nil, true)
            else
                toBattle()
            end
            
        end
    elseif msg == "refreshData" then
        local remainTimes = self.m_model:getRemainBuyTimes() - data.num;
        local msg = Language:getTextByKey("hunt_treasure_str_031", remainTimes)
        local cost = self.m_model:getBuyCost(data.num)
        self:updateMsg("updateMsgInfo",{ msg= msg, cost = cost[3] },"Pops.CommonBuyPop");
    end
end

function M:requestRecall()
    local function realRequest()
        local function callfunc(response)
            RewardUtil:rewardTipsByData(response.reward or {})
            self:updateMsg("refresh_cur_page",nil,"HuntTreasuresGuild")
            self:updateMsg(99999)
        end
        self.m_model:getNetData("active_mining_recall_team", { team_id = self.m_model.m_data.team_id, ver = self.m_model.m_version }, callfunc)
    end
    local occ_time =  self.m_model:getOccupyTime()
    local min_time = ConfigManager:getCommonValueById(625,4)--最少占领时间 
    if occ_time < min_time * 60 * 60 then
        self:popTips(realRequest)
    else
        realRequest()
    end
   
end

function M:popTips(call_func)
    local min_time = ConfigManager:getCommonValueById(625,4)--最少占领时间 
    local atk_cd = ConfigManager:getCommonValueById(626,60)--进攻惩罚时间
    local params =
    {
        on_ok_call = function(msg)
            call_func()
        end,
        new_cancel_call = function(msg)
        end,
        tow_close_btn = true,
        --cancel_text = Language:getTextByKey("hunt_treasure_str_061",min_time, atk_cd),
        title = Language:getTextByKey("sdk_txt_002"),
        --no_close_btn = true,
        text = Language:getTextByKey("hunt_treasure_str_061",min_time, atk_cd),
    }
    static_rootControl:openView("Pops.CommonPop", params, nil, true)
end

function M:updateTime()
    self.m_view:updateTime()
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
        className = "HuntTreasuresGuild.HuntTreasuresGuildAreaInfoPop",
        --最大购买次数
        m_max_buyNum = remainTimes,
        --消耗类型
        cost_data = cost_data,
        --点击购买
        clickBuy = function( num )
            local function netCallback(response)
                self.m_model.m_buy_plunder = response.buy_plunder;
                self.m_model:getMineStatus()
                self:updateMsg("update_buy_plunder", { buy_plunder = response.buy_plunder },"HuntTreasuresGuild")
                self.m_view:refreshUI();
            end
            self.m_model:getNetData("active_mining_buy_plunder_times", { times = num, ver = self.m_model.m_version } , netCallback)
        end
    }
    self:openView("Pops.CommonBuyPop", params)
end

function M:freshNetData()
    local function receivetCallback(response)
        self.m_model:updateNetData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("active_mining_mine_detail",{mine_oid = self.m_model.m_mine_oid, ver = self.m_model.m_version}, receivetCallback)
end

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
    end
    M.super.destroy(self)
end

return M;
