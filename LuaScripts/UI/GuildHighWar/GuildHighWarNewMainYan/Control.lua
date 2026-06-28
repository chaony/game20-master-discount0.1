local M = class("GuildHighWarNewMainYanControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        --self:updateMsg("update_top_rank", self.m_model.m_data.cur_rank,"LingCloud")
        self:closeView()
        --------------------------
    elseif msg == "switch_tab" then
        self:switchTabBtn(data.index, data.cell_object)
    elseif msg == "peak_game_btn" or msg == "peak_game_btn2" then --进入
        self:checkGameBtn()
    elseif msg == "report_btn" then --战报
        if self.m_model.round_id == 1 then -- 第一回合 
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
        --self:openView("GuildHighWar.GuildHighWarTotalLogPop")
    elseif msg == "rank_btn" then --排行
        if self.m_model.big_stage == 3 and self.m_model.playoff_type == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_new_0046"), delay_close = 2})
            return
        end
        --local function netCallback(response)
        --    self.m_model.m_guild_info = response.guild_info
        --    self.m_model.m_city_data = response.citys
        --    self:openView("GuildHighWar.GuildHighWarRankList",{rank_sort = 1,total_city_data = self.m_model.m_city_data,
        --                                                       total_guild_data = self.m_model.m_guild_info ,
        --                                                       big_stage = self.m_model.big_stage,playoff_type = self.m_model.playoff_type})
        --end
        --self.m_model:getNetData("guild_high_war_battlefield", nil, netCallback)
        self:openView("GuildHighWar.GuildHighWarRankList",{rank_sort = 1,total_city_data = self.m_model.m_city_data,
                                                           total_guild_data = self.m_model.m_guild_info ,
                                                           big_stage = self.m_model.big_stage,playoff_type = self.m_model.playoff_type})
    elseif msg == "array_btn" then --布阵
        --if self.m_model.ghw_stage == GlobalConfig.SERVER_GHW_STAGE.FORMATION or self.m_model.ghw_stage == GlobalConfig.SERVER_GHW_STAGE.DECLARE then
        --    self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR, formation_index = 1})
        --    --self:updateMsg("new_team_head_bg_1",nil,"UnionWar")
        --else
        --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_0092"), delay_close = 2})
        --end
        self:openView("Shop", {shop_type = 34}) --巅峰商店
    elseif msg == "update_stage" then
        local function netCallback(response)
            if response then
                self.m_model:UpdateWarData(response)
                self.m_view:refreshUI()
                self.m_model.is_can_updata = false
            end
        end
        self.m_model:getNetData("guild_high_war_index", nil, netCallback)
        ------------------------------------------------------------------
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshUI()

    elseif msg == "set_battle_array_btn" then --布阵
        if self.m_model:checkTeamLock() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0007"), delay_close = 2})
            return
        end
        self:openView("Arena.ArenaHigher.ArenaHigherDefendTeam", {top_arena = true})
    elseif msg == "hint_btn" then
        self:openView("Pops.CommonHelpPop", { title = "guild_high_war_text_0001", content = "tid#guild_high_tips" })
    elseif msg == "zan_btn_1" then
        self:sendZanBtn(1)
    elseif msg == "zan_btn_2" then
        self:sendZanBtn(2)
    elseif msg == "zan_btn_3" then
        self:sendZanBtn(3)
    elseif msg == "refreshUI" then
        self.m_view:refreshUI()
    elseif msg == "shop_btn" then
        self:openView("Shop", {shop_type = 6})
    elseif msg == "reward_btn" then
        if self.m_model:checkHasData() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0062"), delay_close = 2})
            return
        end
        if self.m_model:checWeekBl() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
            return
        end
        if self.m_model:checkOpenType() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
            return
        end
        if self.m_model:checkCanClick() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0008"), delay_close = 2})
            return
        end
        self:openView("PeakArena.PeakArenaRankListPop", {open_type = self.m_model:checkOpenType()})
    elseif msg == "guess_btn" then
        --if self.m_model:checkHasData() == false then
        --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0062"), delay_close = 2})
        --    return
        --end
        --if self.m_model:checWeekBl() == false then
        --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
        --    return
        --end
        --if self.m_model:checkOpenType() == false then
        --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
        --    return
        --end
        --if self.m_model:checkCanClick() == false then
        --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0008"), delay_close = 2})
        --    return
        --end 
        --UserDataManager:removeRedDotByKey("top_arena_guess")
        --self.m_view:refreshRedPoint()
        --self:openView("PeakArena.PeakMyGuessPop", {top_data = self.m_model.m_data})
    elseif msg == "updateGress" then
        self.m_view:refreshUI()
        -----new
    elseif msg == "reward_preview_btn" then
        --self:openView("GuildHighWar.GuildHighWarMachineMain")
        --self:openView("GuildHighWar.GuildHighWarMachineMain.GuildHighWarThreeWorld")
        self:openView("GuildHighWar.GuildHighWarNewMain",{guild_high_war = self.m_model.guild_high_war})
    elseif msg == "help_btn" then
        self:openView("Pops.CommonHelpPop", { title = "guild_high_war_text_0001", content = "tid#guild_high_tips" })
    elseif msg == "get_day_btn" then --分享
        self:openView("GuildHighWar.GuildHighWarSharePop")
    elseif msg == "is_share" then --是否分享
        self.m_model.is_share = data.is_share or 0
        self.m_view:UpdateShareView()
    elseif msg == "update_share_bg" then
        self.m_view:UpdateShareBg(data)
        self:updateMsg("update_share_bg",nil,"GuildHighWar.GuildHighWarSharePop")
    elseif msg == "vedio_btn" then
        self.m_view:checkAndPlayVideo(true)
    end
  
