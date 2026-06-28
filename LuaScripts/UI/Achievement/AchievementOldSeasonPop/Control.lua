local M = class("AchievementOldSeasonPopControl", LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        self:updateMsg("refreshRedPoint", nil, "Achievement")
        self:closeView()
    elseif type(msg) == "number" then
        self:switchTabBtn(msg)
    elseif msg == "switch_tab" then
        self:switchTabBtn(data.index, data.cell_object)
    elseif msg == "goto_btn" then
        self:updateMsg("common_refresh", nil, "parent")
        static_rootControl:closeAllViewPop()
        local go_type = data.cfg.go_type or {}
        QuickOpenFuncUtil:openFunc(go_type)
    elseif msg == "get_top_reward" then
        self:questChapterReward(data)
    elseif msg == "fengyunlu_btn" then
        self:openView("Achievement.AchievementRankList",{season_id = self.m_model.m_season_id})
    elseif msg == "more_btn" then
        if self.m_model.click_more_btn ~= 0 then -- 收起章节任务
            self.m_model.click_more_btn = 0
            self.m_model:changeSeasonData(self.m_model.m_sel_tab_index)
        else
            self.m_model:initClickSeasonChapter(self.m_model.m_sel_tab_index, data.reward_chapter) -- 打开章节任务
        end
        self.m_view:refreshTaskLoopScroll()
    end
end

-- tab按钮切换
function M:switchTabBtn(index,obj)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_model.click_more_btn = 0
        self.m_model:changeSeasonData(self.m_model.m_sel_tab_index)
        self.m_view:switchTabNode(index,obj)
    end
end

-- 领取章节奖励 chapter_id: 任务id
function M:questChapterReward(data)
    local seasonInfo = self.m_model.old_season_list[self.m_model.m_sel_tab_index] or 0
    local function netCallback(response)
        if response then
            local param = {main_quests = response.main_quests or {}}
            self:updateMsg("old_season_data_update", param, "Achievement")
            RewardUtil:rewardTipsByData(response.reward)
            --self.m_model:setSeasonChapterRedPointState(seasonInfo.season, data.chapter_id)
            --self.m_model:setSeasonChapterReceivedStateBySeasonChapter(param)
            --self.m_model:changeSeasonData(self.m_model.m_sel_tab_index)
            self.m_model:updateData(response)
            self.m_view:createLoopScroll()
            self.m_view:refreshTaskLoopScroll() -- 任务列表
        end
    end
    local params = {seanson = tonumber(seasonInfo.season), chapter_id = data.chapter_id}
    self.m_model:getNetData("quest_season_recv_chapter_reward", params, netCallback)
end

function M:destroy()
    M.super.destroy(self)
end

return M
