local M = class("OnTimePopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self.m_transfer = "scale"
    self:getData("online_reward_index")
end

function M:onEnter()
    self:refreshData()
end

function M:refreshData(data)
    if data then
        self.m_data = data
    end
    self.m_online_reward = self.m_data.online_reward or {}
end

function M:getCurUpdateTime()
end

function M:getCurOnlineCfg()
    local tab = self:get_online_tab()
    if self.m_data.online_reward.config == -1 then
        return nil
    end
    local cur_cfg = nil
    for k, v in pairs(tab) do
        if v.id == self.m_data.online_reward.config then
            cur_cfg = v.cfg
        end
    end
    if cur_cfg then
        local now_tim = UserDataManager:getServerTime()
        local s_time = self.m_data.online_reward.stime
        local interval = now_tim - s_time
        return (cur_cfg.time * 60) - interval
    end
    return nil
end

--在线奖励
function M:get_online_tab()
    if next(self.m_online_reward) == nil then
        return {}
    end
    local index = self.m_online_reward.config or 1
    local new_tab = {}
    local old_tab = {}
    local all_tab = {}
    local online_reward_tab = ConfigManager:getCfgByName("online_reward")
    for i = 1, #online_reward_tab do
        table.insert(all_tab, {id = i, cfg = online_reward_tab[i]})
    end
    -- for i = 1, #online_reward_tab do
    --     if i >= index then
    --         table.insert(new_tab, {id = i, cfg = online_reward_tab[i]})
    --     else
    --         table.insert(old_tab, {id = i, cfg = online_reward_tab[i]})
    --     end
    -- end
    -- for i = 1, #new_tab do
    --     table.insert(all_tab, new_tab[i])
    -- end
    -- for i = 1, #old_tab do
    --     table.insert(all_tab, old_tab[i])
    -- end
    return all_tab
end

return M
