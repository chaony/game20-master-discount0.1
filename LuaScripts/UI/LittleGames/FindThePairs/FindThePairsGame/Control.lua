local M = class("FindThePairsGameControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "backBtn" then    -- 返回
        self:closeView()
    elseif msg == "time_out_level" then
        self:updateMsg(99999)
    elseif msg == "win_level" then
        self:updateMsg(99999)
    elseif msg == "nextBtn" then
        self.m_view:resetGame()
    else
        local start_index, end_index = string.find(msg, "game_over_")
        if start_index then
            local sub_index = end_index + 1
            local score = checknumber(string.sub(msg, sub_index))
            if self.m_model.m_open_type == "raccon" then
                self:gameStreetCommonSettlement(score)
            elseif self.m_model.m_is_mult == true then
                self:gameMultStreetSettlement(score)
            else
                self:gameStreetSettlement(score)
            end
            
          
        end
    end
end

-- 结算积分 group_id: 组id  score: 积分
function M:gameStreetCommonSettlement(score)
    local function netCallback(response)
        --self:updateMsg("refresh_ui", nil, "LittleGames")
    end
    local params = {vsn = self.m_model.m_group_id, score = score, open_id = self.m_model.m_open_id}
    self.m_model:getNetData("game_street_common_settlement", params, netCallback)
end


-- 结算积分 group_id: 组id  score: 积分
function M:gameStreetSettlement(score)
    local function netCallback(response)
        self:updateMsg("refresh_ui", nil, "LittleGames")
    end
    local params = {group_id = self.m_model.m_group_id, score = score}
    self.m_model:getNetData("game_street_settlement", params, netCallback)
end

-- 多期结算积分 group_id: 组id  score: 积分
function M:gameMultStreetSettlement(score)
    local function netCallback(response)
        self:updateMsg("refresh_ui", nil, "LittleGames")
    end
    local params = {version = self.m_model.m_group_id, score = score}
    self.m_model:getNetData("mult_settlement", params, netCallback)
end

function M:destroy()
    self:updateMsg("close_view", nil, "LittleGames.FindThePairs.FindThePairsMissions")
    self:updateMsg("close_view", nil, "LittleGames.FindThePairs.FindThePairsMissionsRaccon")
    M.super.destroy(self)
end

return M
