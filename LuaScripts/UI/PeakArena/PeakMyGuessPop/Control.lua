local M = class("PeakMyGuessPopControl",LikeOO.OOControlBase)

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
        local play_data, play_data2 = self.m_model:getGuessBattlePlayerData()
        self:openView("PeakArena.GuessPop",{ data = play_data})
    elseif msg == "guess_right_btn" then    
        local play_data, play_data2 = self.m_model:getGuessBattlePlayerData()
        self:openView("PeakArena.GuessPop",{ data = play_data2})
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
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchNode(index)
    end
end

return M
