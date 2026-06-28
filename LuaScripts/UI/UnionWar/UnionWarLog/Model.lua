local M = class("UnionWarLogModel", LikeOO.OODataBase)

local __page_num = 50

function M:onCreate()
    self.m_transfer = "scale"
    M.super.onCreate(self)
    self:getData("gvg_get_last_report");
end

function M:onEnter()
    self.m_union_war_type = self.m_params.union_war_type
    self.showIndex = 1;
    --log类型
    self.log_type = self.m_params.log_type or 1 --1 我方战报，0 敌方战报
    self.log_type_sub = 1 --1 我方全部战报， 0 我方中我的战报
    self.m_open_tab_index = self.m_params.default_tab or 2;
    if self.m_union_war_type ~= 1 and self.m_union_war_type ~= 5 then
        self.m_open_tab_index = 2
        self.m_show_settlement_tab = false
    end
    --上一次战报
    if self.m_params.last_report == nil then
        self.m_last_report = self.m_data.last_report;
    else
        self.m_last_report = self.m_params.last_report;
    end
    self.m_mode = GlobalConfig.BATTLE_MODE.UNIONWAR
    --我的战报
    self.m_own_battle_log = {}
    -- 敌方战报 
    self.m_enemy_battle_log = {}
    
    self.m_last_report = self.m_data.last_report or {}
    --活跃度页
    self.m_active_target_uid = nil
    self.m_active_data = self.m_params.active_data or {}
    self.m_active_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
    self.m_active_position = self:getPosActive(self.m_active_uid)
    self.m_active_target_uid = nil
    self.m_active_is_trans = false
    self.m_like_count = self.m_last_report.like
end

function M:getShowData()
    local vs = self.m_last_report.vs or {}
    if _G.next(vs) == nil then
        return {}
    end
    local cells = self.m_last_report.cells or {}
    local guild_info = self.m_last_report.guild_info;
    local win_guild_name = "";
    local lose_guild_name = "";
    win_guild_name = guild_info[tostring(vs[1])].name;
    lose_guild_name = guild_info[tostring(vs[2])].name;
    local left_gid = vs[1] or ""
    local right_gid = vs[2] or ""
    local show_data = {}
    local guild_war_map_cfg = ConfigManager:getCfgByName("guild_war_map")
    for k, v in pairs(cells) do
        local cell_id = tonumber(k)
        local win = v.win or 0 -- 0:没有胜利的公会
        local t_num = v.t_num or {} -- 队伍数量
        local left_t_num = t_num[tostring(left_gid)] or 0
        local right_t_num = t_num[tostring(right_gid)] or 0
        local left_win = left_gid == win
        local right_win = right_gid == win
        table.insert(show_data, {data = v, cell_id = cell_id, cell_cfg = guild_war_map_cfg[cell_id] or {}, 
                                 left_t_num = left_t_num, 
                                 right_t_num = right_t_num, 
                                 left_win = left_win, 
                                 right_win = right_win,
                                 left_guild = win_guild_name,
                                 right_guild = lose_guild_name,})
    end
    return show_data
end

--初始化战斗信息
function M:initBattleData(data)
    self.m_battle_info_data = data
    if self.log_type == 1 then
        table.insertto(self.m_own_battle_log, data.battle_logs)
    else
        table.insertto(self.m_enemy_battle_log, data.battle_logs)
    end
end

function M:initGuildInfo()
    local data = self.m_battle_info_data
    if data and data.vs ~= nil and data.guild_info ~= nil then
        local own_guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
        local left_index, right_index = 1, 2
        if self.log_type == 1 then --我的战报
            if own_guild_id == data.vs[1] then
                left_index, right_index = 1, 2
            else
                left_index, right_index = 2, 1
            end
        else--敌方战报
            if own_guild_id == data.vs[1] then
                left_index, right_index = 2, 1
            else
                left_index, right_index = 1, 2
            end
        end
        self.m_left_guide_info = data.guild_info[tostring(data.vs[left_index])] or { name = Language:getTextByKey("UnionWar_str_054") }
        self.m_right_guide_info = data.guild_info[tostring(data.vs[right_index])] or { name = Language:getTextByKey("UnionWar_str_053") }
    else
        self.m_left_guide_info = { name = Language:getTextByKey("UnionWar_str_053") }
        self.m_right_guide_info = { name = Language:getTextByKey("UnionWar_str_054") }
    end
