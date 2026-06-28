local M = class("HeavenBlessSelectRewardPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
    self.m_version = self.m_params.version
    self.m_wishAward = self.m_params.wishAward
    self.m_selectId = -1
    self.reward_cfg = self.m_params.reward_cfg
    self.version = self.m_params.version
    self.select_reward_list = {}  --自选的奖励列表 1 甲级奖励 2、3 乙级奖励
    
    self:getData()
end

function M:getRewardCfgDataByLevel(levelNum)
    local tempTab = {}
    local index = 1
    for i, v in ipairs(self.reward_cfg) do
        if v.level == levelNum then
            tempTab[index] = v
            tempTab[index]["id"] = i
            index = index + 1
        end
    end
    return tempTab
end

function M:getLevel3RewardId() --获取等级3的奖励id列表
    local tempTab = {}
    local index = 4
    for i, v in pairs(self.reward_cfg) do
        if v.level == 3 then
            tempTab[index] = i
            index = index + 1
        end
    end
    return tempTab
end

function M:getReward_Choice_cfg()
    local reward_choice_cfg = ConfigManager:getCfgByName("reward_choice_cfg")
    return reward_choice_cfg
end

function M:onEnter()
    
end

return M