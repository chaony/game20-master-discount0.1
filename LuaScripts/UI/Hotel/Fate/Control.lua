local M = class("FateControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Hotel.Fate.Guide"
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "close_new_btn" then -- 关闭
        self:closeView()
    elseif msg == "help_btn" then
        local desc = Language:getTextByKey("tid#RestaurantDescription_102")
        local params = {title = "lakes_love_text_006", content = desc}
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "story_btn" then
        local fate = data.cell_data
        if self.m_model.m_cur_hero == fate.hero_id then
            local stages = self.m_model:getFateStages(fate.hero_id)
            self:openView("Hotel.Fate.FateStory", {hero = fate.hero_id, cur_stage = fate.stage, list_stage = stages, times = self.m_model.m_cur_dare_num, times_max = self.m_model.m_dare_num_max})
            return
        end
        if self.m_model.m_cur_hero == 0 then
            self:requestStory(fate.hero_id)
            return
        end
        local params = {
            text = Language:getTextByKey("fate_text_008"),
            tow_close_btn = true,
            on_ok_call = function ()
                self:requestStory(fate.hero_id)
            end
        }
        self:openView("Pops.CommonPop", params)
    elseif msg == "box" then
        local rewards = data.cell_data.clear_awards or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.cell_data.reward_status == 2})
        --self:openView("Hotel.Fate.FateRewardPop", {fate = data.cell_data})
    elseif msg == "reward_box" then
        local hero_id = data.cell_data.hero_id
        self:requestGetReward(hero_id)
    elseif msg == "refresh_data" then
        if data.stage_data.result then
            local hero_id = data.stage_data.cur_hero
            local stage = data.stage_data.stage
            self.m_model:updateFate(hero_id, stage) --更新关卡
            self.m_model.m_cur_dare_num = data.stage_data.cur_dare_num
            --刷新界面
            self.m_view:refreshUI()
            --重新打开聆听故事
            local fate = self.m_model:getFate(hero_id)
            local stages = self.m_model:getFateStages(fate.hero_id)
            self:openView("Hotel.Fate.FateStory", {hero = fate.hero_id, cur_stage = fate.stage, list_stage = stages, times = self.m_model.m_cur_dare_num, times_max = self.m_model.m_dare_num_max})
            --显示关卡奖励
            if data.stage_data.reward ~= nil then
                local reward = RewardUtil:mergeRewardAndFormat(data.stage_data.reward)
                RewardUtil:rewardTipsByRewards(reward)
            end
        end
    end
end

function M:requestStory(hero_id)
    local params = {hero = hero_id}
    self.m_model:getNetData("hotel_love_listen", params, function(response)
        if response then
            --重新打开情缘界面
            self:requestUpdateFate()
            --打开聆听故事
            --self.m_model.m_cur_hero = response.cur_hero
            --local fate = self.m_model:getFate(response.cur_hero)
            --local stages = self.m_model:getFateStages(response.cur_hero)
            --self:openView("Hotel.Fate.FateStory", {hero = response.cur_hero, cur_stage = fate.stage, list_stage = stages, times = self.m_model.m_cur_dare_num, times_max = self.m_model.m_dare_num_max})
        end
    end, nil, nil, nil)
end

function M:requestUpdateFate()
    local params = {}
    self.m_model:getNetData("hotel_love_info", params, function(response)
        if response then
            --更新情缘数据
            self.m_model:updateData(response)
            self.m_view:refreshUI()
            --打开聆听故事
            local hero_id = self.m_model.m_cur_hero
            local fate = self.m_model:getFate(hero_id)
            local stages = self.m_model:getFateStages(hero_id)
            self:openView("Hotel.Fate.FateStory", {hero = hero_id, cur_stage = fate.stage, list_stage = stages, times = self.m_model.m_cur_dare_num, times_max = self.m_model.m_dare_num_max})
        end
    end, nil, nil, nil)
end

function M:requestGetReward(hero_id)
    local params = {hero = hero_id}
    self.m_model:getNetData("hotel_love_clear_recv", params, function(response)
        if response then
            self.m_model:updateRewardStatus(response.hero)
            self.m_view:refreshUI()
            if response.reward ~= nil then
                --self:setOnceTimer(1.0, function ()
                    local reward = RewardUtil:mergeRewardAndFormat(response.reward)
                    RewardUtil:rewardTipsByRewards(reward)
                    --self:closeView()
                --end)
            end
        end
    end, nil, nil, nil)
end

function M:destroy()
    M.super.destroy(self)
end

return M