end

--是否可以拖拽刷新
function M:canPullRefresh()
    local log_data = self:getLogData()
    local data_num = #log_data
    return data_num > 0 and data_num%__page_num == 0
end

--获取战报数据
function M:getLogData()
    self:initGuildInfo()
    if self.log_type == 1 then
        if self.log_type_sub == 1 then --我方战报
            return self.m_own_battle_log;
        else --我的战报
            local battle_log_mine = {}
            local uid_mine = UserDataManager.user_data:getUserStatusDataByKey("uid")
            for _, item_data in ipairs(self.m_own_battle_log or {}) do
                if item_data.atk_user.uid == uid_mine or item_data.def_user.uid == uid_mine then
                    table.insert(battle_log_mine, item_data)
                end
            end
            return battle_log_mine
        end
    else
        --敌方战报
        return self.m_enemy_battle_log;
        end
end

-- is_def: 敌方1  我方0   page_num: 1    # 一页几个  page: 1       # 页号
function M:getBattleData(net_callback)
    local function callback(response)
        self:initBattleData(response)
        net_callback()
    end
    local is_def = self.log_type == 1 and 0 or 1
    local log_data = self:getLogData()
    local data_num = #log_data
    self:getNetData("gvg_battle_info", {is_def = is_def, page_num = __page_num, page = math.floor(data_num/__page_num) + 1}, callback)
end

function M:getScoreData(net_callback)
    local function callback(response)
        self:initScoreData(response.score_logs)
        net_callback()
    end
    self:getNetData("gvg_get_last_report", {}, callback)
end

--活跃度页
function M:getListDataActive()
    return self.m_active_data.players or {}
end

function M:getPresidentDataActive()
    for i,v in ipairs(self:getListDataActive()) do
        if v.uid == self.m_active_data.guild.president then
            return v
        end
    end
end

function M:getSelfUnionDataActive()
    local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
    for i,v in ipairs(self:getListDataActive()) do
        if self_uid == v.uid then
            return v
        end
    end
end

function M:getIsNPCActive(uid)
    for i,v in ipairs(self.m_active_data.guild.npc) do
        if v == uid then
            return true
        end
    end
    return false
end

--成员管理
function M:updateDataActive(data)
    table.merge(self.m_active_data, data)
    self.m_active_position = self:getPosActive(self.m_active_uid)
end

function M:setTargetMemberActive(uid)
    if self.m_active_target_uid == uid then
        self.m_active_target_uid = nil
        return
    end
    self.m_active_target_uid = uid
    self.m_active_target_position = self:getPosActive(self.m_active_target_uid)
    self.m_active_handle_list = {}
    if GlobalConfig.UNION_POS_HANDLE[self.m_active_position] then
        self.m_active_handle_list = table.copy(GlobalConfig.UNION_POS_HANDLE[self.m_active_position][self.m_active_target_position] or {})
    end
    if self.m_active_uid == self.m_active_target_uid then --不能给自己拉黑名单、发邮件
        for i=#self.m_active_handle_list,1, -1 do
            if self.m_active_handle_list[i] == GlobalConfig.UNION_HANDLE_ID.BLACK or self.m_active_handle_list[i] == GlobalConfig.UNION_HANDLE_ID.SEND_MAIL then
                table.remove(self.m_active_handle_list, i)
            end
        end
    end
end

function M:getPosActive(uid)
    for i,v in ipairs(self.m_active_data.players) do
        if v.uid == uid then
            return v.position
        end
    end
    return 0
end

function M:getMemberDataActive()
    for i,v in ipairs(self.m_active_data.players) do
        if v.uid == self.m_active_target_uid then
            return v
        end
    end
end


function M:getLikeCount()
    return self.m_like_count
end

function M:setLikeCount(count)
    self.m_like_count = count
end

return M