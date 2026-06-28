---@class HalfAnniversaryLotteryPopModel: OODataBase
local M = class("HalfAnniversaryLotteryPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_lottery_tiket = ConfigManager:getCfgByName("lottery_tiket")
    self.m_lottery_tiket_type = ConfigManager:getCfgByName("lottery_tiket_type")
    self.m_version = self.m_params.version or 1
    self:checkData()
    self.m_stage = self.m_last_stage
end

function M:getActivityData()
    return UserDataManager:getActivesDataByOpenId(self.m_version)
    
end

function M:updateData(data)
    if data then
        table.merge(self.m_params, data)
    end
    self:checkData()
end

function M:checkData()
    self.m_last_stage = 1
    if self.m_params.stage == 0 then
        for k,v in pairs(self.m_params.history or {}) do
            if self.m_last_stage < tonumber(k) then
                self.m_last_stage = tonumber(k)
            end
        end
    else
        self.m_last_stage = self.m_params.stage - 1
    end
end

function M:setTabIndex(index)
    self.m_stage = index
end

function M:getStageData(stage)
    return self.m_params.history[tostring(stage)]
end

function M:getLotteryReward()
    local data = self:getStageData(self.m_stage)
    local lottery_tiket = self.m_lottery_tiket[self.m_version] or {}
    local type_cfg = lottery_tiket[self.m_stage] or {}
    if type_cfg.type then
        local lottery_tiket_type = self.m_lottery_tiket_type[type_cfg.type]
        local rewards = {}
        for k,v in pairs(lottery_tiket_type or {}) do
            table.insert(rewards, {id = k, cfg = v})
        end
        
        table.sort(rewards, function(a, b) return a.id < b.id end)
        for i,v in ipairs(rewards) do
            if table.indexof(v.cfg.num, data.same_num_count) then
                return i, v.cfg.reward
            end
        end
    end
end

return M