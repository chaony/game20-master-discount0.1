---
---
local M = class("AwakeSystemAsleepPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_cur_hero_id = self.m_params.hero_id  or 0
    self.m_awaken_stage_cfg = ConfigManager:getCfgByName("awaken_stage")
    self.m_awaken_cfg = ConfigManager:getCfgByName("awaken")
    self.m_cur_awaken_cfg = self.m_awaken_cfg[self.m_cur_hero_id] or{}
    self.m_cur_stage_cfg = self.m_awaken_stage_cfg[self.m_cur_hero_id] or{}
    self.m_cur_state_data = self.m_params.stage_data or {}
    self.m_times = self.m_cur_state_data.times or 0
    self.m_can_get = self.m_cur_state_data.recv or false
    self.m_end_unlock_id = 0 
end

function M:initData(data)
    if data.stage_data.result then
        self.m_cur_state_data = data.stage_data.stage_data or {}
        self.m_times = self.m_cur_state_data.times or 0
        self.m_can_get = self.m_cur_state_data.recv
    else
        self.m_cur_state_data = data.stage_data or {}
        self.m_times = self.m_cur_state_data.times or 0
        self.m_can_get = self.m_cur_state_data.recv
    end
end

function M:getShowData()
    local data = {}
    for k,v in pairs(self.m_cur_stage_cfg) do
        table.insert(data,{stage_id = k,data = v})
    end
    table.sort(data, function(data1, data2)
        return data1.stage_id < data2.stage_id
    end)
    return data
end

--1 未解锁 2 已经挑战 3 已经解锁 4 不能解锁  
function M:getStageStatus(index,id)
    local status = 1
    local unlock_table = self.m_cur_state_data.unlock[tostring(self.m_cur_hero_id)]
    local done_table = self.m_cur_state_data.done or {}
    if unlock_table and next(unlock_table) then
        for k,v in ipairs(done_table) do
            if v == id then
                status = 2
                self.m_end_unlock_id = id
                return status
            end
        end
        for k,v in ipairs(unlock_table) do
            if v == id then
                status = 3
                return status
            end
        end
        if self.m_cur_stage_cfg[self.m_end_unlock_id] and self.m_cur_stage_cfg[self.m_end_unlock_id].next == id then
            status = 1
            return  status
        else
            status = 4
            return  status
        end
    else
        status = index == 1 and 1 or 4 
    end
    return  status
end


function M:canGetReward()
    local status = false     
    local done_table = self.m_cur_state_data.done or {}
    local done_stage = done_table[#done_table] or 0
    local done_stage_cfg = self.m_cur_stage_cfg[(done_stage)] or {}
    status = done_stage_cfg.is_end == 1
    
    return  status
end



function M:refreshData(response)
   
end

return M