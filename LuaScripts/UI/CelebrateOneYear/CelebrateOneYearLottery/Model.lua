---@class HalfAnniversaryLotteryModel: OODataBase
local M = class("CelebrateOneYearLotteryModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("lottery_tiket_lottery_tiket_index")
end

function M:onEnter()
    --Logger.log(self.m_data,"lottery_tiket_lottery_tiket_index m_data=====")
    self.m_open_id = self.m_params.open_id or 331
    self.m_version = self.m_data.version or 1
    self.refresh_main = self.m_params.refresh_main or "HalfAnniversary.HalfAnniversaryMain"
    self.m_lottery_tiket = ConfigManager:getCfgByName("lottery_tiket")
    self.m_lottery_tiket_type = ConfigManager:getCfgByName("lottery_tiket_type")
    self:checkData()
end

function M:checkData()
    if self.m_data.stage == 0 then
        self.m_last_stage = 1
        for k,v in pairs(self.m_data.history or {}) do
            if self.m_last_stage < tonumber(k) then
                self.m_last_stage = tonumber(k)
            end
        end
        self.m_data.self_number = self.m_data.history[tostring(self.m_last_stage)].self_number
    end
end

function M:getLotteryReward()
    local lottery_tiket = self.m_lottery_tiket[self.m_version] or {}
    local stage = self.m_data.stage == 0 and self.m_last_stage or self.m_data.stage
    local type_cfg = lottery_tiket[stage] or {}
    if type_cfg.type then
        local lottery_tiket_type = self.m_lottery_tiket_type[type_cfg.type]
        local rewards = {}
        for k,v in pairs(lottery_tiket_type or {}) do
            table.insert(rewards, {id = k, data = v})
        end
        table.sort(rewards,function(a, b) return a.id < b.id end)
        return rewards
    end
end

function M:updateData(data)
    if data then
        table.merge(self.m_data, data)
    end
    self:checkData()
end

function M:getActivityData()
    return UserDataManager:getActivesDataByOpenId(self.m_open_id)
end

--获取活动数据
function M:getActiveData(open_id)
    local id = self.m_open_id
    if open_id then
        id = open_id
    end
    local active_tab = ConfigManager:getCfgByName("active")
    for i, v in pairs(active_tab) do
        if v.open_id == id and v.version == self.m_data.version then
            return v
        end
    end
    return nil
end

return M