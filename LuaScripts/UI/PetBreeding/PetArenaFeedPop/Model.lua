---@class PetArenaFeedPopModel: OODataBase
local M = class("PetArenaFeedPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_feed_list = self.m_params.feed_list
    self.m_mood_list = self.m_params.mood_list
    if not self.m_feed_list or not self.m_mood_list then
        self:initData()
    end
end

function M:initData()
    local pet_ids = UserDataManager.hero_data:getTeamByKey("pet_pvp")
    self.m_feed_list = {}
    for i = 1, 3 do
        local data = UserDataManager.pet_data:getPetDataById(self.m_feed_list[i])
        if pet_ids[i] ~= "" and data then
            table.insert(self.m_mood_list, data.mood)
            table.insert(self.m_feed_list, pet_ids[i])
        end
    end
end

function M:getPetsList()
    return self.m_feed_list
end

function M:getNeedItemData()
    local mood_list = self.m_mood_list
    local mood_cfg = ConfigManager:getCfgByName("mood_random")
    local num = 0
    --取第一个
    for i = 1, #mood_list do
        if mood_list[i] == 1 then
            num = num + mood_cfg[1].cost[3] + mood_cfg[2].cost[3]
        elseif mood_list[i] == 2 then
            num = num + mood_cfg[2].cost[3]
        end
    end
    self.m_cost_data = { [1] = mood_cfg[1].cost[1], [2] = mood_cfg[1].cost[2], [3] = num }
    return self.m_cost_data
end

function M:checkNeedItem()
    local cost_num = self.m_cost_data[3]
    local item_data = RewardUtil:getProcessRewardData(self.m_cost_data)
    local own_num = item_data.user_num
    return own_num >= cost_num, cost_num
end

function M:getFeedData()
    local feed_list = { }
    for i = 1, #self.m_feed_list do
        local data = UserDataManager.pet_data:getPetDataById(self.m_feed_list[i])
        if data then
            feed_list[self.m_feed_list[i]] = 3
        end
    end
    return feed_list
end

function M:getPetDataById(oid)
    local data, cfg = UserDataManager.pet_data:getPetDataById(oid)
    return data, cfg
end

return M