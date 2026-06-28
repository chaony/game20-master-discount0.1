local M = class("ArenaNormalTicketBuyControl",LikeOO.OOControlBase)

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
        self:updateMsg("update_data", {data = response}, "Arena.ArenaHigher.ArenaHigher")
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {count = num}
    if self.m_model.m_buy_mode == 0 then
        self.m_model:getNetData("arena_buy_arena_ticket", params, netCallback)
    elseif self.m_model.m_buy_mode == 1 then
        self.m_model:getNetData("high_arena_buy_arena_ticket", params, netCallback)
    end
end


return M
