local M = class("PeakArenaGameControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()
        self.m_view:updateTime()
    end)
    if self.m_model:getGuessAlert() then
        local team_id = self.m_model:getGuessAlert() 
        self:openView("PeakArena.GuessTipsPop", {top_data = self.m_model.m_top_data, team_id = team_id })
    end
end

function M:onHandle(msg , data)
    if self.m_model:checkCanClick() == false then
        self:checkIsClose()
        return
    end
    if msg == 99999 then    -- 返回
        self:updateMsg("refreshUI", nil, "PeakArena.PeakArenaMain")
        self:closeView()
    elseif msg == "my_game_btn" or msg == "guess_btn" or msg == "racn64_btn" or msg == "racn8_btn"  then   
        self.m_view:selectTab(msg)
    elseif msg == "refreshRedPoint" then    
        self.m_view:refreshUI()
    elseif msg == "hint_btn" then 
        local params = {}
        params.title = "gf_str_0078"
        params.content = Language:getTextByKey("gf_str_0078")
        self:openView("Pops.CommonHelpPop", params) 
    elseif msg == "shop_btn" then    
        self:openView("Shop", {shop_type = 13}) 
    elseif msg == "rank_btn" then    
        self:openView("PeakArena.PeakArenaRankListPop")
    elseif msg == "my_guess_btn" then    
        self:openView("PeakArena.PeakMyGuessPop", {top_data = self.m_model.m_top_data})
    elseif msg == "quarter_reward_btn" then
        self:openView("PeakArena.PeakRankRewardPop")
    elseif msg == "talk_btn" then
        self:openView("Chat2")   
    elseif msg == "updateGress" then
        self.m_model.m_top_data.guess_data = data.guess_data or {}
        self.m_model.m_top_data.quiz_count = data.quiz_count or {}
        self.m_view:refreshUI()
    elseif msg == "refresh_ui" then    
        self.m_view:refreshUI()
    elseif msg == "look_hero" then
        self:openView("HeroBag", {player_data = {heros = data.data} , mode = 3, oid = data.oid})
    end
end

function M:checkIsClose()
    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0008"), delay_close = 2})
    self:closeView()
    return
end

return M
