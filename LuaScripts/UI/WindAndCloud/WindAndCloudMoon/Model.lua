---@class DeliciousFeastRankModel: OODataBase
local M = class("WindAndCloudMoonModel", LikeOO.OODataBase)


function M:onCreate()
    self.open_id = self.m_params.open_id or 406
    self:refreshActiveData()
    self.current_show_tab_num = self.m_version --当前展示的页签
    self:getActivePeriods()
    self.m_activityData = UserDataManager:getActivesDataByOpenId(self.m_openId)
    self:getData("active_diamond_rebate_ranks", {open_id = self.open_id,version = self.m_version,start = 1, stop = 10})
end


function M:onEnter()
    --Logger.logError(self.m_data,"九天揽月活动数据~~~~~~~~~~~~~~")
    self:refreshRankData(self.m_data)
end

function M:updateServerData(data,is_new_list)
    table.merge(self.m_data, data or {})
    self:refreshRankData(self.m_data,is_new_list)
end

--计算活动开启期数，固定3个版本号为一期
function M:getActivePeriods()
    local integer,decimal = math.modf(self.m_version/3)
    self.periods_num = decimal > 0 and integer +1 or integer
end

--刷新活动期数显示
function M:refreshActiveData()
    self.m_active_data = self:getActiveData()
    self.m_version = self.m_active_data.version or 1
    self.show_tab_max_num = self.m_version --最大可展示的页签
end

--设置当前显示页签id
function M:setSelectIndex(index)
    self.current_show_tab_num = index
end

--刷新排行榜数据
function M:refreshRankData(m_data,is_new_list)
    if is_new_list then
        self:insertRankData(m_data.ranks,m_data)
    else
        self.roleRankData = m_data.ranks
    end
    self.roleRankCount = m_data.count
    if self.roleRankCount > 0 and table.nums(self.roleRankData) > 0 then
        table.sort(self.roleRankData, function(itemData1, itemData2) return itemData1.rank < itemData2.rank end)
    end
    self.myInfoData = {
        rank = m_data.self_rank,
        score = m_data.self_score,
    }
end

--获取活动数据
function M:getActiveData()
    local active_data = {}
    for i, v in ipairs(UserDataManager.m_actives) do
        if v.open_id == self.open_id then
            table.insert(active_data,v)
        end
    end
    if #active_data == 1 then
        if active_data[1].end_ts < UserDataManager:getServerTime() then
            local new_table_data = self:getActiveCfgToVsn(self.open_id,active_data[1].version + 1)
            if new_table_data then
                return new_table_data
            end
        end
        return active_data[1]
    else
        for i, v in ipairs(active_data) do
            local cur_tim = UserDataManager:getServerTime()
            if v.open_status == 1 and v.end_ts > cur_tim then
                return v
            end
        end
        if active_data[#active_data].end_ts < UserDataManager:getServerTime() then
            local new_table_data = self:getActiveCfgToVsn(self.open_id,active_data[#active_data].version + 1)
            if new_table_data then
                return new_table_data
            end
        end
    end
    --self.active_over = 1
    local new_table_data = self:getActiveCfgToVsn(self.open_id,active_data[#active_data].version,true)
    if new_table_data.end_ts < UserDataManager:getServerTime() then
        self.active_over = 1
    end
    return new_table_data
end

--返回active表里的数据信息
function M:getActiveCfg()
    local active = ConfigManager:getCfgByName("active")
    return active[self.m_active_data.id]
end

--通过open_id和vsn查找数据
function M:getActiveCfgToVsn(open_id,version,change_end_ts)
    local change_end_t = false
    if change_end_ts then
        change_end_t = change_end_ts
    end
    local active = ConfigManager:getCfgByName("active")
    for i, v in pairs(active) do
        if v.open_id == open_id and v.version == version then
            local end_ts = GameUtil:stringToTimesTamp(v.end_time)
            if change_end_t then
                end_ts = GameUtil:stringToTimesTamp(v.show_time)
            end
            local table_times = {
                end_ts = end_ts,
                id = i,
                open_id = open_id,
                open_status = 1,
                start_ts = GameUtil:stringToTimesTamp(v.start_time),
                version = version
            }
            return table_times
        end
    end
end

--获取排名奖励
function M:getRewardInfo(id)
    local diamond_rebate_rank = ConfigManager:getCfgByName("diamond_rebate_rank")
    if diamond_rebate_rank[self.open_id] and diamond_rebate_rank[self.open_id][self.current_show_tab_num] then
        return diamond_rebate_rank[self.open_id][self.current_show_tab_num][id]
    end
    local reward_table = {}
    return reward_table
end

--获取第四名开始的数据
function M:showFourListData()
    local right_list_table = {}
    for i, v in ipairs(self.roleRankData) do
        if i > 3 then
            table.insert(right_list_table,v)
        end
    end
    return right_list_table
end

function M:insertRankData(new_rank_data,rank_info)
    for i = 1, #new_rank_data do
        table.insert(self.roleRankData, new_rank_data[i])
    end
    --self.own_data = {rank = rank_info.rank or 0,score = rank_info.score,user=rank_info.user_info}
end

--获取排行榜刷新开始位置和结束位置
function M:getLoadIndex()
    local max_rank_count = self.m_data.count
    local cur_rank_nums = table.nums(self.roleRankData)
    local start_pos, end_pos = 0, 0
    if cur_rank_nums + 10 <= max_rank_count then
        start_pos = cur_rank_nums + 1
        end_pos = cur_rank_nums + 10
    elseif max_rank_count - cur_rank_nums > 0 then
        start_pos = cur_rank_nums + 1
        end_pos = max_rank_count
    end
    return start_pos, end_pos
end

--判断是否还有数据可刷新
function M:getIsRefreshList()
    local cur_rank_nums = table.nums(self.roleRankData)
    local max_rank_count = self.m_data.count
    if cur_rank_nums == max_rank_count then
        return false --没有可以刷新的数据了
    end
    return true
end

return M
