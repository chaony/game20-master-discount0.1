local M = class("MythArenaStageControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
        local not_close_tab = {}
        not_close_tab = {["Loading.SyncLoadBigLoading"] = 1, ["Loading.SmallLoading"] = 1, ["Loading.BattleLoading"] = 1, ["Loading.BigLoading"] = 1, ["Main.TotalWorld"] = 1}
        static_rootControl:closeAllViewPop(not_close_tab)
    elseif msg == "go_btn" then --快速导航
        --self:openView("MythArena.MythArenaShowRank")
        if self.m_model.m_big_stage == 1 then
        elseif self.m_model.m_big_stage == 2 then
            self:openView("MythArena.MythArenaMain")
        elseif self.m_model.m_big_stage > 2 and self.m_model.m_big_stage < 8 then
            if self.m_model.m_small_stage == 1 then
                self:openView("MythArena.MythArenaSecond", {small_end_time = self.m_model.m_small_end_time, big_stage = self.m_model.m_big_stage, small_stage = self.m_model.m_small_stage})
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("wlsh_text_0010"), delay_close = 2})
            end
        elseif self.m_model.m_big_stage == 8 then
            self:openView("MythArena.MythArenaShowRank")
        end
    elseif msg == "reward_btn" then
        self:openView("MythArena.MythArenaRewardPop")
    elseif msg == "help_btn" then
        local params = {}
        params.title = "wlsh_text_0004"
        params.content = "tid#myth_tips"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "pop_promotino" then
        self:openView("MythArena.MythArenaPromotion", {pop_data = self.m_model.m_pop_data})
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;
