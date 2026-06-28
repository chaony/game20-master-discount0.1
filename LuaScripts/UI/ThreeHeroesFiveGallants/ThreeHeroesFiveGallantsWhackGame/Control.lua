local M = class("ThreeHeroesFiveGallantsWhackGameControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "backBtn" then    -- 返回
        self:updateMsg("refresh_data", nil, "ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsMain")
        self:closeView()
    elseif msg == "begin_btn" then
        local remain_num = self.m_model.frequency - self.m_model.m_data.daily_times
        if remain_num > 0 then
            self.m_view:startAnimation()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("three_heroes_five_gallants_text_0025"), delay_close = 2})
        end
    elseif msg == "nextBtn" then
        local remain_num = self.m_model.frequency - self.m_model.m_data.daily_times
        if remain_num > 0 then
            self.m_view:StartGame()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("three_heroes_five_gallants_text_0025"), delay_close = 2})
        end
    else
        local start_index, end_index = string.find(msg, "game_over_")
        if start_index then
            local sub_index = end_index + 1
            local score = checknumber(string.sub(msg, sub_index))
            if self.m_model.m_is_mult == true then
                self:gameMultStreetSettlement(score)
            else
                self:gameStreetSettlement(score)    
            end
  
        end
    end
end

-- 结算积分 group_id: 组id  score: 积分
function M:gameStreetSettlement(score)
    local function netCallback(response)
        self:updateMsg("refresh_ui", nil, "LittleGames")
        if response.reward then
            RewardUtil:rewardTipsByData(response.reward) --展示奖励
        end
    end
    local params = {open_id = self.m_model.open_id,vsn =self.m_model.m_version , score = score}
    self.m_model:getNetData("game_street_common_settlement", params, netCallback)
end


return M
