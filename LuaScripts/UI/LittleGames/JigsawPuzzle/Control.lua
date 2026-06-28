local M = class("JigsawPuzzleControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "backBtn" then    -- 返回
        self:closeView()
    elseif msg == "StartGame" then
        self.m_view:startGame()
    elseif msg == "nextBtn" then
        self.m_view:resetGame()
    end
end

-- 结算积分 group_id: 组id  score: 积分
function M:gameStreetSettlement()
    local function netCallback(response)
        self:updateMsg("refresh_ui", nil, "LittleGames")
    end
    local params = {group_id = self.m_model.m_group_id, score = self.m_model.m_score}
    self.m_model:getNetData("game_street_settlement", params, netCallback)
end

-- 多期结算积分 group_id: 组id  score: 积分
function M:gameMultStreetSettlement()
    local function netCallback(response)
        self:updateMsg("refresh_ui", nil, "LittleGames")
    end
    local params = {version = self.m_model.m_group_id, score = self.m_model.m_score}
    self.m_model:getNetData("mult_settlement", params, netCallback)
end


return M
