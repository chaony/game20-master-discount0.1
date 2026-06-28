local M = class("WindAndCloudReceiveRedPacketView", LikeOO.OOPopBase)

M.m_uiName = "WindAndCloud/WindAndCloudReceiveRedPacket"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("desc_text", "wind_clouds_red_packet_text_00010")
    local servername = UserDataManager.server_data:getServerNameById(self.m_model.m_info[4]) or ""
    local name_str = self.m_model.m_info[2] or ""
    self:setTextByLanKey("names_text", servername .. "-" .. name_str)
    self:setTextByLanKey("desc2_text", "wind_clouds_red_packet_text_00011")
    self:setTextByLanKey("receive_text", "wind_clouds_red_packet_text_0009")
    self:refreshUI()
end

function M:refreshUI()
    self:createReward()
end

function M:createReward()
    local parent = self:findGameObject("reward_grid")
    local rewards = self.m_model.m_reward
    GameUtil:createRewards(parent.transform, rewards, true, true, nil)
end

return M
