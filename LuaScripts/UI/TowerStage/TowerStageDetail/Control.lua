local M = class("TowerStageDetailControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "look_statistics_data" then
        local player_data = data.cell_data
        local battle_id = player_data.battle_id
        self:openView("Pops.BattleStatistics", {battle_id = battle_id, round = 1, log_data = player_data})
    elseif msg == "item_click" then
    	local player_data = data.cell_data
    	self:openView("Pops.PlayerInfo", {uid = player_data.uid, look_model = 1})
    end
end

return M
