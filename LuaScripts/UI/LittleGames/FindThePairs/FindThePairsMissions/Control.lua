local M = class("FindThePairsMissionsControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "close_view" then
        self:closeView()
    else
        local start_idx, _ = string.find(msg, "Mission")
        if start_idx then
            CS.Mission.selectedMission = data:GetComponent("Mission")
            --self:openView("LittleGames.FindThePairs.FindThePairsLevels")
            local tableLevel = self.m_view:findGameObject("Level"):GetComponent("TableLevel")
            CS.TableLevel.selectedLevel = tableLevel;
            CS.LevelsTable.selectedLevelID = tableLevel.ID
            self:openView("LittleGames.FindThePairs.FindThePairsGame", {group_id = self.m_model.m_group_id, game_id = self.m_model.m_game_id, mult = self.m_model.m_mult})
        end
        self:setOnceTimer(0.8,function()
            self.m_view:setViewVisible()
        end)
    end
end

return M
