local M = class("HuashanSwordBattleDetailControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "battle_log_btn" then -- 战斗统计
        self:openView("Pops.BattleStatistics", {data = self.m_model.m_data, round = data.index, log_data = self.m_model.m_log_data})
    end
end

return M
