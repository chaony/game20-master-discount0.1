local M = class("MythArenaSecondGuessPopView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaSecondGuessPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("common_title_text", "peak_str_0016")
	self:setTextByLanKey("get_num", "")
    local HeadNode = self:findGameObject("HeadNode")
    if self.m_model.m_guess_player_data and next(self.m_model.m_user_data) ~= nil then
        GameUtil:setUserAvatar(HeadNode, self.m_model.m_user_data)
        self:setTextByLanKey("name_text", self.m_model.m_user_data.name)
    end
    self:refreshGetData()
end

function M:refreshGetData()
    local guess_cfg = self.m_model:getGuessRewardData()
    if guess_cfg and guess_cfg.season_rewards then
        local reward_data = RewardUtil:getProcessRewardData(guess_cfg.season_rewards[1])
        self:setImg(reward_data.icon_name, reward_data.atlas_name, "get_icon_img")
        local cost_text = self:setTextByLanKey("get_num", reward_data.data_num)
    end
    
end

function M:destroy()
    M.super.destroy(self)
end

return M