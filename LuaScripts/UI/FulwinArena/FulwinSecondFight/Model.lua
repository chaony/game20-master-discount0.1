

local M = class("FulwinSecondFightModel", LikeOO.OODataBase)

function M:onCreate()
    self:getData()
end

function M:onEnter()
    self.m_round_cd = 10
    self.m_data = self.m_params.battle_logs
    --Logger.log(self.m_data,"FulwinSecondFightModel data ====")
    self.m_battle_round = {
        [1] = {
            {battle_id = 1, player_node_atk = "player_info_8", player_node_def = "player_info_9"},
            {battle_id = 2, player_node_atk = "player_info_10", player_node_def = "player_info_11"},
            {battle_id = 3, player_node_atk = "player_info_12", player_node_def = "player_info_13"},
            {battle_id = 4, player_node_atk = "player_info_14", player_node_def = "player_info_15"},
        },
        [2] = {
            {battle_id = 5, player_node_atk = "player_info_4", player_node_def = "player_info_5"},
            {battle_id = 6, player_node_atk = "player_info_6", player_node_def = "player_info_7"},
        },
        [3] = {
            {battle_id = 7, player_node_atk = "player_info_2", player_node_def = "player_info_3"},
        },
    }
    self.m_round = 1
    local server_time = UserDataManager:getServerTime()
    local log_data = self:getBattleData(1)
    if log_data then
        local time = server_time - log_data.log_time
        local round = math.ceil(time/self.m_round_cd)
        round = math.max(round, 1)
        self.m_round = math.min(round, 4)
    end
end

function M:getRoundData(round)
    round = round or self.m_round
    return self.m_battle_round[round]
end

function M:getBattleData(id)
    if self.m_data then
        return self.m_data[id]
    end
end

function M:getNextTime()
    local log_data = self:getBattleData(1)
    if log_data then
        return self.m_round * self.m_round_cd + log_data.log_time
    end
end

function M:addRound()
    if self.m_round < 4 then
        self.m_round = self.m_round + 1
    end
end

return M