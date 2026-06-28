local M = class("ArenaRaceTicketBuyControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
        self:updateMsg(99999)
    elseif msg == "ok_btn" then -- 购买
        self:arenaBuyArenaTicket()
    elseif msg == "minus_one_btn" then
    	self.m_model:addUseNum(-1)
        self.m_view:updateUseNum()
    elseif msg == "add_one_btn" then
    	self.m_model:addUseNum(1)
        self.m_view:updateUseNum()
    end
end

-- 购买竞技场门票 count: 0 门票数量
function M:arenaBuyArenaTicket()
    local num = self.m_model:getNum()
    if num <= 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0277"), delay_close = 2})
        return
    end
    local function netCallback(response)
        self:updateMsg(99999)
        --Logger.logError(response," 购买之后的接口数据 ")
        if self.m_model.m_match_type == 2 then
            self:updateMsg("update_data", {data = response}, "Arena.ArenaFiveRace")
        else
            self:updateMsg("update_data", {data = response}, "Arena.ArenaRace.ArenaRace")
        end
       
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {count = num}
    --race_arena_season_buy_arena_ticket
    if self.m_model.m_match_type == 2 then
        self.m_model:getNetData("race_arena_season_buy_arena_ticket", params, netCallback)
    else
        self.m_model:getNetData("race_arena_buy_arena_ticket", params, netCallback)
    end
end


return M
