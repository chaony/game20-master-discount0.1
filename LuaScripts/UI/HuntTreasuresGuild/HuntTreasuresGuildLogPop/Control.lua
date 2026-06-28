local M = class("HuntTreasuresGuildLogPop",LikeOO.OOControlBase)

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
    elseif msg == "go_btn" then
        local region_id, location_id = self.m_model:getRidAndLid(data.index)
        self:updateMsg("change_area", { region_id = region_id, location_id = location_id, close_view_name = "HuntTreasuresGuildLogPop" }, "HuntTreasuresGuild")
    end
end

function M:destroy()
    M.super.destroy(self)
end

function M:requestVideo(battle_log_id, region_id)
    local races = GameUtil:getActiveRacesByRegionId(region_id,self.m_model.m_version)
    self:openView("Pops.BattleStatistics",  {mode = GlobalConfig.BATTLE_MODE.ACTIVE_MINING, battle_id = battle_log_id, round = 1, races = races})
end
return M;
