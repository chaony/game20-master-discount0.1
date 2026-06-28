---@class AchievementControl:OOControlBase
local M = class("AchievementControl", LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        self:updateMsg("refresh_red_point" ,nil ,"SeasonPreview")
        self:updateMsg("refreshRedPoint" ,nil ,"Main.TotalWorld")
        self:closeView()
    elseif type(msg) == "number" then
        self:switchTabBtn(msg)
    elseif msg == "switch_tab" then
        self:switchTabBtn(data.index, data.cell_object)
    elseif msg == "goto_btn" then
        self:updateMsg("common_refresh", nil, "parent")
        local go_type = data.cfg.go_type or {}
        local not_close_tab = {}
        if type(go_type) == "table" and (go_type[1] == 35 or go_type[1] == 87) then --跳到帮会战，奇门遁甲时
            not_close_tab = {["Loading.SyncLoadBigLoading"] = 1, ["Loading.SmallLoading"] = 1, ["Loading.BattleLoading"] = 1, ["Loading.BigLoading"] = 1, ["Main.TotalWorld"] = 1}
        end
        static_rootControl:closeAllViewPop(not_close_tab)
        QuickOpenFuncUtil:openFunc(go_type)
    elseif msg == "reward_btn" then
        self:questForTaskReward(data)
    elseif msg == "get_top_reward" then 
        self:questChapterReward(data)
    elseif msg == "fengyunlu_btn" then
        self:openView("Achievement.AchievementRankList",{season_id = self.m_model.m_season_id})
    elseif msg == "season_shop_btn" then
        self:openView("Shop", {is_season_score = true, shop_type = 26})
    elseif msg == "old_season_btn" then
        if self.m_model.m_season_id and self.m_model.m_season_id > 1 then
            self:openView("Achievement.AchievementOldSeasonPop",{season_id = self.m_model.m_season_id, main_quests = self.m_model.main_quests})
        else
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("achievement_text11"), delay_close = 2})
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "achievement_text10"
        params.content = "tid#SeasonDes_01"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "old_season_data_update" then
        self.m_model:updateMainSeasonQuest(data.main_quests)
        self.m_view:refreshWQLCRedPoint()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshWQLCRedPoint()
    elseif msg == "buff_btn" then
        if self.m_model.buff_open == true then
            self.m_model.buff_open = false
        else
            self.m_model.buff_open = true
        end
        self.m_view:setObjectVisible("season_buff_count", self.m_model.buff_open == true)
        local season = UserDataManager:getCurSeason()
        UserDataManager.local_data:setUserDataByKey("red_point_336_"..season, 0)
        self.m_view:refreshWQLCRedPoint()
    elseif msg == "season_btn_close" then
        self.m_model.buff_open = false
        self.m_view:setObjectVisible("season_buff_count", self.m_model.buff_open == true)
    end
end

-- tab按钮切换
function M:switchTabBtn(index,obj)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index,obj)
    end
end

-- 领取章节奖励 chapter_id: 任务id
function M:questChapterReward(data)
    local function netCallback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateMainSeasonQuest(response.main_quests)
            self.m_view:refreshTaskLoopScroll()
            self.m_view:createLoopScroll(false)
            self.m_view:refreshTopInfo()
            self.m_view:updateTopData()
        end
    end
    local params = {seanson = self.m_model.m_season_id, chapter_id = data.chapter_id}
    self.m_model:getNetData("quest_season_recv_chapter_reward", params, netCallback)
end

-- 领取任务奖励
function M:questForTaskReward(data)
    local function callback(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateMainSeasonQuest(response.main_quests)
            self.m_view:refreshTaskLoopScroll()
            self.m_view:createLoopScroll(false)
            self.m_view:refreshTopInfo()
            self.m_view:updateTopData()
        end
    end
    local params = {seanson = self.m_model.m_season_id, quest_id = data.cfg.id} 
    self.m_model:getNetData("quest_season_recv_quest_reward", params, callback)
end

function M:destroy()
    M.super.destroy(self)
end

return M
