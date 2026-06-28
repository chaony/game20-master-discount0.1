local M = class("GuildHighWarMainControl",LikeOO.OOControlBase)

function M:onEnter()
    --self:updateRankData()
    if SceneManager.curScene.sceneId == SceneManager.SceneID.GuildHighWar then
        SceneManager.curScene:resetSceneData( { parent_model = self.m_model } )
    else
        SceneManager:changeScene(SceneManager.SceneID.GuildHighWar, { parent_model = self.m_model }, false);
    end
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("close_view",nil,"GuildHighWar.GuildHighWarMachineMain")
        self:updateMsg("close_view",nil,"GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff1")
        self:updateMsg("close_view",nil,"GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff2")
        self:updateMsg("close_view",nil,"GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineBuff3")
        self:updateMsg("close_view",nil,"GuildHighWar.GuildHighWarMachineMain.GuildHighWarThreeWorld")
        self:updateMsg("close_view",nil,"GuildHighWar.GuildHighWarMachineMain.GuildHighWarMachineLevelPop")
        self:closeView()
        audio:SendEvtBGM("Set_State_TianXia")
    elseif msg == "main_refresh_ui" then
        self.m_view:refreshUI()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshUI()
    elseif msg == "click_city" then
        if data then
            local city_data = self.m_model:getCityInfoById(data)
            local guild_data = self.m_model.m_guild_info
            local ghw_stage = self.m_model.m_ghw_stage
            local is_watch =  self.m_model.m_is_watch
            local position =  self.m_model.m_position
            local m_declare_times = self.m_model.m_declare_times
            self:openView("GuildHighWar.GuildHighWarCityPop", { city_id = data,
                                                                city_data = city_data,
                                                                guild_data = guild_data,
                                                                position = position,
                                                                ghw_stage = ghw_stage,
                                                                is_watch = is_watch,
                                                                m_declare_times = m_declare_times})
        end
    elseif msg == "pop_log" then
        self:openView("GuildHighWar.GuildHighWarResultPop", {pop_log = self.m_model.m_pop_log})
    elseif msg == "main_refresh_red_point" then
        self.m_view:refreshRedPoint()
    elseif msg == "refreshData" then
    elseif msg == "task_btn" then
        self:openView("Pops.CommonHelpPop", { title = "tid#QMDJ_dec_01", content = "tid#QMDJ_dec_02" })
    elseif msg == "battle_team_btn" then
        self:openView("GuildHighWar.GuildHighWarBattleTeamPop", {total_city_data = self.m_model.m_city_data,
                                                                 total_guild_data = self.m_model.m_guild_info ,
                                                                 city_id = self.m_model.m_my_city_id,parent_model = self.m_model,
                                                                 position = self.m_model.m_position}) --我的队伍

    elseif msg == "log_btn" then
        if self.m_model.m_round_id == 1 then -- 第一回合 
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_0080"), delay_close = 2})
            return
        end
        if self.m_model.m_is_watch == 1 then --观战
            self:openView("GuildHighWar.GuildHighWarTotalLogPop")
        elseif self.m_model.m_is_watch == 0 then --不是观战
            self.m_model:getNetData("guild_high_war_battle_logs", {is_self = 1}, function(response)
                if response then
                    self:openView("GuildHighWar.GuildHighWarResultPop", {pop_log = response})
                end
            end, nil, nil, nil)
        end
    elseif msg == "rank_btn" then
        self:openView("GuildHighWar.GuildHighWarCityRankList",{rank_sort = 4,total_city_data = self.m_model.m_city_data,
                                                               total_guild_data = self.m_model.m_guild_info ,
                                                               big_stage = self.m_model.big_stage,playoff_type = self.m_model.playoff_type})
        --self:openView("GuildHighWar.GuildHighWarSettIementPop")
    elseif msg == "reward_btn" then -- 提示语
        --self:openView("GuildHighWar.GuildHighWarRewardPop", {total_city_data = self.m_model.m_city_data,
        --                                                     total_guild_data = self.m_model.m_guild_info ,
        --                                                    is_watch = self.m_model.m_is_watch})
        self:openView("Shop", {shop_type = 34}) --巅峰商店
    elseif msg == "edit_team_btn" then
        self:openView("GuildHighWar.GuildHighWarTaskPop")
        --self:openView("GuildHighWar.GuildHighWarTeamPop", {city_id = self.m_model.m_my_city_id,parent_model = self.m_model})
    elseif msg == "udpate_declare" then
        self.m_model:updateDeclareTimes(data)
        self.m_view:updateAtkTimes()
    elseif msg == "change_scene" then
        if data and data.result == 1 then
            local battle_ret_data = data.battle_ret_data
            if battle_ret_data then
                self.m_model:netData(battle_ret_data)
            end
            self.m_model:updateLockOne(data.result)
            self.m_view:refreshUI()
            self:updateMsg("show_monster_messag") --战斗胜利时，需要选择打扫战场的英雄
        end
        SceneManager:changeScene(SceneManager.SceneID.QiMenDunJiaScene, self.m_model:getMainData(), false);
        if data then
            local status_code = data.status
            if status_code and tostring(status_code) == "58009" then
                self:setOnceTimer(1,function()
                    self:qmdjGridRefreshReq()
                end)
            end
        end
    elseif msg == "btn_playerPos" then
        if (SceneManager.curScene ~= nil) then
            SceneManager.curScene:recoverViewByPlayerPos()
        end
    elseif msg == "change_btn" then
        --self.m_model:setShowStatus()
        --self.m_view:updateBtnStatus()
    elseif msg == "chat_tab_btn" then
        --if data ~= self.m_model.m_cur_channel_id then
        self.m_model.m_cur_channel_id = data or self.m_model.m_cur_channel_id
        local msgs = self.m_model:getChatMsgByChannel(data)
        self.m_view:updateChatScroll(msgs)
        self.m_view:refreshPrivateChatRedPoint()
        --end
    elseif msg == "chat_show_btn" then
        self.m_model.m_chat_show = false
        self.m_view:showChatDetailNode()
    elseif msg == "chat_btn2" then
        self.m_model.m_chat_show = true
        self.m_view:showChatDetailNode()
    elseif msg == "open_chat_btn" then
        self:openView("Chat", {channel_id = self.m_model.m_cur_channel_id, open_type ="guild_high_war"})
    elseif msg == "update_city_data" then
        if data then
            self.m_model:updateCityData(data)
            self.m_model:InitLinesOwerData()
            self.m_view:refreshUI()
            SceneManager:getCurSceneModel():refreshBrand();
        end
    elseif msg == "guild_show_btn" then
        self.m_model.m_guild_show = not self.m_model.m_guild_show
        self.m_view:updateGuildView()
    elseif msg == "map_btn" then
        self:openView("GuildHighWar.GuildHighWarMap", {parent_model = self.m_model})
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", { title = "tid#guild_high_name", content = "tid#guild_high_tips" })
    elseif msg == "refresh_screen_data" then --刷新场景
        if SceneManager.curScene.sceneId == SceneManager.SceneID.GuildHighWar then
            SceneManager.curScene:resetSceneData( { parent_model = self.m_model } )
        else
            SceneManager:changeScene(SceneManager.SceneID.GuildHighWar, { parent_model = self.m_model }, false);
        end
    elseif msg == "refresh_red_point" then
        self.m_view:UpdataRedPoint()
    elseif msg == "double_btn" then
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("guild_high_war_new_0041"), delay_close = 2})
        --------燕过风云
    elseif msg == "threeworld_btn" then
        --self:openView("GuildHighWar.GuildHighWarMachineMain")
        self:openView("GuildHighWar.GuildHighWarMachineMain.GuildHighWarThreeWorld")
    end
