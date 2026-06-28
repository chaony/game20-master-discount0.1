local M = class("MoonShadowBattleControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateRankData()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshRedPointBattle", nil, "MoonShadow.MoonShadowMain")
        self:closeView()
    elseif msg == "Tiaozhan" then
        self:openView("Fivelines", {enemy = self.m_model:getEnemy(), heirloom = self.m_model:getHeirloom()})
    elseif msg == "battle_end_refresh_ui" then
        self.m_model:setMaxDamageData(data.data.max_damage or 0)
        self.m_view:updateMaxDamage()
        self:updateRankData()
    elseif msg == "switch_btn" then
        if self.m_model:getRankType() == 1 then
            self.m_model.m_rank_type = 0
        elseif self.m_model:getRankType() == 0 then
            self.m_model.m_rank_type = 1
        end
        self:updateRankData()
    elseif msg == "chakan_btn" then
        self:openView("MoonShadow.MoonShadowRankListPop", {vsn = self.m_model.m_version, data = self.m_model.m_rank_data})
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", { title = "tid#moon_shadow_test01", content = "tid#moon_shadow_test02" })
    end
end

function M:updateRankData()
    local function receivetCallback(response)
        if response then
            self.m_model:updateRankData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.version = self.m_model:getVersion()
    params.is_day = self.m_model:getRankType() --排行榜类型
    params.start = 1
    params.stop = 20
    self.m_model:getNetData("mood_shadow_rank_info", params, receivetCallback)
end

return M
