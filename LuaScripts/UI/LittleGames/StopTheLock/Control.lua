local M = class("StopTheLockControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "backBtn" then    -- 返回
        self:closeView()
    elseif msg == "start_btn" then
        self.m_view:startAnimation()
    elseif msg == "nextBtn" then
        self.m_view:resetGame()
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


return M
