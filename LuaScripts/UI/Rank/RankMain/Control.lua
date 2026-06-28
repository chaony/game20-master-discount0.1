local M = class("RankMainControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("Amb_2D_indoor_fire")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 22})
    elseif msg == "item_node_1" then
        self:openRankList(1)
    elseif msg == "item_node_2" then
        self:openRankList(2)
    elseif msg == "item_node_3" then
        self:openRankList(3)
    elseif msg == "item_node_4" then
        self:openRankList(4)
    elseif msg == "item_node_5" then
        self:openRankList(5)
    elseif msg == "item_node_6" then
        self:openRankList(6)
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", {title = "tid#ranking1", content = "tid#ranking2"})
    elseif msg == "refresh_red_point" then
        self.m_model:updateRedPoint(data)
        self.m_view:refreshRedPoint()
    end
end

function M:openRankList(index)
    local rank_cfg = self.m_model:getRankCfgByIndex(index)
    self:openView("Rank.RankList", {id = rank_cfg.id, rank_cfg = rank_cfg, index = index, all_rank_types = self.m_model:getAllRankTypes()})
end

function M:destroy()
    audio:SendEvtUI("Reset_Lpf_Amb_2D_wind_bird_water_frog")
    M.super.destroy(self)
end

return M
