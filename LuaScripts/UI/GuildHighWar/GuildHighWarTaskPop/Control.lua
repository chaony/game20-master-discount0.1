local M = class("GuildHighWarTaskPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refreshRedPoint", nil, "GuildHighWar.GuildHighWarMain")
        self:closeView()
    elseif msg == "refreshExploreScroll" then
        self.m_view:updateTitleNode()
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "reward_btn" then
        audio:SendEvtUI("UI_Tab_N7")
            local function netCallback(response)
                if response then
                    RewardUtil:rewardTipsByData(response.reward)
                    self.m_model:UpdateData(response)
                    self.m_view:refreshUI()
                end
            end
        self.m_model:getNetData("guild_high_war_new_quest_recy", {quest_id = data.id},netCallback)
    elseif msg == "auto_get_btn" then
        audio:SendEvtUI("UI_Tab_N7")
        self:questForAllReward(self.m_model.m_select_tab_index) --1 个人， 2 帮会
    elseif msg == "box_click" then
        audio:SendEvtUI("Play_UI_TresureChest")
        local rewards = data.data.reward or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == -1})
    elseif msg == "goto_zl_btn" then --战令
        --QuickOpenFuncUtil:openFunc(10009)
        QuickOpenFuncUtil:openFunc(10018,{open_id = 109})
    elseif msg == "score_btn" then --积分
        local item_data = {}
        item_data.name = Language:getTextByKey("guild_high_war_yan_text_0030")
        item_data.story = Language:getTextByKey("guild_high_war_yan_text_0031")
        static_rootControl:openView("Pops.CommonItemTipsPop", {data = item_data, target_obj = data})
    end
end

function M:switchTabBtn(index)
    if self.m_model.m_select_tab_index ~= index then
        self.m_model.m_select_tab_index = index
        self.m_view:switchNode(index)
    end
end

return M
