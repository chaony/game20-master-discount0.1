local M = class("UnionWarModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    M.super.onCreate(self)    
    self:getData("gvg_index")
end

function M:onEnter()
    --工会数据
    self.m_unionData = self.m_params.union_data;
    self.m_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
    --各个阶段时间
    --结束时间
    self.type_end_time = self.m_data.type_end_time
    -- 赛季阶段，0:未开始，1：报名-准备阶段，2：匹配阶段，3: 战斗阶段，4：结算阶段，5：休赛阶段，下个赛季未开始
    --self.m_data.type
    --我在工会中的位置
    self.m_position = self:getPos(self.m_uid);
    UserDataManager:setGvgTeams(self.m_data.gvg_teams)
    local ghw_teams = self.m_data.guild_high_war and self.m_data.guild_high_war.teams or {}
    UserDataManager:setGuildHighWarTeams(ghw_teams)
    local guild_high_war_base = ConfigManager:getCfgByName("guild_high_war_base") or {}
    self.m_ghw_cfg = guild_high_war_base[UserDataManager:getCurSeason()] or {}
    
    --是否展示队伍设置奖励
    self.m_has_team_reward = self.m_data.has_team_gift
    self.m_cur_index = 1
    self.m_is_open_high = true--巅峰公会战
    local is_watch = self.m_data.guild_high_war and self.m_data.guild_high_war.is_watch or 0
    self.m_is_high_ob = is_watch == 1 --巅峰公会战观战模式
    self.ghw_stage = self.m_data.guild_high_war.ghw_stage or 1
    self.end_guild_rank = self.m_data.guild_high_war.end_guild_rank or nil
    self.end_self_rank = self.m_data.guild_high_war.end_self_rank or nil
    --self.my_teams = self.m_data.guild_high_war.teams or {}
    -- 邀请函数据
    self.invite_data = self.m_data.guild_high_war.invite_data or nil
    self.show_letter = self.m_data.guild_high_war.show_letter or 0
    self.start_time = self.m_data.guild_high_war.type_start_time or 0
    self.end_time = self.m_data.guild_high_war.type_end_time or 0
    self.big_stage = self.m_data.guild_high_war.big_stage or 0
end


function M:getCurrentRedPoint()
    local red_flag_ = false
    -- 战报红点
    local red_flag = RedPointUtil:localRedPointJudge("guild_zhan_bao")
    if red_flag then 
        return true
    end
    --self:setObjectVisible("log_btn_red_point_img",red_flag)
    --参与队
    local team_flag = RedPointUtil:hasRedPointById(295)
    if team_flag then
        return true
        --self:setObjectVisible("battle_team_btn_red_point_img",team_flag)
    end
    return red_flag_
end
--获取剩余时间
function M:getRemainTime()
    local time = self.type_end_time - UserDataManager:getServerTime()
    return time;
end


--获取各个阶段结束时间
function M:getTypeEndTime()
    local time = self:getRemainTime();
    local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)
    if day > 0 then
        hour = hour + day * 24;
    end
    return string.format("%02d:%02d:%02d", hour, min, sec)
end


function M:getUnionWarInfo()
    return self.m_data 
end

function M:getGuildHighWarData()
    return self.m_data.guild_high_war or {}
end

function M:getPos(uid)
    for i,v in ipairs(self.m_unionData.players) do
        if v.uid == uid then
            return v.position
        end
    end
    return 0
end

function M:updateTeamRewardStatus(netCallback)
    local function callback(response)
        if response then
            self.m_has_team_reward = response.has_team_gift
        end
        if netCallback then
            netCallback()
        end
    end
    self:getNetData("gvg_index", nil, callback)
end

--设置的此变量只用来判断队伍设置退出的时候是否向服务器发送队伍变更消息
--单纯有队伍设置奖励没领，也需要在退出时发这个消息
function M:updateTeamRewardStatusJustForTeamSet()
    UserDataManager:setGvgTeamSetRewardFlag(self.m_has_team_reward)
end

function M:getTeamSetRewardStatus()
    return self.m_has_team_reward
end

function M:getTeamSetStatus(index)
    if self.m_data.type == 2 or self.m_data.type == 3 or self.m_data.type == 4 then --不能设置队伍时，不展示红点
        return true
    end
    local teams = UserDataManager:getGvgTeamsByKey("def_teams")
    local team = teams[tostring(index)]
    if team and team.team and team.team[1] ~= "" then
        return true
    end
    return false
end

function M:getNewTeamSetStatus(index)
    if self.m_data.guild_high_war.ghw_stage == 1 or self.m_data.guild_high_war.ghw_stage == 2 or self.m_data.guild_high_war.ghw_stage == 5 then --不能设置队伍时，不展示红点
        return false
    end
    --local teams = UserDataManager:getGvgTeamsByKey("def_teams")
    if  not self.m_data.guild_high_war.teams then return false end
    local team = self.m_data.guild_high_war.teams[tostring(index)]
    if team and team.team then
        for k,v in ipairs(team.team) do
            if v == "" then 
                return true
            end
        end
    else
        return true
    end
    return false
end

function M:getTotalStage()
    local nums = 0
    if next(self.m_ghw_cfg) then
        nums = self.m_ghw_cfg.battle_cycle[2] - self.m_ghw_cfg.plan_cycle[2]
    end
    return nums
end

function M:getRankData()
    local rank_data = {}
    if self.m_data.guild_high_war and self.m_data.guild_high_war.watch_ranks then
        rank_data = self.m_data.guild_high_war.watch_ranks.ranks or {}
    end
    return rank_data
end

return M