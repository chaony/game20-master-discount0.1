local M = class("UnionHallControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh",nil,"parent")
        self:closeView()
    elseif msg == "union_shop_btn" then -- 帮会商店
        self:openView("Shop", {shop_type = 2})
    elseif msg == "accounting_room_btn" then -- 账房先生
        self:openView("Union.UnionContributionPop", {times = self.m_model.m_data.contribution_times})
    elseif msg == "union_map_btn" then -- 帮会地图
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("rpg_scroll_9"), delay_close = 2})
    elseif msg == "union_manage_btn" then -- 帮会管理
        self:openView("Union.UnionMain")
    elseif msg == "union_boss_btn" then -- 帮会boss
        self:openView("UnionBoss")
    elseif msg == "union_shenlu_btn" then -- 帮会神炉
        self:openView("Union.UnionArtifactPop", {data = self.m_model.m_data})
    elseif msg == "union_activity_btn" then -- 帮会活动
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("rpg_scroll_9"), delay_close = 2})
    elseif msg == "union_notice_btn" then -- 帮会通告
        local params = {}
        params.title = "union_str_1046"
        local des = self.m_model.m_data.guild.desc
        if des == nil or des == "" then
            des = Language:getTextByKey("union_str_1050")
        end
        params.content = des
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "fresh_red_point" then
        self.m_view:refreshUI()
    elseif msg == "update_data" then
        self.m_model:updateData(data)
        self.m_view:refreshUI()
    end
end

return M;
