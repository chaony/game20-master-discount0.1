local M = class("GiftScrollSelectPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
    self.m_floor = self.m_params.floor or 1
    self.m_version = self.m_params.version or 1
    self.m_select_big_id = self.m_params.big_gift_id or 0
    self.m_big_rcvd = self.m_params.big_rcvd or {}
    if  self.m_floor  == -1 then
        self.m_floor = self:getMaxFloor()
    end
end

function M:refreshData(data)

end

function M:getBigReward()
    local scroll_tab = ConfigManager:getCfgByName("scroll_reward")
    local scroll_list = scroll_tab[self.m_version]
    local new_tab = {}
    for k,v in pairs(scroll_list) do
        for kk,vv in pairs(v.big_reward) do
            table.insert(new_tab, {level = k, reward_id = kk, reward_num = vv})
        end
    end
    local function sortFunc(id_one, id_two)
        local can_buy_1 = id_one.level
        local can_buy_2 = id_two.level 
        if can_buy_1 == can_buy_2 then 
            return id_one.reward_id < id_two.reward_id
        end
        return can_buy_1 < can_buy_2
    end
    table.sort(new_tab, sortFunc)
    return new_tab
end

function M:getMaxFloor()
    local scroll_tab = ConfigManager:getCfgByName("scroll_reward")
    local scroll_list = scroll_tab[self.m_version] or {}
    return #scroll_list
end

function M:getRewardById(id)
    local reward_library = ConfigManager:getCfgByName("big_reward_library")
    return reward_library[id]
end

function M:checkBigRcvd(id)
    return self.m_big_rcvd[tostring(id)]    
end

return M
