---@class PetEvolveQuicklyPopModel: OODataBase
local M = class("CommonUseItemPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_transfer = "scale"
    self.m_source = self.m_params.source
    self:getData()
end

function M:onEnter()
    self.m_item_id = 5510
    self.m_pet_oid = self.m_params.pet_oid
    local data, cfg = UserDataManager.pet_data:getPetDataById(self.m_pet_oid)
    if data.egg_ets then
        self.m_end_time = data.egg_ets
    else
        Logger.logError("数据错误，宠物id" .. self.m_pet_oid .. "没有孵蛋结束时间戳")
        return
    end
    self.m_use_data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, self.m_item_id, 1 }
    local item_data = RewardUtil:getProcessRewardData(self.m_use_data)
    self.m_own_num = item_data.user_num
    self.m_num = 1
    self.m_item_effect = 0
    local item_cfg = ConfigManager:getCfgByName("item")
    if item_cfg[self.m_item_id] then
        self.m_item_effect = item_cfg[self.m_item_id].effect
    end
end

function M:addUseNum(value)
    local new_count = self.m_num + value
    self.m_num = math.min(math.max(1, new_count), self:getMaxNum())
end

function M:getMaxNum()
    local curTime = UserDataManager:getServerTime()
    local max_need_num = math.ceil((self.m_end_time - curTime) / self.m_item_effect)
    return math.min(self.m_own_num, max_need_num) 
end

function M:checkMaxNum()
    local curTime = UserDataManager:getServerTime()
    local max_need_num = math.ceil((self.m_end_time - curTime) / self.m_item_effect)
    return self.m_num - max_need_num , max_need_num
end

function M:setMaxNum()
    self.m_num = self:getMaxNum()
end

function M:setMinNum()
    self.m_num = 1
end

function M:getNum()
    return self.m_num
end

function M:getUseItem()
    self.m_use_data = { RewardUtil.REWARD_TYPE_KEYS.ITEM, self.m_item_id, self.m_num }
    return self.m_use_data
end

function M:checkCanUse()
    return self.m_own_num > 0
end

function M:getEndTime()
    return self.m_end_time
end

return M
