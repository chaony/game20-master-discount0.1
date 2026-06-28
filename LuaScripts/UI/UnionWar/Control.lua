local M = class("UnionWarControl",LikeOO.OOControlBase)

function M:onEnter()
    self:setOnceTimer(0.2, function()
        local round_report = self.m_model.m_data.round_report or {}
        local last_report = self.m_model.m_data.last_report or {}
        if next(round_report) then
            self:openView("UnionWar.UnionWarSettlement", {round_report = round_report, last_report = last_report})
        end
    end)
    
    --每隔1秒执行一次
    self:setTimer(1,function()
        self.m_view:refreshTimeUI(self.m_model:getTypeEndTime())
        if self.m_model:getRemainTime() <= 0 then
            self.m_model:getNetData("gvg_index", nil, function(response)
                --结束时间
                self.m_model.type_end_time = response.type_end_time
                table.merge(self.m_model.m_data, response)
                self.m_view:refreshUI();
            end)
        end
    end)
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    EventDispatcher:registerEvent("refresh_dfbhz_team_data", {self, self.updateRedPointData})
end
local msg_tab = {new_team_head_bg_1 = 1, new_team_head_bg_2 = 2, new_team_head_bg_3 = 3, new_team_head_bg_4 = 4, new_team_head_bg_5 = 5,}
function M:onHandle(msg , data)
    if msg == 99999 or msg == "new_close_btn" then
        self:closeView()
    elseif msg == "gotobattle_btn" then --前往战场
        self:goUnionWar()
    elseif msg == "new_gotobattle_btn" then --前往战场
        local m_data = self.m_model:getGuildHighWarData()
        local ghw_stage = m_data.ghw_stage
        local is_watch = m_data.is_watch
        local round_id = m_data.round_id
        self:openView("GuildHighWar.GuildHighWarMain", {is_watch = is_watch, ghw_stage = ghw_stage ,round_id = round_id})
        self:closeView()
    elseif msg == "log_btn" then --战报
        local function callback(response)
            self:openView("UnionWar.UnionWarLog", {union_war_type = self.m_model.m_data.type, active_data = response})
        end
        self.m_model:getNetData("guild_index", nil, callback)
    elseif msg == "rank_btn" then --排行榜、
        self:openView("UnionWar.UnionWarRank")
    elseif msg == "team_btn" or msg == "team_head_bg_1" then --编队1
        self:teamLocking(1)
    elseif msg == "team_head_bg_2" then --编队2
        self:teamLocking(2)
    elseif msg == "team_head_bg_3" then --编队3
        self:teamLocking(3)
    elseif msg == "explain_btn" then --规则说明
        self:openView("Pops.CommonHelpPop", { title = "tid#GuildWar_2", content = "tid#GuildWar_1" })
    elseif msg == "reward_btn" then --奖励说明
        self:openView("UnionWar.UnionWarRewardPop")
    elseif msg == "new_btn" then
        --if self.m_model.ghw_stage <= 1 then
        --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_00102"), delay_close = 2})
        --    return
        --end
        --if self.m_model.invite_data and  self.m_model.ghw_stage == 2 then --够资格 邀请函
        --    self:openView("GuildHighWar.GuildHighWarInvitePop",{invite_data = self.m_model.invite_data,start_time = self.m_model.start_time,end_time = self.m_model.end_time})
        --    self:closeView()
        --    return
        --end
        --if not self.m_model.invite_data and self.m_model.ghw_stage == 2 then --邀请阶段 和不够资格
        --    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_00101"), delay_close = 2})
        --    return
        --end
        if self.m_model.big_stage <= 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_00102"), delay_close = 2})
            return
        end
        if self.m_model.end_guild_rank and self.m_model.end_self_rank then
            self:openView("GuildHighWar.GuildHighWarSettIementPop",{end_guild_rank = self.m_model.end_guild_rank,end_self_rank = self.m_model.end_self_rank,big_stage = self.m_model.big_stage,
                                                                    playoff_type = self.m_model.m_data.guild_high_war.playoff_type})
            self:closeView()
            return 
        end
        --第一种
        --self:openView("GuildHighWar.GuildHighWarNewMain",{guild_high_war = self.m_model.m_data.guild_high_war})
        --第二种
        self:openView("GuildHighWar.GuildHighWarNewMainYan")
        --self:changePanel(2)
    elseif msg == "old_btn" then
        self:changePanel(1)
    elseif msg == "new_help_btn" then
        self:openView("Pops.CommonHelpPop", { title = "guild_high_war_text_0001", content = "tid#guild_high_tips" })
    elseif msg == "new_log_btn" then
        self:openView("GuildHighWar.GuildHighWarTotalLogPop")
    elseif msg == "new_rank_btn" then
        self:openView("GuildHighWar.GuildHighWarRankList",{rank_sort = self.m_model.m_is_high_ob == true and 3 or 1})
    elseif msg == "refresh_ui" then 
        self.m_view:refreshUI()
    elseif msg_tab[msg] then
        if self.m_model.ghw_stage == 3 or self.m_model.ghw_stage == 4 or self.m_model.ghw_stage == 6 then
            local team_index = msg_tab[msg]
            self:teamLockingNew(team_index)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("guild_high_war_text_0092"), delay_close = 2})
            return
        end
    elseif msg == "refresh_data" then

    end
