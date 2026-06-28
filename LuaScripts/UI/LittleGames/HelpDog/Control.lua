local M = class("HelpDagMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.LittleGames.HelpDog.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "backBtn" then    -- 返回
        self:updateMsg("check_guide" ,nil ,"parent")
        self:closeView()
        SceneManager:getCurSceneView():setBGMusic()
    elseif msg == "level_cell_1" then
        self:switchLevel(1)
    elseif msg == "level_cell_2" then
        self:switchLevel(2)
    elseif msg == "level_cell_3" then
        self:switchLevel(3)
    elseif msg == "receiveReward" then --领奖
        local complete_num = self.m_model:getLevelCompleteNum()
        if complete_num >= data and self.m_model:getRewardStage(data) == 0 then
            self:receiveReward(data)
        end
    elseif msg == "level_1_stop_num_but_2" then --第二关
        local refreshCallback = function()
            --self:updateData()
            --self.m_guide:checkGuide()
        end
        self:openView("LittleGames.HelpDog.HelpDagLevel",{guide = 1,stage_id = self.m_model.m_show_level_num,level_id = 2,callback = refreshCallback})
        return
    elseif msg == "level_1_stop_num_but_3" then --第三关
        local refreshCallback = function()
            --self:updateData()
            --self.m_guide:checkGuide()
        end
        self:openView("LittleGames.HelpDog.HelpDagLevel",{guide = 1,stage_id = self.m_model.m_show_level_num,level_id = 3,callback = refreshCallback})
        return
    elseif msg == "begin_btn" then --开始游戏
        local isopen, unlock_stage= self.m_model:getLevelIsOpen(data)
        if isopen == 1 then
            local refreshCallback = function()
                --self:updateData()
                --self.m_guide:checkGuide()
            end
            audio:SendEvtUI("UI_FuLi")
            self:openView("LittleGames.HelpDog.HelpDagLevel",{guide = data.guide,stage_id = self.m_model.m_show_level_num,level_id = data.id,callback = refreshCallback})
        elseif isopen == 2 then
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0823",data.id - 1), delay_close = 2})
            audio:SendEvtUI("UI_Click_N1")
        elseif isopen == 3 then --引导
            local big = math.floor(unlock_stage/100)
            local small = unlock_stage - big * 100
            local stage_str = big.."-"..small
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("little_game_text_010",stage_str), delay_close = 2})
            local have_guide = UserDataManager.guide_data:setAnyTeamGuide(-50)
            self.m_guide:checkGuide()
            audio:SendEvtUI("UI_Click_N1")
        elseif isopen == 4 then
            local big = math.floor(unlock_stage/100);
            local small = unlock_stage - big * 100;
            local stage_str = big.."-"..small;
            GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("little_game_text_010",stage_str), delay_close = 2})
            audio:SendEvtUI("UI_Click_N1")
        end
    elseif msg == "check_guide" then --刷新ui
        self.m_guide:checkGuide()
    elseif msg == "refresh_ui" then
        self.m_model:updateServerData(data.data)
        self.m_view:refreshUI()
    end
end

--切换关卡
function M:switchLevel(id)
    self.m_model.m_show_level_num = id
    self.m_view:refreshUI()
end

--领取奖励
function M:receiveReward(id)
    local function netCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateServerData(response["data"])
        self.m_view:refreshUI()
    end
    local params = {stage_id = self.m_model.m_show_level_num, level_id = id}
    self.m_model:getNetData("big_game_receive", params, netCallback)
end

--刷新数据
function M:updateData()
    local function netCallback(response)
        self.m_model:updateServerData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("big_game_index", nil, netCallback)
end

--function M:destroy()
--    --SceneManager:getCurSceneView():setBGMusic()
--end
return M
