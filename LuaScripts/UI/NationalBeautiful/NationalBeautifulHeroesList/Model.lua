---@class DeliciousFeastRankModel: OODataBase
local M = class("NationalBeautifulHeroesListModel", LikeOO.OODataBase)


function M:onCreate()
    self.open_id = self.m_params.open_id or 412
    self.version = self.m_params.version or 1
    self.m_is_token = self.m_params.is_token or false
    self.current_show_tab_num = 1 --默认进入活动展示展示排行榜
    self.is_show = self.m_params.is_show
    self.refresh_main = self.m_params.refresh_main or "NationalBeautiful.NationalBeautifulMain"
    self.m_activityData = UserDataManager:getActivesDataByOpenId(self.m_openId)
    self:getData("active_common_favor_index",{open_id = self.open_id,version = self.version})
end


function M:onEnter()
    self.items = {
        {open_id = 412, btn_name = "item_1_btn", prefab_folder = "NationalBeautiful",prefab_name = "NationalBeautifulDailyReward",show_name = true,show_name_text = "national_beautiful_text_0005",is_close_view = false}, 	--养成竞速
        {open_id = 411, btn_name = "item_2_btn", prefab_folder = "Chivalry",prefab_name = "ChivalryBattle",show_name = false,is_close_view = true}, 	--郿坞试炼
        {open_id = 314, btn_name = "item_3_btn", prefab_folder = "LuckyDraw",prefab_name = "LuckyDraw",show_name = false,show_name_text = "national_beautiful_text_0007",is_close_view = true,jump_id = 100002}, 	--天香召唤
        {open_id = 410, btn_name = "item_4_btn", prefab_folder = "NationalBeautiful",prefab_name = "NationalBeautifulXkz",show_name = false,is_close_view = true}, 	--巾帼红颜
    }
    self.m_items = self.m_params.items_table or self.items
    self.show_dialogue_id = 1 --显示的对话类型
    self.is_once_timer = {  } --是否在倒计时中，0不在，1在
    self:refreshRankData(self.m_data)
    self:getRewardInfo()
    self.show_send_gift = false --初始不显示一键赠送
end

function M:netData(data, tag)
    table.merge(self.m_data, data or {})
    --self:refreshRankData(self.m_data)
end

function M:getAllItem()
    return self.m_items
end

function M:getItem(btn_name)
    for k, v in pairs(self.m_items) do
        if btn_name == v.btn_name then
            return v
        end
    end
    return nil
end

function M:getTokenFlag()
    return self.m_is_token
end

--设置当前显示页签id
function M:setSelectIndex(index)
    self.current_show_tab_num = index
end

--刷新排行榜数据
function M:refreshRankData(m_data)
    self.roleRankData = m_data.ranks
    self.roleRankCount = m_data.count
    if self.roleRankCount > 0 and table.nums(self.roleRankData) > 0 then
        table.sort(self.roleRankData, function(itemData1, itemData2) return itemData1.rank < itemData2.rank end)
    end
    self.myInfoData = {
        rank = m_data.rank,
        score = m_data.score,
    }
end

--获取活动数据
function M:getActiveData(open_id)
    local id = self.open_id
    if open_id then
        id = open_id
    end
    local version = self:getActVsn(open_id)
    if id == self.open_id then
        version = self.version
    end
    local active_tab = ConfigManager:getCfgByName("active")
    for i, v in pairs(active_tab) do
        if v.open_id == id and v.version == version then
            return v
        end
    end
    local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
    for i,v in pairs(active_recharge_tab) do
        if v.open_id == open_id and v.version == self.m_data.version then
            return v
        end
    end
    return nil
end

--获取活动version
function M:getActVsn(open_id, is_recharge)
    open_id = open_id or 393
    local active = nil
    if is_recharge then
        active = UserDataManager:getActivesRechargeDataByOpenId(open_id)
    else
        active = UserDataManager:getActivesDataByOpenId(open_id)
    end
    if active and active.version then
        return active.version
    end
    local current_version = 1
    if is_recharge then
        local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
        for i,v in pairs(active_recharge_tab) do
            if v.open_id == open_id then
                local cur_tim =  UserDataManager:getServerTime()
                local start_ts = GameUtil:stringToTimesTamp(v.start_time)
                local end_ts = GameUtil:stringToTimesTamp(v.end_time)
                local show_ts = 0
                if v.show_time ~= "" then
                    show_ts = cur_tim < GameUtil:stringToTimesTamp(v.show_time) and 1 or 0
                end
                local is_end = cur_tim < end_ts or show_ts == 1
                current_version = v.version
                if cur_tim > start_ts and is_end then
                    return v.version
                end
            end
        end
    else
        local active = ConfigManager:getCfgByName("active")
        for i,v in pairs(active) do
            if v.open_id == open_id then
                local cur_tim =  UserDataManager:getServerTime()
                local start_ts = GameUtil:stringToTimesTamp(v.start_time)
                local end_ts = GameUtil:stringToTimesTamp(v.end_time)
                local show_ts = 0
                if v.show_time ~= "" then
                    show_ts = cur_tim < GameUtil:stringToTimesTamp(v.show_time) and 1 or 0
                end
                local is_end = cur_tim < end_ts or show_ts == 1
                current_version = v.version
                if cur_tim > start_ts and is_end then
                    return v.version
                end
            end
        end
    end
    return current_version
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
function M:getRewardInfo()
    self.rank_rewards = {}
    local favor_rank = ConfigManager:getCfgByName("favor_rank")
    if favor_rank[self.open_id] and favor_rank[self.open_id][self.version] then
        self.rank_rewards = favor_rank[self.open_id][self.version]
    end