end

function M:sendZanBtn(index)
    local function netCallback(response)
        if response.reward then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model.m_data.like_data = response.like_data
            self.m_model:updateLikeNumByIndex(index,response.like)
            self.m_view:refreshUI()
        end
    end
    local target_uid = self.m_model:getTopPlayerByIndex(index)
    if self.m_model:checkLickData(target_uid) == true then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0059"), delay_close = 2})
        return
    end
    local params = {
        target_uid = self.m_model:getTopPlayerByIndex(index),
    }
    self.m_model:getNetData("top_arena_like", params, netCallback)
end

--检测战斗结果
function M:checkBattleResult(callback)
    local top_arena_data = UserDataManager.local_data:getUserDataByKey("top_arena_result", {})
    if self.m_model:checkCanClick() == true and top_arena_data and next(top_arena_data) ~= nil and top_arena_data.season == self.m_model.m_data.season then
        if top_arena_data.step == 6 and top_arena_data.win == 1 then
            callback()
        else
            self:openView("PeakArena.PromotedPop", {cb = callback, top_arena_data = top_arena_data})
            UserDataManager.local_data:setUserDataByKey("top_arena_result", {})
        end
    else
        callback()
    end
end

--检测前三展示
function M:checkTopWinner()
    if self.m_model:checkTopArenaFinal() == true then
        self:openView("PeakArena.PeakArenaResultPop", self.m_model.m_data, function ()
            self:checkGuessTips()
        end)
        UserDataManager.local_data:setUserDataByKey("top_arena_final", {})
    else
        self:checkGuessTips()
    end
end

function M:checkGuessTips()
    if self.m_model:getGuessAlert() > 0 then
        local team_id = self.m_model:getGuessAlert()
        self:openView("PeakArena.GuessTipsPop", {team_id = team_id })
    end
end
---------------------------------
-- tab按钮切换
function M:switchTabBtn(index,obj)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index,obj)
    end
end

function M:checkGameBtn()
    if self.m_model.ghw_stage == GlobalConfig.SERVER_GHW_STAGE.MATCH and self.m_model.is_sign_up == 0  then --特殊处理匹配阶段  没有报名 匹配阶段
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("guild_high_war_new_0039"), delay_close = 2})
        return
    elseif self.m_model.ghw_stage == GlobalConfig.SERVER_GHW_STAGE.MATCH and self.m_model.is_sign_up == 1 then--特殊处理匹配阶段第二轮  有报名 匹配阶段
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("guild_high_war_new_0040"), delay_close = 2})
        return
    end
    if self.m_model.is_sign_up == 0 then --没有报名 需要报名
        local function netCallback(response)
            if response then
                self.m_model.is_sign_up = response.is_sign_up
                self.m_view:updateButtonstage()
            end
        end
        self.m_model:getNetData("guild_high_war_new_sign_up", nil, netCallback)
    elseif self.m_model.big_stage == 1 then  --第一阶段已经报名过了
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("guild_high_war_new_0021"), delay_close = 2})
        return
    elseif self.m_model.is_sign_up == 1 and self.m_model.is_condition == 0 then --已报名不够资格
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("guild_high_war_new_0029"), delay_close = 2})
        return
    elseif self.m_model.big_stage == 2 or self.m_model.big_stage == 3 then
        if self.m_model.is_go_game == false then
            self.m_model.is_go_game = true
            local m_data = self.m_model:getGuildHighWarData()
            local ghw_stage = m_data.ghw_stage
            local is_watch = m_data.is_watch
            local round_id = m_data.round_id
            local playoff_type = m_data.playoff_type
            self.m_view:CreateMenEnd()
            self.timer_id = self:setOnceTimer(1, function ()
                self:openView("GuildHighWar.GuildHighWarMain", {is_watch = is_watch, ghw_stage = ghw_stage ,round_id = round_id,playoff_type =playoff_type })
                self.timer_id = nil
                self.m_view:ClearMenEnd()
                self.m_model.is_go_game = false
            end)
            --self:closeView()
        end
    elseif self.m_model.big_stage == 3 then

    end
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end



function M:destroy()
    M.super.destroy(self)
    self:removeTimer(self.m_timer_id)
end
return M
