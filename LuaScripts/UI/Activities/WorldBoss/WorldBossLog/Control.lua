local M = class("WorldBossLogControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "back_btn" then
    	self:closeView()
    elseif msg == "statistics_btn" then
        local item_data = data.cell_data
        self:openView("Pops.BattleStatistics", {battle_id = item_data.battle_id, round = 1, log_data = item_data,battle_config_id = self.m_model.m_battle_config_id})
    end
end

return M
