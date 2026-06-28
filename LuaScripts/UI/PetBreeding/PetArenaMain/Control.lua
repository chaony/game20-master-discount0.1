---@class PetArenaMainControl: OOControlBase
---@field m_model PetArenaMainModel
---@field m_view PetArenaMainView
local M = class("PetArenaMainControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, data)
    if msg == 99999 then
        -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refresh_entrances", nil, "PengLaiBazzar.PengLaiBazzarIsland")
        self:updateMsg("redPoint_refresh", nil, "PetBreeding.PetBreedingMain")
        self:closeView()
    elseif msg == "guide_btn" then
        --快速导航
        self:openView("WorldMap.WorldMapGuide", { pop_from_func_id = -1 })
    elseif msg == "team_btn" then
        --布阵
        self:openView("Formation", { mode = GlobalConfig.BATTLE_MODE.PET_DOUJI })
    elseif msg == "challenge_btn" then
        --挑战
        if self.m_model.m_is_can_match then
            self:matchWar()
        else
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_arena_text_0020"), delay_close = 2 })
        end
        
    elseif msg == "feed_btn" then
        --投喂
        local state, feedList, moodList = self:checkFeedList()
        if state == 1 then
            self:openView("PetBreeding.PetArenaFeedPop", { feed_list = feedList, mood_list = moodList })
        elseif state == 2 then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_arena_text_0016"), delay_close = 2 })
        elseif state == 3 then
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_arena_text_0014"), delay_close = 2 })
        end
    elseif msg == "explain_btn" then
        --说明
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("pet_arena_text_0017"), content = Language:getTextByKey("tid#PetRuleDes_6") })
    elseif msg == "add_text_bg" or msg == "add_bg" then
        --加成
        self.m_view:showAddPanel()
    elseif msg == "panel_close_btn" then
        self.m_view:hideAddPanel()
    elseif msg == "mood_bg1" then
        self.m_view:showMoodPanel(1)
    elseif msg == "mood_bg2" then
        self.m_view:showMoodPanel(2)
    elseif msg == "mood_bg3" then
        self.m_view:showMoodPanel(3)
    elseif msg == "canReceived1" then
        self:onClickBox(1)
    elseif msg == "canReceived2" then
        self:onClickBox(2)
    elseif msg == "canReceived3" then
        self:onClickBox(3)
    elseif msg == "canReceived4" then
        self:onClickBox(4)
    elseif msg == "canReceived5" then
        self:onClickBox(5)
    elseif msg == "refreshScoreAndWeekTimes" then
        --刷新分数和每周次数
        self.m_model:setScore(data.score)
        self.m_model:setWeekTimes(data.week_times)
        self.m_view:refreshScore()
        self.m_view:refreshAwardNode()
        self.m_view:refreshSlider()
    elseif msg == "refreshPetModel" then
        --刷新宠物模型(战斗结束也会调用，重新加载ab)
        self.m_view:updatePetModel()
    elseif msg == "pet_mood_refresh" then
        --刷新宠物心情
        self.m_view:refreshPetMood()
        if next(self.m_model.m_feed_pet_ids) then
            self.m_view:playEffect()
        end
    elseif msg == "getNewData" then
        --刷新下一期 跨周（天刷新）
        self:getNewData(data.isSeasonRefresh)
    elseif msg == "skip_battle_btn" then
        --跳过
        self.m_model:setJumpState()
        self.m_view:refreshJumpState()
    end
end

function M:updateTime()
    self.m_view:setTimeText()
end

function M:onClickBox(index)
    audio:SendEvtUI("UI_Tab_N7")
    local data = self.m_model:getAwardCfgByIndex(index)
    local isCanRecv = (self.m_model:getWeekTimes() >= data.num) and (not self.m_model:checkReceivedList(index))
    if isCanRecv then
        self:recvScoreAward(index)
    end
end

function M:recvScoreAward(index)
    local params = { reward_id = index }
    self.m_model:getNetData("pet_arena_week_recv", params, function(response)
        if response then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model:updateRewardState(response.week_recv)
            self.m_view:refreshAwardNode()
        end
    end, nil, nil, nil)
end

function M:matchWar()
    local function callfunc(response)
        if self.m_model:getJumpState() then
            local data = {}
            data.mode = GlobalConfig.BATTLE_MODE.PET_DOUJI
            data.result = response.result
            data.battle_data = response
            --data.quick_pass = true
            data.full_mask_flag = true
            self:openView("Settlement", data)
        else
            self:openView("GamePanel", { data = response, mode = GlobalConfig.BATTLE_MODE.PET_DOUJI })
        end
        self:updateMsg("refreshScoreAndWeekTimes", response)
    end
    if self:checkHasTeam() then
        self.m_model:getNetData("pet_battle_start", nil, callfunc)
    end
    
end

function M:getNewData(isSeasonRefresh)
    if isSeasonRefresh then
        self.m_model:setSeasonState(true)
    end
    self.m_model:getNetData("pet_arena_index", nil, function(data)
        if data then
            self.m_model:initData(data)
            self.m_view:refreshUI()
        end
    end)
end

function M:checkFeedList()
    self.m_model.m_feed_pet_ids = {}
    local pet_ids = UserDataManager.hero_data:getTeamByKey("pet_pvp")
    local feedList = {}
    local moodList = {}
    for i = 1, 3 do
        local data = UserDataManager.pet_data:getPetDataById(pet_ids[i])
        if pet_ids[i] ~= "" and data and data.mood and data.mood < 3 then
            table.insert(moodList, data.mood)
            table.insert(feedList, pet_ids[i])
            table.insert(self.m_model.m_feed_pet_ids, i)
        end
    end
    if next(feedList) and next(moodList) then
        return 1, feedList, moodList
    elseif #pet_ids <= 0 or (pet_ids[1] == "" and pet_ids[2] == "" and pet_ids[3] == "") then
        return 2
    end
    return 3
end

function M:checkHasTeam()
    local pet_ids = UserDataManager.hero_data:getTeamByKey("pet_pvp")
    if #pet_ids <= 0 or (pet_ids[1] == "" and pet_ids[2] == "" and pet_ids[3] == "") then
        GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("pet_arena_text_0019"), delay_close = 2 })
        return false
    end
    return true
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
