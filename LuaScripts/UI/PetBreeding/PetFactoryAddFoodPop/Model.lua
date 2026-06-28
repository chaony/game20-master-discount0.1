local M = class("PetFactoryAddFoodPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()
    local constants = ConfigManager:getCfgByName("common")
    -- 单个道具翻倍效果时间
    self.m_doubleTime = constants[743].value
    -- 消耗道具数据
    self.m_cost_item_data =  constants[745].value
    -- 消耗道具ID
    self.m_cost_item_id = self.m_cost_item_data[2]
    
    self.m_use_data = {RewardUtil.REWARD_TYPE_KEYS.ITEM, self.m_cost_item_id, 1}
    local data = RewardUtil:getProcessRewardData(self.m_use_data)
    
    -- 最大可使用数量
    self.m_max_num = data.user_num
    -- 当前值，默认为 1
    self.m_num = data.user_num ~= 0 and 1 or 0
    
    -- 派遣最大时间
    self.m_idle_start_time = self.m_params.idleStartTime
    self.m_idle_end_time = self.m_params.idleEndTime
    
    local leftSecond = self.m_idle_end_time - UserDataManager:getServerTime()
    local leftHour = math.floor(leftSecond / 3600) 
    -- 投喂数量最优值
    self.m_best_num = leftHour / self.m_doubleTime
end

function M:addUseNum(value)
    local new_count = self.m_num + value
    self.m_num = math.min(math.max(1, new_count), self:getMaxNum())
end

function M:addUseNumMax() 
    local new_count = self.m_best_num
    new_count = self.m_max_num < new_count and self.m_max_num or new_count
    new_count = GameUtil:formatNum(new_count)
    self.m_num = math.min(new_count, self:getMaxNum())
end

function M:getMaxNum()
    return self.m_max_num
end

function M:getNum()
    return self.m_num
end

function M:getUseItem()
    return self.m_use_data
end

return M
