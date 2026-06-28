local M = class("QiMenDunJiaBattleRecordModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    M.super.onCreate(self)
    self:getData("gve_guild_reward_index", {ver = self.m_params.version or 0});
end

function M:onEnter()
    self.m_version = self.m_params.version or 0
    self.m_record_data = {}
    self.m_reward_data = {}
    self.m_active_target_index = 0
    self:initRecordData()
    self:initRewardData()
end

function M:initRecordData()
    self.m_record_data = self.m_data.logs or {}
    table.sort(self.m_record_data, function(item1, item2)
       return item1.date > item2.date
    end)
    
end

function M:initRewardData()
    self.m_reward_data = {}
    local insert_flag = false
    for k1, v1 in pairs(self.m_data.show_reward or {}) do --相同的奖励合并
        if next(v1.gifts) and v1.status == 0 then
            for k2, v2 in pairs(v1.gifts) do
                insert_flag = false
                for k3, v3 in pairs(self.m_reward_data) do
                    if v3[1] == v2[1] and v3[2] == v2[2] then
                        v3[3] = v3[3] + v2[3]
                        insert_flag = true
                        break
                    end
                end
                if insert_flag == false then
                    table.insert(self.m_reward_data, v2)
                end
            end
        end
    end
    
    --消除红点
    if next(self.m_reward_data) == nil then
        UserDataManager:removeRedDotByKey("gve_guild_reward")
    end
end

function M:updateRewardData(data)
  --table.merge(self.m_data.show_reward, data)
    self.m_data.show_reward = data  --领奖励时，一次全部领取，show_reward为空，而不是通常的show_reward最新状态，故，需要特殊处理 
    self:initRewardData()
end

function M:getVersion()
    return self.m_version
end

function M:getRecordData()
    return self.m_record_data
end

function M:getRewardData()
    return self.m_reward_data
end

function M:hasRewardToGet()
   return next(self.m_reward_data) ~= nil
end

function M:setTargetMember(uid)
    if uid == self.m_active_target_index then
        self.m_active_target_index = -1
    else
        self.m_active_target_index = uid
    end
end



return M