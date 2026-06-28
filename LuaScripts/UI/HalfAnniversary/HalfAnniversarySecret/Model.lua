local M = class("HalfAnniversarySecretModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self:getData("active_monster_index")
end

function M:onEnter()
    Logger.log(self.m_data,"active_monster_index =====")
    self.m_open_id = 330
    self.m_end_ts = self:getActiveEndTime()
    self.big_reward_floor = 0
end

function M:refreshData(data)
    if data then
        self.m_data = data
    end
end

function M:checkLastFloor()
    local max_layer = self:getMaxFloor()
    local cur_layer = self:getLayerNum()
    return cur_layer >= max_layer
end


function M:getScrollRcvdGift(index)
    local data = self.m_data.rcvd_gifts[tostring(index)]
    return data or {}
end

--新的一层 显示引导手
function M:checkIsNewLayer()
    return table.nums(self.m_data.rcvd_gifts) == 0
end

function M:checkWhitePos(index)
    for k,v in pairs(self.m_data.white_pos) do
		if index == v then
			return true
		end
	end
	return false
end

function M:isBigPos(index)
    local big_reward_cfg = self:checkBigRcvd()
	local rewardTable = big_reward_cfg.reward[1] or nil
    local rcvd_gift = self:getScrollRcvdGift(index)
    if rewardTable and next(rcvd_gift) ~= nil then
        if rcvd_gift.gift then
            local rcvdData = rcvd_gift.gift[1]
            if rewardTable[1] == rcvdData[1] and rewardTable[2] == rcvdData[2] and rewardTable[3] == rcvdData[3] then
                return true
            end
        end
    end
    return false
end

--获取大奖奖励
function M:checkBigRcvd()
    local reward_library = ConfigManager:getCfgByName("monster_big_library")
    return reward_library[self.m_data.big_gift_id or 1]
    --return reward_library[1]
end

function M:getPanelName()
    local open_condition_tab = ConfigManager:getCfgByName("open_condition")
    local cur_data = open_condition_tab[self.m_open_id]
    return Language:getTextByKey(cur_data.name)
end

--当前层数
function M:getLayerNum()
    if self.m_data.layer == -1 then
        return self:getMaxFloor()
    else
        return self.m_data.layer
    end
    return 1
end

function M:getMaxFloor()
    local scroll_tab = ConfigManager:getCfgByName("monster_reward")
    local scroll_list = scroll_tab[self.m_data.version] or {}
    return #scroll_list
end

--锦囊玉轴消耗
function M:getCostNum()
    local scroll_tab = ConfigManager:getCfgByName("monster")
    local cfg = scroll_tab[self.m_data.version]
    return cfg.score[1]
end

function M:getActiveEndTime()
    if self.m_data.actives and next(self.m_data.actives) ~= nil then
        for k,v in pairs(self.m_data.actives) do
            if v.open_status > 0 then
                return v.end_ts
            end
        end
    end
    return -1
end

--锦囊玉轴配置
function M:getScrollCfg()
    local scroll_tab = ConfigManager:getCfgByName("monster")
    local cfg = scroll_tab[self.m_data.version]
    return cfg
end

function M:getScrollConsume()
    if self.m_data == nil then
        return nil
    end
    local scroll_tab = ConfigManager:getCfgByName("monster")
    local scroll_cfg = scroll_tab[self.m_data.version]
    local data_consume = scroll_cfg.score[1]
    local consume_data = RewardUtil:getProcessRewardData(data_consume)
    return consume_data
end

function M:getActiveCfg()
    local active_tab = ConfigManager:getCfgByName("active")
    for k,v in pairs(active_tab) do
        if v.open_id == self.m_open_id and v.version == self.m_data.version then
            return v
        end
    end
end

function M:checkTaskRedPoint()
    --if self.m_data == nil then
    --    return false
    --end
    --for k,v in pairs(self.m_data.quests) do
    --    if v.status == 1 then
    --        return true
    --    end
    --end
    --return RedPointUtil:getScrollActiveShopStatus()
end

--当前大奖
function M:getTheAwardData()
    local scroll_cfg = self:getScrollCfg()
    local scroll_tab = ConfigManager:getCfgByName("monster_reward")
    local scroll_list = scroll_tab[self.m_data.version] or {}
    local big_reward = nil
    for i = #scroll_list, 1, -1 do
        local cur_floor_data = scroll_list[i]
        if cur_floor_data.big_reward and next(cur_floor_data.big_reward) ~= nil then
            big_reward = cur_floor_data.big_reward
            self.big_reward_floor = i
            break
        end
    end
    local reward_id = 1
    for k,v in pairs(big_reward) do
        if k > reward_id then
            reward_id = k
        end
    end
    self.reward_id = reward_id 
    local reward_library = ConfigManager:getCfgByName("monster_big_library")
    if reward_library[reward_id] then
        return reward_library[reward_id].reward[1]
    end
    return nil
end

--当前大奖进度
function M:showTehAwardNum()
    if self:getLayerNum() >=self.big_reward_floor then
        return self.big_reward_floor .."/"..self.big_reward_floor 
    else
        return self:getLayerNum().."/"..self.big_reward_floor 
    end
end

--是否已获得大奖
function M:isGetBig()
    if self.m_data.big_rcvd and next(self.m_data.big_rcvd) ~= nil then
        for k,v in pairs(self.m_data.big_rcvd) do
            if self.reward_id == tonumber(k) then
                return true
            end
        end
    end
    return false
end

return M
