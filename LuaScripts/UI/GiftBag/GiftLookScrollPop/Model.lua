local M = class("GiftLookScrollPopModel", LikeOO.OODataBase)

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
end

function M:refreshData(data)

end

function M:getBigReward()
    local scroll_tab = ConfigManager:getCfgByName("scroll_reward")
    local scroll_list = scroll_tab[self.m_version]
    local new_tab = {}
    for i = 1, #scroll_list do
        local cur_scroll = scroll_list[i]
        for k,v in pairs(cur_scroll.big_reward) do
            table.insert(new_tab, {level = i, reward_id = k, reward_num = v})
        end
    end
    table.sort(new_tab,function(data1,data2)
        local can_buy_1 = data1.level
        local can_buy_2 = data2.level 
        if can_buy_1 == can_buy_2 then 
            return data1.reward_id < data2.reward_id
        end
        return can_buy_1 < can_buy_2
    end)
 
    return new_tab
end

function M:getRewardById(id)
    local reward_library = ConfigManager:getCfgByName("big_reward_library")
    return reward_library[id]
end

function M:checkBigRcvd(id)
    return self.m_big_rcvd[id]    
end

return M
