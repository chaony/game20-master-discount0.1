local M = class("WorldBossRankControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "log_btn" then
        local cell_data = data.cell_data
        local battle_id = cell_data.battle_id or 0
        if battle_id > 0 then
            local boss_id = self.m_model.m_boss_id
            self:openView("Pops.BattleStatistics", {battle_id = cell_data.battle_id, round = 1, log_data = cell_data, boss_id = boss_id})
        else
            Logger.logError(cell_data, "battle_id is error :")
        end
    elseif msg == "cell_btn" then
        local cell_data = data.cell_data
        self:openView("Pops.PlayerInfo", {uid = cell_data.user.uid})
    end
end

return M
