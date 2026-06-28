local M = class("LuckyDogShopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_open_id = self.m_params.open_id or 0
    self.m_version = self.m_params.version or 0
    self.m_library = self.m_params.library or 0
    self:getData("lucky_treasure_draw_index", {open_id = self.m_open_id, vsn = self.m_version})
end

function M:onEnter()
    self.m_score = self.m_data.score or 0
    self.m_reward_data = {}
    self.m_reward_index = 1
    self:initGiftData()
end

function M:getOpenID()
    return self.m_open_id
end

function M:getVersion()
    return self.m_version
end

function M:getScore()
    return self.m_score
end

function M:hasEnoughScore(score_count)
    return self.m_score >= score_count
end

function M:updateGiftData(data)
    self:updateRewardData(data.reward)
    table.merge(self.m_data, data)
    self.m_score = self.m_data.score or 0
    self:initGiftData()
end

function M:getBigRewardFlagArray()
    return {[3] = true, [6] = true, [10] = true, [13] = true}
end

function M:initGiftData()
    self.m_gift_data = {}
    local gift_tab = ConfigManager:getCfgByName("lucky_treasure_library") or {}
    local gift_library_tab = gift_tab[self.m_library] or {}
    local gift_data_id_normal = self.m_data.normal_ids or {}
    local gift_data_id_big = self.m_data.big_ids or {}
    local gift_data_big_left = self.m_data.big_left or {}
    local big_prize_flag_arr = self:getBigRewardFlagArray()
    local index_normal = 1
    local index_big = 1
    local type --1大奖，2普通奖
    local id
    local cfg
    local left_times
    for index = 1, 14 do
        if big_prize_flag_arr[index] == true then
            type = 1
            id = gift_data_id_big[index_big] or -1
            index_big = index_big + 1
            left_times = gift_data_big_left[tostring(id)]
        else
            type = 2
            id = gift_data_id_normal[index_normal] or -1
            index_normal = index_normal + 1
            left_times = -1
        end
        if id ~= -1 then
            cfg = gift_library_tab[type][id] or {}
            self.m_gift_data[index] = {id = id, cfg = cfg, left_times = left_times}
        end
    end
end

function M:getGiftData()
    return self.m_gift_data
end

function M:updateRewardData(reward_data)
    self.m_reward_data = {}
    if reward_data then
        for k, v in pairs(reward_data) do
            for kk, vv in pairs(self.m_gift_data) do
                if vv.id == v then
                    table.insert(self.m_reward_data, vv.cfg.reward[1])
                    self.m_reward_index = kk
                    break
                end
            end
        end
    end
end

function M:getRewardIndexAndData()
    return self.m_reward_index, self.m_reward_data
end

function M:getGachaCfg()
    local lucky_treasure_tab = ConfigManager:getCfgByName("lucky_treasure") or {}
    local lucky_treasure_tab_open_id = lucky_treasure_tab[self.m_open_id] or {}
    local lucky_treasure_tab_version = lucky_treasure_tab_open_id[self.m_version] or {}
    return lucky_treasure_tab_version
end

return M