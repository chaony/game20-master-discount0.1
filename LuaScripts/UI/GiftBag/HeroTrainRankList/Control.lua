local M = class("HeroTrainRankListControl", LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
    elseif msg == "check_tag" then
        self.m_model.m_select_index = data
        self.m_view:refreshUI()
    elseif msg == "RankListItem" then
        local cell_data = data.cell_data
        self:openView("Pops.PlayerInfo", {uid = cell_data.user.uid})
    elseif msg == "battle_log_btn" then
        local item_data = data.cell_data
        local battle_id = item_data.battle_id or 0
        if battle_id > 0 then
            local boss_id = self.m_model.hero_train_data.train_id
            self:openView("Pops.BattleStatistics", {battle_id = item_data.battle_id, round = 1, log_data = item_data, boss_id = boss_id})
        else
            Logger.logError(item_data, "battle_id is error :")
        end
    end
end


return M
