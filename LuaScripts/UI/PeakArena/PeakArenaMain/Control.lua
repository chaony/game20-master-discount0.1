local M = class("PeakArenaMainControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()
    end)
    self:checkBattleResult(handler(self,self.checkTopWinner))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("update_top_rank", self.m_model.m_data.cur_rank,"LingCloud")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "refreshRedPoint" then    
        self.m_view:refreshUI()
    elseif msg == "peak_game_btn" then --进入
        if self.m_model:checkHasData() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0062"), delay_close = 2})
            return
        end
        if self.m_model:checWeekBl() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
            return
        end
        if self.m_model:checkOpenType() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
            return
        end
        if self.m_model:checkCanClick() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0008"), delay_close = 2})
            return
        end
        if next(self.m_model.m_data) ~= nil then
            self:openView("PeakArena.PeakArenaFight", self.m_model.m_data)
        end
    elseif msg == "set_battle_array_btn" then --布阵
        if self.m_model:checkTeamLock() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0007"), delay_close = 2})
            return 
        end
        self:openView("Arena.ArenaHigher.ArenaHigherDefendTeam", {top_arena = true})
    elseif msg == "hint_btn" then 
        local params = {}
        params.title = Language:getTextByKey("peak_str_0006")
        params.content = Language:getTextByKey("tid#Top_Arena_001")
        self:openView("Pops.CommonHelpPop", params) 
    elseif msg == "zan_btn_1" then
        self:sendZanBtn(1)
    elseif msg == "zan_btn_2" then
        self:sendZanBtn(2)
    elseif msg == "zan_btn_3" then
        self:sendZanBtn(3)
    elseif msg == "refreshUI" then
        self.m_view:refreshUI() 
    elseif msg == "shop_btn" then    
        self:openView("Shop", {shop_type = 6}) 
    elseif msg == "reward_btn" then
        if self.m_model:checkHasData() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0062"), delay_close = 2})
            return
        end
        if self.m_model:checWeekBl() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
            return
        end
        if self.m_model:checkOpenType() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
            return
        end
        if self.m_model:checkCanClick() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0008"), delay_close = 2})
            return
        end 
        self:openView("PeakArena.PeakArenaRankListPop", {open_type = self.m_model:checkOpenType()})
    elseif msg == "guess_btn" then   
        if self.m_model:checkHasData() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0062"), delay_close = 2})
            return
        end
        if self.m_model:checWeekBl() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
            return
        end
        if self.m_model:checkOpenType() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
            return
        end
        if self.m_model:checkCanClick() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0008"), delay_close = 2})
            return
        end 
        UserDataManager:removeRedDotByKey("top_arena_guess")
        self.m_view:refreshRedPoint()
        self:openView("PeakArena.PeakMyGuessPop", {top_data = self.m_model.m_data})
    elseif msg == "updateGress" then
        self.m_view:refreshUI()
    end
end

function M:sendZanBtn(index)
    local function netCallback(response)
        if response.reward then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model.m_data.like_data = response.like_data
            self.m_model:updateLikeNumByIndex(index,response.like)
            self.m_view:refreshUI() 
        end
    end
    local target_uid = self.m_model:getTopPlayerByIndex(index)
    if self.m_model:checkLickData(target_uid) == true then 
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0059"), delay_close = 2})
        return 
    end
    local params = {
        target_uid = self.m_model:getTopPlayerByIndex(index),
    }
    self.m_model:getNetData("top_arena_like", params, netCallback)
end

--检测战斗结果
function M:checkBattleResult(callback)
    local top_arena_data = UserDataManager.local_data:getUserDataByKey("top_arena_result", {})
    if self.m_model:checkCanClick() == true and top_arena_data and next(top_arena_data) ~= nil and top_arena_data.season == self.m_model.m_data.season then
        if top_arena_data.step == 6 and top_arena_data.win == 1 then
            callback()
        else
            self:openView("PeakArena.PromotedPop", {cb = callback, top_arena_data = top_arena_data}) 
            UserDataManager.local_data:setUserDataByKey("top_arena_result", {})
        end
    else
        callback()
    end 
end

--检测前三展示
function M:checkTopWinner()
    if self.m_model:checkTopArenaFinal() == true then
        self:openView("PeakArena.PeakArenaResultPop", self.m_model.m_data, function ()
            self:checkGuessTips()
        end)
        UserDataManager.local_data:setUserDataByKey("top_arena_final", {})
    else
        self:checkGuessTips()
    end
end

function M:checkGuessTips()
    if self.m_model:getGuessAlert() > 0 then
        local team_id = self.m_model:getGuessAlert()
        self:openView("PeakArena.GuessTipsPop", {team_id = team_id })
    end
end

return M