end

function M:updateRedPointData()
    self.m_model:getNetData("gvg_index",nil,function(response)
        self.m_model.m_data.guild_high_war = response.guild_high_war
        self.m_view:refreshUI()
    end)
end
function M:changePanel(index)
    if self.m_model.m_cur_index == index then
        return
    end
    self.m_model.m_cur_index = index
    self.m_view:refreshUI()
end

--编队锁定
function M:teamLocking(team_num)
    self.m_model:updateTeamRewardStatusJustForTeamSet()
    local m_data = self.m_model:getUnionWarInfo()
    if m_data.type == 2 or m_data.type == 3 or m_data.type == 4 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuildWar_13"), delay_close = 2})
    else
        if self.m_model.m_cur_index == 1 then
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.UNIONWAR_DEFENSE, formation_index = team_num})
        else
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR, formation_index = team_num})
        end
    end
end
--巅峰帮会战编队锁定
function M:teamLockingNew(team_num)
    local m_data = self.m_model:getGuildHighWarData()
    --if m_data.ghw_stage == 2 or m_data.ghw_stage == 3 then
        --GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuildWar_13"), delay_close = 2})
    --else
        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.GUILD_HIGH_WAR, formation_index = team_num})
    --end
end

function M:goUnionWar()
    local m_data = self.m_model:getUnionWarInfo()
    if m_data.type == 1 then --可以报名
        if m_data.is_sign == false then--还没有报名
            self.m_model:getNetData("gvg_sign_up", nil, function(response)
                m_data.is_sign = response.is_sign
                table.merge(self.m_model.m_data, response)
                self.m_view:refreshTimeUI(self.m_model:getTypeEndTime())
                self.m_view:refreshUnionWarInfo(self.m_model.m_data)
                self:updateMsg("refreshRedPoint", nil, "Union.UnionMain")
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuildWar_7"), delay_close = 2})
            end)
        else--已经报名
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuildWar_3"), delay_close = 2})
        end
    elseif m_data.type == 2 then --匹配阶段
        if m_data.is_sign == true then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuildWar_5"), delay_close = 2})
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuildWar_4"), delay_close = 2})
        end
    elseif m_data.type == 3 then --驻扎阶段
        if m_data.is_sign == true then
            QuickOpenFuncUtil:openFunc(35)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuildWar_4"), delay_close = 2})
        end
    elseif m_data.type == 4 then --战斗阶段
        if m_data.is_sign == true then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuildWar_6"), delay_close = 2})
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuildWar_4"), delay_close = 2})
        end
    elseif m_data.type == 5 then --休赛阶段
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#GuildWar_12"), delay_close = 2})
    end
end

function M:closeViewEvent(event, data)
    local view_name = data.name or ""
   if view_name == "UnionWar.UnionWarMain" then
       self.m_model:getNetData("gvg_index",nil,function(response)
           table.merge(self.m_model.m_data, response)
           self.m_view:refreshUI()
       end)
    end
end

function M:dataUpdateEvent(event, data)
    if data.event == "red_dot_update" then
        self.m_view:refreshRedPoint()
    elseif data.event == "gvg_teams_update" then --编队数据回调刷新
        self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refreshRedPoint" ,nil ,"Main.TotalWorld")
        self.m_view:refreshTeamInfo()
        self.m_model:updateTeamRewardStatus(function()self.m_view:refreshTeamSetRewardInfo()  end)
    elseif data.event == "gvg_team_set_reward" then --编队设置奖励回调展示
        self:checkTeamSetReward()
    end
end

function M:checkTeamSetReward()
    local reward_data = UserDataManager:getGvgTeamSetReward()
    RewardUtil:rewardTipsByData(reward_data)
    UserDataManager:resetGvgTeamSetReward()
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.CLOSE_VIEW, {self, self.closeViewEvent})
    EventDispatcher:unRegisterEvent("refresh_dfbhz_team_data", {self, self.updateRedPointData})
    M.super.destroy(self)
end

return M