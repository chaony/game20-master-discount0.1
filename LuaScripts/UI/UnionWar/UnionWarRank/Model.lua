local M = class("UnionWarRankModel", LikeOO.OODataBase)

local __TAB_BTN_NODE = {
    { btn_key = "checkpoint_togglebtn", lua_name = "", btn_text = "checkpoint_btn_text", text_key = "new_str_0125", open = true, sort = 1, red_point_img = "checkpoint_red_point_img"}, -- 关卡
    --{ btn_key = "tower_togglebtn", lua_name = "", btn_text = "tower_btn_text", text_key = "new_str_0126", open = true, sort = 2, red_point_img = "tower_red_point_img"}, -- 爬塔
    { btn_key = "tower_togglebtn", lua_name = "", btn_text = "tower_btn_text", text_key = "new_str_0126", open = true, sort = 4, red_point_img = "tower_red_point_img"}, -- 五行阵
    { btn_key = "score_togglebtn", lua_name = "", btn_text = "score_btn_text", text_key = "new_str_0127", open = true, sort = 3, red_point_img = "score_red_point_img"}, -- 积分
}

function M:onCreate()
    M.super.onCreate(self)
    self.m_transfer = "scale"
    --local sort = self.m_params.id
    self:getData("gvg_rank", {lastseason = 0, start = 1, stop = 50})
end

function M:getRewardData(net_callback)
    local function callback(response)
        self.m_reward_data = response
        self:initQuestsData()
        net_callback()
    end
    self:getNetData("rank_rank_quest_info",{sort = self.m_params.id}, callback)
end

function M:onEnter()
    self.m_sel_tab_index = nil
    self.m_open_tab_index = 1
end

function M:initQuestsData()
    self.m_red_point = 0
    local show_data = {}
    local quests = self.m_reward_data.quests or {}
    local quest_rank = ConfigManager:getCfgByName("quest_rank")
    local cur_quest_rank = quest_rank[self.m_id] or {}
    for k,v in pairs(quests) do
        local key = tonumber(k)
        local cfg = cur_quest_rank[key]
        if cfg then
            table.insert(show_data, {id = key, cfg = cfg, data = v})
            local value = v.value or 0 -- 是否完成 0 未完成 1 已完成
            local recv = v.recv or 0  -- 是否领奖 0 未领奖 1 已领奖
            if value == 1 and recv == 0 then
                self.m_red_point = 1
            end
        end
    end
    table.sort(show_data, function(data1, data2)
        if data1.data.recv == data2.data.recv then
            if data1.cfg.target_value == data2.cfg.target_value then
                return data1.id < data2.id
            else
                return data1.cfg.target_value < data2.cfg.target_value
            end
        else
            return data1.data.recv < data2.data.recv
        end
    end)
    self.m_quests_data = show_data
end


function M:getQuestsData()
    return self.m_quests_data
end

function M:getQuestsDataCount()
    return #self.m_quests_data
end

function M:getQuestsDataByIndex(index)
    return self.m_quests_data[index]
end

function M:initData(data)
    self.m_data = data or self.m_data
end

function M:getRankData()
    local ranks = self.m_data.ranks or {}
    return ranks
end

function M:getRankItemCount()
    local ranks = self.m_data.ranks or {}
    return #ranks
end

function M:isLevelRank()
    local isLevelRank = (self.m_data.gvg_rank_name == "guild_lv")
    return isLevelRank
end

function M:getRankDataByIndex(index)
    local ranks = self.m_data.ranks or {}
    return ranks[index]
end

function M:getOwnRankData()
    local rank = self.m_data.rank or 0
    local score = self.m_data.score or 0
    --local count = self.m_data.count or 0
    local flag = self.m_data.flag or 0
    local name = UserDataManager.user_data:getUserStatusDataByKey("guild_name")
    local server_name = self.m_data.server_name
    local data = {rank = rank, score = score, name = name, flag = flag, server_name = server_name}
    return data
end

function M:changeIndex(offset_idx)
    local index = self.m_index + offset_idx
    if index < 1 then
        self.m_index = #self.m_all_rank_types
    elseif index > #self.m_all_rank_types then
        self.m_index = 1
    else
        self.m_index = index
    end
    self.m_rank_cfg = self.m_all_rank_types[self.m_index]
    self.m_id = self.m_rank_cfg.id
end


return M