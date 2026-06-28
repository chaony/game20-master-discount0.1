local M = class("ToKensEntrancPopView", LikeOO.OOPopBase)

M.m_uiName = "TopUpGiftBag/ToKensEntrancPop"
M.m_size_type = 2

--代金券入口
function M:onEnter()
    self:setTextByLanKey("top_up_text", "gf_str_0092")
    self:setTextByLanKey("actives_text", "gf_str_0036")
    self:setTextByLanKey("other_text", "gf_str_0126")
    self:setTextByLanKey("common_title_text", "gf_str_0127")
    self:setTextByLanKey("tokens_text", "gf_str_0128")
    self:setTextByLanKey("choice_gift_text", "gf_str_0140")
	self:refreshUI()
end

function M:refreshUI()
    local tokens_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.VOUCHER,0,0})
    if tokens_data then 
        self:setImg(tokens_data.icon_name, tokens_data.atlas_name, "tokens_icon")
        self:setTextByLanKey("tokens_num", tokens_data.user_num)
    end
    local other_tab = self.m_model.m_common_data--self.m_model:getCommonData()
    if next(other_tab) ~= nil then
        self:setObjectVisible("other_btn", true)
    else
        self:setObjectVisible("other_btn", false)
    end
    local open_flag, tips_str = BtnOpenUtil:isBtnOpen(149)
    self:setObjectVisible("topup_btn", open_flag == true)
    
    local choice_gifts_tab = self.m_model:checkChoiceGifts()
    self:setObjectVisible("choice_gift_btn", table.nums(choice_gifts_tab)  > 0)
end


return M