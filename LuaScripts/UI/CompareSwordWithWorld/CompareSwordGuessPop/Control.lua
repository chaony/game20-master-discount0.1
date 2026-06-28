local M = class("CompareSwordGuessPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()

    end)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView() 
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "guess_left_btn" then
        self:requireGuessNetData(true)
    elseif msg == "guess_right_btn" then
        self:requireGuessNetData(false)
    elseif msg == "left_btn" then 
        local play_data, play_data2 = self.m_model:getGuessBattlePlayerData()
        self:openView("Pops.PlayerInfo", {uid = play_data.user.uid, look_model = 5})   
    elseif msg == "right_btn" then    
        local play_data, play_data2 = self.m_model:getGuessBattlePlayerData()
        self:openView("Pops.PlayerInfo", {uid = play_data2.user.uid, look_model = 5})
    elseif msg == "updateGress" then
        self.m_model.m_data.guess_data = data.guess_data or {}
        self.m_model.m_data.quiz_count = data.quiz_count or {}
        self.m_view:refreshUI()
    elseif msg == "btn_gotoGuess" then
        self:updateMsg("onclick_btn_enter", {raceType  = 1}, "CompareSwordWithWorld.GameOfHeavenAndEarth") --默认天赛
        self:closeView()
    elseif msg == "huifang_btn" then
        if data.battle_log_id == 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compare_sword_race_text_046"), delay_close = 2})
            return 
        end
        self:requestVideo(data.battle_log_id)
    end
end

function M:requireGuessNetData(isLeft)
    local function receivetCallback(response)
        self.m_model.is_support_type = isLeft and 1 or 2
        self.m_model.guess_times = response.guess_times
        self.m_model.total_guess_times = response.total_guess_times
        self:updateMsg("update_times",{guess_times = response.guess_times,total_guess_times = response.total_guess_times},"CompareSwordWithWorld.GameOfHeavenAndEarth")
        self.m_view:refreshUI()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compare_sword_race_text_033"), delay_close = 2})
    end

    if self.m_model.raceType == 2 then
        local params = {
            typ = self.m_model.typ,
            group_id = self.m_model.group_id,
            rounds =self.m_model.rounds,
            battle_uuid =self.m_model.uuid,
            uid = isLeft and self.m_model.left_data.uid or self.m_model.right_data.uid,
        }
        self.m_model:getNetData("full_service_point_race_guess", params, receivetCallback)
    elseif self.m_model.raceType == 3 then
        local params = {
            typ = self.m_model.typ,
            round_stage = self.m_model.round_stage ,
            uid = isLeft and self.m_model.left_data.uid or self.m_model.right_data.uid,
        }
        self.m_model:getNetData("full_service_top_guess", params, receivetCallback)
    end
end

function M:requireRaceGuessNum()
    local function receivetCallback(response)
        self.m_model.is_support_type = 2
        self.m_model.guess_times = response.guess_times
        self.m_model.total_guess_times = response.total_guess_times
        self:updateMsg("update_times",{guess_times = response.guess_times,total_guess_times = response.total_guess_times},"CompareSwordWithWorld.GameOfHeavenAndEarth")
        self.m_view:refreshUI()
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compare_sword_race_text_033"), delay_close = 2})
    end

    if self.m_model.raceType == 2 then
        local params = {
            typ = self.m_model.typ,
            group_id = self.m_model.group_id,
            rounds =self.m_model.rounds,
            battle_uuid =self.m_model.uuid,
            uid =self.m_model.right_data.uid,
        }
        self.m_model:getNetData("full_service_point_race_guess", params, receivetCallback)
    elseif self.m_model.raceType == 3 then
        local params = {
            typ = self.m_model.typ,
            round_stage = self.m_model.round_stage ,
            uid =self.m_model.right_data.uid,
        }
        self.m_model:getNetData("full_service_top_guess", params, receivetCallback)
    end

end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        if index == 2 then
            local function nameCallback(response)
                self.m_view:switchNode(index)
                self.m_model:UpdateGuessData(response)
                self.m_view:refreshUI()
            end
            if  self.m_model.raceType == 2 then
                self.m_model:getNetData("full_service_my_guess_v2", nil, nameCallback)
            elseif self.m_model.raceType == 3 then
                self.m_model:getNetData("full_service_top_guess_index", nil, nameCallback)
            end
        else
            self.m_view:switchNode(index)
        end
    end
end

function M:requestVideo(id)
    if self.m_model.raceType ==2 then
        self:openView("CompareSwordWithWorld.CompareSwordBattleDetail", {battle_id = id, mode = GlobalConfig.BATTLE_MODE.SORT_FULL_SERVICE_POINT_RACE})
    elseif self.m_model.raceType ==3 then
        self:openView("CompareSwordWithWorld.CompareSwordBattleDetail", {battle_id = id, mode = GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION})
    end
    
end

return M
