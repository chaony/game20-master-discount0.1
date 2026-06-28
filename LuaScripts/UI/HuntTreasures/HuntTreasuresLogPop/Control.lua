local M = class("HuntTreasuresLogPop",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint() 
    elseif msg == "huifang_btn" then
        local region_id, location_id = self.m_model:getRidAndLid(data.index)
        self:requestVideo(self.m_model:getBattleLogId(data.index), region_id)
    elseif msg == "my_area_btn" then
        self:openView("HuntTreasures.HuntTreasuresMyTeamPop")
        self:closeView()
    elseif msg == "go_btn" then
        local region_id, location_id = self.m_model:getRidAndLid(data.index)
        self:updateMsg("change_area", { region_id = region_id, location_id = location_id, close_view_name = "HuntTreasuresLogPop" }, "HuntTreasures")
    end
end

function M:destroy()
    M.super.destroy(self)
end

function M:requestVideo(battle_log_id, region_id)
    local races = GameUtil:getRacesByRegionId(region_id)
    self:openView("Pops.BattleStatistics",  {mode = GlobalConfig.BATTLE_MODE.MINING, battle_id = battle_log_id, round = 1, races = races})
end
return M;
