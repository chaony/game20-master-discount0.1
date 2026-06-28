---@class RewardModel:OODataBase
local M = class("RewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
     self:getData("bounty_bounty_index")
    --self:getData("big_map_plunder_station")
    
end
--驻地列表
M.map_station_data = {}

M.m_open_tab_index = 1

M.m_heros = {}
function M:onEnter()
    self.cur_type = 1 --当前页签
    self.m_sel_tab_index =  nil
    self.m_data_cache = {}
    self.map_bounty_data = {}
    self.m_open_tab_index = 1
    local heroIds = table.copy(UserDataManager.hero_data:getHerosId())
    if self.m_filter_func then
        heroIds = self.m_filter_func(heroIds)
    end
    self.toDay_active = true
    self.toDay_HasHighLevelTasks = true
    self.callback_time = nil
    self.callback_tasts = nil --紫色品阶显示
    self.m_heros = heroIds
    self.m_select = heroIds[1]
    self.isSort = true
    self.task_temp_list = {}

    self:initData(self.m_params.map_indexData, true)
    
end

function M:initData(data, reset_sort)
    if data then 
        self.m_data = data
    end
    self.self_hero = {} --己方已上阵英雄
    self.resh_tim = self.m_data.next_time
    self.now_tim = UserDataManager:getServerTime()
    self.dataTime =  self.resh_tim - self.now_tim --刷新的倒计时
    self.bounty_lv = self.m_data.level
    self.m_master_info = self.m_data.master_info or {}
    self.free_refresh = self.m_data.free_refresh --每天可免费刷新的次数
    self.pay_refresh = self.m_data.pay_refresh --付费刷新次数
    if self.pay_refresh == 0 then
        self.pay_refresh = 1
    end
    self.common = ConfigManager:getCfgByName("common")

    self:initSingleData(reset_sort)
    self:initMasterApprenticeData()
    self:init_Rank()
end
function M:isMaxTime()
    local max_times = self:getMaxTimes()
    local cur_times = self.m_data.pay_refresh or 0
    local is_max_time = false
    if max_times == 0 then
    elseif cur_times >= max_times then
        is_max_time = true
    end
    return is_max_time
end

function M:getMaxTimes()
    local max_times = ConfigManager:getCommonValueById(447,0)
    return max_times
end
function M:refreshinitData(data)
    self.m_data.single_quest = data.single_quest
    self.m_data.team_quests = data.team_quests
    self.m_data.master_quests = data.master_quests
    self.m_data.single_his_done = data.single_his_done
    self.m_data.unlock_num = data.unlock_num
    if data.quests_counter then
        self.quests_counter = data.quests_counter --任务计数器  {任务id: 次数}
    end
    if data.single_rank then
        self.single_rank = data.single_rank -- 个人任务品质计数器   {品质: 次数}
    end
    if data.single_rank then
        self.team_rank = data.team_rank -- # 团队任务品质计数器   {品质: 次数}
    end
 
    if data.up_level == true and self.bounty_lv + 1 > self:getMaxLv() then
        self.bounty_lv = self.bounty_lv + 1
    end
    self.single_data = {}
    self.resh_tim = self.m_data.next_time
    self.now_tim = UserDataManager:getServerTime()
    self.dataTime =  self.resh_tim - self.now_tim --刷新的倒计时
    self:initSingleData()
end

function M:getMaxLv()
	local bounty_lv = ConfigManager:getCfgByName("bounty_lv")
	return table.nums(bounty_lv) 
end

function M:getHeroDataByIndex(index)
    return self.m_heros[index]
end
function M:setSelectHero(oid)
    self.m_select = oid
end

function M:initSingleData(reset_sort)
    local single = self.m_data.single_quest or {}
    local team_quests = self.m_data.team_quests or {}
    local master_quests = self.m_data.master_quests or {}
    local TEST_TAB = {}
    local list = {}
    local quest_main = ConfigManager:getCfgByName("bounty_quest")
    for k,v in pairs(single) do
        local task = {}
        task.id = tonumber(k)
        task.cur_sort = self.task_temp_list[task.id] or 0
        task.data = v
        task.cfg = quest_main[task.id]
        if task.data and task.data.quest_status and task.data.quest_status == 1 then --任务进行中
            local start_ts = task.data.start_ts
            local task_tim = self.now_tim - start_ts--任务进行的时间
            task.count_down = task.cfg.duration_time * 60 - task_tim
        end
        if v.self_hero then
            for k,vv in pairs(v.self_hero) do
                table.insert(self.self_hero, vv)
            end
        end
        table.insert(TEST_TAB, task)
    end

    for k,v in pairs(team_quests) do
        local task = {}
        task.id = tonumber(k)
        task.cur_sort = self.task_temp_list[task.id] or 0
        task.data = v
        task.cfg = quest_main[task.id]
        if task.data and task.data.quest_status and task.data.quest_status == 1 then --任务进行中
            local start_ts = task.data.start_ts
            local task_tim = self.now_tim - start_ts--任务进行的时间
            task.count_down = task.cfg.duration_time * 60 - task_tim
        end
        if v.self_hero then
            for k,vv in pairs(v.self_hero) do
                table.insert(self.self_hero, vv)
            end
            
        end
        table.insert(TEST_TAB, task)
    end

    for k,v in pairs(master_quests) do
        local task = {}
        task.id = tonumber(k)
        task.cur_sort = self.task_temp_list[task.id] or 0
        task.data = v
        task.cfg = quest_main[task.id]
        if task.data and task.data.quest_status and task.data.quest_status == 1 then --任务进行中
            local start_ts = task.data.start_ts
            local task_tim = self.now_tim - start_ts--任务进行的时间
            task.count_down = task.cfg.duration_time * 60 - task_tim
        end
        if v.self_hero then
            for k,vv in pairs(v.self_hero) do
                table.insert(self.self_hero, vv)
            end
            
        end
        table.insert(TEST_TAB, task)
    end

    self:listSort(TEST_TAB)

    if reset_sort == true then
        for k = 1, #TEST_TAB do
            local task = TEST_TAB[k]
            task.cur_sort = k
            self.task_temp_list[task.id] = k

        end
    end

    self.single_data = TEST_TAB

end

-- 是否有可以领取的任务
function M:isCanGotTask()
    local allTaskData = self:getTaskList()
    local isCanGot = false
    for _, itemData in pairs(allTaskData) do
        if itemData.data.quest_status == 2 then
            -- 有可领取
            isCanGot = true
            break
        end
    end
    return isCanGot
end

-- 是否满足一键派遣条件
function M:isSatisfyDispatchCondition()
    local curVipLevel = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    local vipXlsxData = ConfigManager:getCfgByName("vip")
    if not vipXlsxData[curVipLevel] then
        return false
    end
    if vipXlsxData[curVipLevel].reward_auto ~= 1 then
        return false
    end
    local targetVipLevel = ConfigManager:getCommonValueById(693) or 0
    if curVipLevel < targetVipLevel then
        return false
    end
    local season_data = UserDataManager.m_season_data or {}
    local seasonId = season_data.season or 0
    local targetSeasonId = ConfigManager:getCommonValueById(694) or 0
    if seasonId < targetSeasonId then
        return false
    end
    return true
end

function M:initMasterApprenticeData()
    local team = self.m_data.master_quests or {}
    local TEST_TAB = {}
    local quest_main = ConfigManager:getCfgByName("bounty_quest")
    for k,v in pairs(team) do
        local task = {}
        if self:chechMasterStatue() == true then
            task.id = v.quest_id
        else
            task.id = tonumber(k)
        end 
        task.data = v
        task.cfg = quest_main[task.id]
        if task.data and task.data.quest_status and task.data.quest_status == 1 then --任务进行中
            local start_ts = task.data.start_ts
            local task_tim = self.now_tim - start_ts--任务进行的时间
            task.count_down = task.cfg.duration_time * 60 - task_tim
        end
        table.insert( TEST_TAB, task)
    end
    self.team_data = TEST_TAB
    
end

--任务完成品质计数
function M:init_Rank()
    self.quests_counter = self.m_data.quests_counter --任务计数器  {任务id: 次数}
    self.single_rank = self.m_data.single_rank -- 个人任务品质计数器   {品质: 次数}
    self.team_rank = self.m_data.team_rank -- # 团队任务品质计数器   {品质: 次数}
end

--获取悬赏的数量
function M:getListCount()
    if self.cur_type == 1 then --个人悬赏
        return #self.single_data
    elseif self.cur_type == 2 then --团队悬赏
        return #self.team_data
    end
end

function M:getTaskList()
    if self.cur_type == 1 then
        return self.single_data
    elseif self.cur_type == 2 then
        return self.team_data
    end
end

function M:checkCanGetReward()
    local task_tab = self:getTaskList()
    for k,v in pairs(task_tab) do
        if  v.data.quest_status == 2  then
            return true
        elseif v.count_down and v.count_down <= 0 then
            return true
        end
    end
    return false
end


function M:setTaskAllList(data)
    self.m_data.single_quest = data.single_quest
    self.m_data.team_quests = data.team_quests
    self.m_data.master_quests = data.master_quests
    self.now_tim = UserDataManager:getServerTime()
    self:initSingleData()
end

function M:setTaskList(data,cfg_data)
    local cell_data = data.cell_data
    if cell_data == nil then
        cell_data = data
    end
    
    local quest_id = data.quest_id
    if quest_id == nil then
        if cfg_data ~= nil then
            quest_id = cfg_data.cell_data.id
        else
            quest_id = 0
        end
    end
    local index = data.index
    if index ==nil then
        if cfg_data ~= nil then
            index = cfg_data.index
        else
            index = 0
        end
    end
    local quest_main = ConfigManager:getCfgByName("bounty_quest")
    self.now_tim = UserDataManager:getServerTime()
    for k,v in pairs(self.m_data.single_quest) do
        if tonumber(k) == quest_id then
            self.m_data.single_quest[k] = cell_data.quest
            self.m_data.single_quest[k].isSort = data.isSort
            self.m_data.single_quest[k].cur_isSort = data.index or cfg_data.index
        end
    end
    for k,v in pairs(self.m_data.team_quests) do
        if tonumber(k) == quest_id then
            self.m_data.team_quests[k] = cell_data.quest
        end
    end
    for k,v in pairs(self.m_data.master_quests) do
        if tonumber(k) == quest_id then
            self.m_data.master_quests[k] = cell_data.quest
        end
    end
    if  cell_data.quests_counter then
        self.quests_counter = cell_data.quests_counter --任务计数器  {任务id: 次数}
    end
    if  cell_data.single_rank then
        self.single_rank = cell_data.single_rank -- 个人任务品质计数器   {品质: 次数}
    end
    if cell_data.single_rank then
        self.team_rank = cell_data.team_rank -- # 团队任务品质计数器   {品质: 次数}
    end
    self.single_data = {}
    self:initSingleData()
    
        for k,v in pairs(cell_data.quest.self_hero) do
            table.insert(self.self_hero, v)
        end
    
    
end

--悬赏任务排序
function M:listSort(list)
    list = list or {}
    local function sortFunc(id_one, id_two)
        if id_one.cur_sort == id_two.cur_sort then
            local rank_1= id_one.cfg.rank
            local rank_2= id_two.cfg.rank
            local quest_status_1 = id_one.data.quest_status
            local quest_status_2 = id_two.data.quest_status
            local bounty_type_1 = id_one.cfg.bounty_type
            local bounty_type_2 = id_two.cfg.bounty_type
            local id_1 = id_one.id
            local id_2 = id_two.id

            if id_1 == 100 then
                return true
            elseif id_2 == 100 then
                return false
            else
                if quest_status_1 == quest_status_2 then
                    if rank_1 == rank_2 then
                        if bounty_type_1 == bounty_type_2 then
                            return id_1 < id_2
                        else
                            return  bounty_type_1 > bounty_type_2
                        end
                    else
                        return rank_1 > rank_2
                    end
                else
                    if quest_status_1 == 2 then
                         return true
                    elseif quest_status_2 == 2 then
                         return false
                    else
                         return quest_status_1 < quest_status_2
                    end
                    -- if self.isSort then
                    --     return quest_status_1 < quest_status_2
                    -- end
                end
            end
        else
            return id_one.cur_sort < id_two.cur_sort
        end
    end
    table.sort(list, sortFunc)
end

function M:checkDeadTime(tim)
    if self.cur_type  == 1 then
        local dead_tim = tim - self.now_tim
        local dead_day = math.ceil(dead_tim / 86400) 
        if dead_day <= 0 then
            return ""
        end
        local str = Language:getTextByKey("mail_str_0009", dead_day) 
        return  str
    else
        return ""
    end
end

function M:getBountyBuId(id)
    local quest_main = ConfigManager:getCfgByName("bounty_quest")
    return quest_main[id]
end

function M:chechMasterStatue()
    local open_flag, tips = BtnOpenUtil:isBtnOpen(52)
    return open_flag
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
    if tag == "bounty_refresh" then
        if data == {} then
            return
        end
        self:initData(data)
    elseif tag == "bounty_receive" then
        
    elseif tag == "bounty_info" then
        self:initData(data)
    end
end

return M
