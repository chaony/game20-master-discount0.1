---@class FukubukurokuMainModel: OODataBase
local M = class("FukubukurokuMainModel", LikeOO.OODataBase)


function M:onCreate()
    self.open_id = 401
    self.avtive_data = UserDataManager:getActivesDataByOpenId(self.open_id)
    self.version = self.avtive_data and self.avtive_data.version or 1
    self:getData("fukubukuro_luckbag_index",{open_id = self.open_id,vsn = self.version})
end


function M:onEnter()
    self.m_reward_data = {}
    self.total_login_days = self.m_data.total_login_days or 0
    self.daily = self.m_data.daily or 0
    self.can_share = self.m_data.can_share or 0
    self.every_data = nil
    self.is_First_share = false
    self:InitRewardData(self.m_data)
end

function M:InitRewardData(response)
    local stage = response.stage or {}
    self.m_reward_data = {}
    local cfg = ConfigManager:getCfgByName("luckybag")
    if cfg then
        local cfgData = cfg[self.open_id][self.version]
        for k,v in pairs(cfgData) do 
            if v.type == 2 then
                local data = v
                data.status = 0
                data.id = k
                if v.target_day <= self.total_login_days then
                    data.status = 1
                end
                for m,n in pairs(stage) do
                    if n == data.id then
                        data.status = 2
                    end
                end
                table.insert(self.m_reward_data,data)
            else
                local data_ = v 
                data_.id = k
                self.every_data = v
            end
        end
        table.sort(self.m_reward_data,function(a,b)
            return a.id < b.id
        end)
    else
        return {}
    end
end

function M:getRewardData()
    return  self.m_reward_data or {}
end

return M
