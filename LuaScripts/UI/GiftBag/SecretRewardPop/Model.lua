local M = class("SecretRewardPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self:getData("secret_index")
end

function M:onEnter()
    self.big_reward_floor_List = {} -- 里程碑层数
    self.m_version = self.m_data.version
    self:getActStatus()
    self.cur_position = self.m_data.pos + 1 -- 阿闲初始位置 后端是0-13
    self:updateData()
    self.last_position = 0 -- 阿闲下次要去的位置
end

function M:updateData(data)
    if data then
        self.m_data = data
    end
    self.cur_floor = self.m_data.layer -- 当前层数
    self.layer_gifts = self.m_data.gifts -- 本层奖品列表
    self.max_layer = self.m_data.max_layer -- 本期最大层数
    self.got_milepost_reward = self.m_data.got_milepost_reward --已领取的里程碑奖励
    self.big_reward_floor_List = self:getMilepostRewardList() -- 里程碑奖励层数
end

function M:checkMaxFloor()
    local flag = false
    if self.cur_floor == self.max_layer and self.cur_position == 14 then
        flag = true
    end
    return flag
end

function M:getBoxStatus(index)
    local stauts = 0  -- 2可领取 -1 已领取 0 未达成
    if table.indexof(self.got_milepost_reward, self.big_reward_floor_List[index]) then
        stauts = -1
    elseif self.cur_floor >= self.big_reward_floor_List[index] then
        stauts = 2
    end
    return stauts, self.big_reward_floor_List[index]
end

function M:getPanelName()
    local open_condition_tab = ConfigManager:getCfgByName("open_condition")
    local cur_data = open_condition_tab[288]
    return Language:getTextByKey(cur_data.name)
end

function M:getUserItemCount()
    local item_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, 5395, 0})
    local user_num = item_data.user_num
    return user_num
end

--锦囊玉轴消耗
function M:getCostNum()
    local scroll_tab = ConfigManager:getCfgByName("secret")
    local cfg = scroll_tab[self.m_version]
    return cfg.score[1]
end

--锦囊玉轴配置
function M:getScrollCfg()
    local scroll_tab = ConfigManager:getCfgByName("secret")
    local cfg = scroll_tab[self.m_version] or {}
    return cfg
end

function M:getScrollConsume()
    if self.m_data == nil then
        return nil
    end
    local scroll_tab = ConfigManager:getCfgByName("secret")
    local scroll_cfg = scroll_tab[self.m_version]
    local data_consume = scroll_cfg.score[1]
    local consume_data = RewardUtil:getProcessRewardData(data_consume)
    return consume_data
end

function M:checkTaskRedPoint()
    if self.m_data == nil then
        return false
    end
    for k,v in pairs(self.m_data.quests) do
        if v.status == 1 then
            return true
        end
    end
    return RedPointUtil:getSecretActiveShopStatus()
end

--当前大奖层数
function M:getMilepostRewardList()
    local scroll_tab = ConfigManager:getCfgByName("secret_reward")
    local scroll_list = scroll_tab[self.m_version] or {}
    local floor_list = {}
    for i = 1, #scroll_list do
        local cur_floor_data = scroll_list[i]
        if cur_floor_data.milepost_reward and cur_floor_data.milepost_reward ~= 0 then
            floor_list[#floor_list+1] = i
        end
    end
    return floor_list
end

function M:getActStatus()
    self.m_act_data = UserDataManager:getActivesDataByOpenId(288)
    if self.m_act_data and self.m_act_data.open_status then
        return self.m_act_data.open_status
    end
    return 0
end

function M:getEndTs()
    if self.m_act_data and self.m_act_data.end_ts then
        return self.m_act_data.end_ts - UserDataManager:getServerTime()
    end
    return 0
end
-- 大奖预览
function M:getBigRewardsShowData()
    local show_data = {}
    local secret_reward_cfg = ConfigManager:getCfgByName("secret_reward")
    local secret_big_library_cfg = ConfigManager:getCfgByName("secret_big_library")
    local cur_season = UserDataManager:getCurSeason() -- 当前赛季
    local secret_reward_cfg_v = secret_reward_cfg[self.m_version]
    for k, v in pairs(secret_reward_cfg_v) do
        local big_reward_id = v.big_reward
        if secret_big_library_cfg[big_reward_id] then
            local secret_big_cfg = secret_big_library_cfg[big_reward_id][cur_season]
            if not secret_big_cfg then
                for i = cur_season, 0 , -1 do
                    secret_big_cfg = secret_big_library_cfg[big_reward_id][i]
                    if secret_big_cfg then
                        break
                    end
                end
            end
            local itemData = RewardUtil:getProcessRewardData(secret_big_cfg.reward[1])
            table.insert(show_data, {reward = secret_big_cfg.reward, cfg = itemData.item_cfg, id = k, name = Language:getTextByKey("secret_reward_pop_text008",k) })
        end
    end
    table.sort(show_data, function(data1,data2)
        return data1.id < data2.id
    end)
    return show_data
end
-- 进度条奖励
function M:getProgressRewardData()
    local secret_reward_cfg = ConfigManager:getCfgByName("secret_reward")
    local secret_big_library_cfg = ConfigManager:getCfgByName("secret_big_library")
    local secret_reward_cfg_v = secret_reward_cfg[self.m_version] or {}
    local cur_season = UserDataManager:getCurSeason() -- 当前赛季
    local progressReward = {}
    for k, v in pairs(secret_reward_cfg_v) do
        if v.milepost_reward then
            if secret_big_library_cfg[v.milepost_reward] then
                local secret_big_cfg = secret_big_library_cfg[v.milepost_reward][cur_season]
                if not secret_big_cfg then
                    for i = cur_season, 0 , -1 do
                        secret_big_cfg = secret_big_library_cfg[v.milepost_reward][i]
                        if secret_big_cfg then
                            break
                        end
                    end
                end
                progressReward[#progressReward+1] = {id = k, reward = secret_big_cfg.reward}
            end
        end
    end
    table.sort(progressReward, function(data1,data2)
        return data1.id < data2.id
    end)
    return progressReward
end

return M