end

function M:onrefreshPrivateRedPoint()
    if not(self.m_model.m_chat_show)  then
        self.m_view:refreshPrivateChatRedPoint()
    end
end

function M:requestUnion()
    local function callback(response)
        local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
        if guild_id and guild_id > 0 then
            self:openView("Union.UnionMain", response)
        else
            self:openView("Union.UnionIndex", response)
        end
    end
    self.m_model:getNetData("guild_index", nil, callback)
end

function M:showBuyStrengthWindow()
    local remain_times = self.m_model:getRemainBuyTimes()
    local params =
    {
        --内容
        msg = Language:getTextByKey("jubaoShan_str_005",self.m_model:getVip(), remain_times),
        --标题
        title = Language:getTextByKey("qi_men_dun_jia_str_028"),
        --通知的类名
        className = "QiMenDunJia.QiMenDunJiaMain",
        --最大购买次数
        m_max_buyNum = remain_times,
        --消耗类型
        cost_data = self.m_model:getCostType(),
        --消耗
        cost = self.m_model:getCost(1),
        --点击购买
        clickBuy = function( num )
            local function netCallback(response)
                --self.m_model:updateBuyTimes(response.buy_times)
                --self.m_model:updateStrength(response.health)
                self.m_view:refreshUI();
            end
            local params = {}
            params.times = num
            params.ver = self.m_model:getVersion()
            self.m_model:getNetData("gve_buy_health", params, netCallback)
        end
    }
    self:openView("QiMenDunJia.QiMenDunJiaBuyStrength", params)
end

--请求主数据更新
function M:requestForMainDataUpdate()
    local function netCallback(response)
        if response then
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("gve_index", nil, netCallback)
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    --ChatUtil:updateLocalMsg()
    M.super.destroy(self)
end

return M
