local M = class("ToKensEntrancPopControl", LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
    elseif msg == "topup_btn" then --充值
        self:updateMsg("jump_topup", -1 , "parent")
    elseif msg == "actives_btn" then --活动
        self:updateMsg("goto_recharge", -1 , "parent")
    elseif msg == "other_btn" then --其他
        self:openView("TopUpGiftBag.ToKensSelectGiftBagPop", {common_data = self.m_model.m_common_data})
    elseif msg == "refresh_data" then --刷新
        self.m_view:refreshUI()
    elseif msg == "choice_gift_btn" then
        local push_gifts = self.m_model:checkChoiceGifts()
        self:openView("GiftBag.ChoiceChargePop", {push_gift = push_gifts, is_token = true})
    end
end

return M
