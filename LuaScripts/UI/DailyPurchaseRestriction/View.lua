local M = class("DailyPurchaseRestrictionView",LikeOO.OOPopBase)

M.m_uiName = "DailyPurchaseRestriction/DailyPurchaseRestriction"
M.m_size_type = 2

function M:onEnter()
	--self:setTextByLanKey("Title", "daily_purchase_restriction_text1")
    --self:setTextByLanKey("Desc", "daily_purchase_restriction_text2")
	self.content = self:findGameObject("RewardContent").transform
    self:refreshUI()
end

function M:refreshUI()
    local cfg = self.m_model:getGiftCfg()
    self:setTextByLanKey("PriceTxt", GameUtil:getMoneyTypeNum(cfg.price))
    self:setTextByLanKey("TitleTxt", self.m_model:getViewName())
    
    GameUtil:createRewards(self.content, cfg.reward, true, true, nil)
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs() - UserDataManager:getServerTime()
    if end_ts >= 0 then
        local text = GameUtil:formatTimeBySecond(end_ts, 999)
        self:setText("LessTimeStrTxt", text .. Language:getTextByKey("daily_purchase_restriction_text3"))
    else
        self:updateMsg(99999)
    end
end


return M