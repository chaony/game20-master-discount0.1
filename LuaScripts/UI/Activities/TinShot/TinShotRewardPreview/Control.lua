local M = class("TinShotRewardPreviewControl", LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
    elseif msg == "get_reward_btn" then
        self:getOnTimeReward()
    elseif msg == "ok_btn" then
        self:setBigPrize()
    elseif msg == "cancle_btn" then
        self:updateMsg(99999)
    end
end

--在线奖励
function M:setBigPrize()
    local function receivetCallback(response)
        self:updateMsg("updateBigPrize", response.big_pos, "GiftBag")
        self:updateMsg(99999)
    end
    local params = {index = self.m_model.m_select_big_pop}
    self.m_model:getNetData("scroll_set_big_prize", params, receivetCallback)
end






return M