end

--获取当前等级的最大好感值
function M:getLevelnum()
    local favor_level = ConfigManager:getCfgByName("favor_level")
    local level = favor_level[self.open_id][self.version]
    if level[self.m_data.lv+1] then
        return level[self.m_data.lv+1].favor_need
    end
    return 0
end

--好感度道具
function M:getItems()
    local item_table = {}
    local show_data = self:getShowDate()
    local item_id = show_data and show_data.favor_item or "5602"
    table.insert(item_table,item_id)
    return item_table
end

--获取开场对话
function M:getOpenDialogue()
    local favor_dialogue = ConfigManager:getCfgByName("favor_dialogue")
    if favor_dialogue[self.open_id] and favor_dialogue[self.open_id][self.version] then
        for i, v in ipairs(favor_dialogue[self.open_id][self.version]) do
            if self.m_data.lv >= v.level[1] and v.level[2] >= self.m_data.lv  then
                return v.dialogue
            end
        end
    end
    return 0
end

--获取收到礼物对话
function M:getDialogue()
    local favor_dialogue = ConfigManager:getCfgByName("favor_dialogue")
    if favor_dialogue[self.open_id] and favor_dialogue[self.open_id][self.version] then
        for i, v in ipairs(favor_dialogue[self.open_id][self.version]) do
            if self.m_data.lv >= v.level[1] and v.level[2] >= self.m_data.lv then
                return v.regards_receive
            end
        end
    end
    return 0
end

--获取点击礼物对话
function M:getClickDialogue()
    local favor_dialogue = ConfigManager:getCfgByName("favor_dialogue")
    if favor_dialogue[self.open_id] and favor_dialogue[self.open_id][self.version] then
        for i, v in ipairs(favor_dialogue[self.open_id][self.version]) do
            if self.m_data.lv >= v.level[1] and v.level[2] >= self.m_data.lv then
                local click_table = v.click
                local value_id =  math.random(#click_table)
                return v.click[value_id]
            end
        end
    end
    return 0
end

--获取气泡对话内容
function M:getDialogueContent(click_id)
    local favor_dialogue = ConfigManager:getCfgByName("favor_dialogue_guide")
    for i, v in pairs(favor_dialogue) do
        if i == click_id then
            return v.words
        end
    end
    return ""
end

--获取加载的index
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

function M:insertRankData(new_rank_data,rank_info)
    for i = 1, #new_rank_data do
        table.insert(self.roleRankData, new_rank_data[i])
    end
    --self.own_data = {rank = rank_info.rank or 0,score = rank_info.score,user=rank_info.user_info}
end

--养成竞速是否有红点
function M:dailyRewardIsRed()
    --获取英雄id
    local hero_event_daily_reward = ConfigManager:getCfgByName("favor_growth_reward") or {}
    local m_cur_cfg = hero_event_daily_reward[self.open_id][self.version] or {}
    local hero_id = m_cur_cfg[1].hero_id
    --英雄最大等级
    local max_data = UserDataManager:getHeroMaxEvo(hero_id)
    local m_max_evo = 0
    if max_data then
        m_max_evo = max_data.max_evo or 0
    end
    --判断是否有可领取的奖励
    for i = #m_cur_cfg, 1, -1 do
        local quality = m_cur_cfg[i].hero_evo
        local is_receive = self:getIsReceive(i)
        if m_max_evo >= quality and not is_receive then
            return true
        end
    end
    return false
end

--判断是否领取过
function M:getIsReceive(id)
    for i, v in pairs(self.m_data.recv) do
        if v == id then
            return true
        end
    end
    return false
end

--获取显示数据（活动描述、活动名称、展示英雄等）
function M:getShowDate()
    local favor_event = ConfigManager:getCfgByName("favor_event")
    return favor_event[self.open_id][self.version] or {}
end

--获取spine信息
function M:getSkinData()
    local show_data = self:getShowDate()
    local skin_id = 60501
    if show_data then
        skin_id = tonumber(show_data.hero_spine)
    end
    local hero_skin = ConfigManager:getCfgByName("hero_skin")
    return hero_skin[skin_id] or {}
end

--获取活动名称
function M:getActiveName()
    local show_data = self:getShowDate()
    return show_data.favor_growth or ""
end

return M
