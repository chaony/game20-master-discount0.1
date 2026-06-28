---@class HalfAnniversaryLotteryPopView: OOPopBase
---@field m_model HalfAnniversaryMainModel
local M = class("HalfAnniversaryLotteryPopView", LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversaryLotteryPop"
M.m_size_type = 2

local __TAB_BTN_NODE = {
    {btn_key = "tab1", btn_text = "tag_name_text1", red_img = "red_point1", lan_key = "half_year_text_0033"},
    {btn_key = "tab2", btn_text = "tag_name_text2", red_img = "red_point2", lan_key = "half_year_text_0034"},
    {btn_key = "tab3", btn_text = "tag_name_text3", red_img = "red_point3", lan_key = "half_year_text_0035"},
}

function M:onEnter()
    self:setTextByLanKey("close_title_text", "half_year_text_0004")
    self:setTextByLanKey("title_text", "half_year_text_0028")
    self:setTextByLanKey("no_award_text", "half_year_text_0029")
    self:setTextByLanKey("luckyNum_txt", "half_year_text_0031")
    self:setTextByLanKey("myNum_txt", "half_year_text_0030")
    self:setTextByLanKey("recv_award_btn_text", "half_year_text_0032")
    self:setTextByLanKey("wait_text", "half_year_text_0039")
    self.scroll_content = self:findGameObject("scroll_content")

    for k,v in pairs(__TAB_BTN_NODE) do
        self:setText(v.btn_text, string.cutTextForString(Language:getTextByKey(v.lan_key)))

        local tog_btn = self:findToggle(v.btn_key)
        if k == self.m_model.m_stage then
            tog_btn.isOn = true
        end
        UIUtil.addToggleListener(tog_btn, function(is_on)
            if is_on then
                self:updateMsg("tab_index", k)
            end
        end, nil, self.m_uiName)
        if k > self.m_model.m_last_stage then
            self:setObjectVisible(v.btn_key, false)
        end
    end
    self:refreshUI()
end

function M:refreshUI()
    for k,v in pairs(__TAB_BTN_NODE) do
        if k == self.m_model.m_stage then
            self:setTextColor(v.btn_text, GlobalConfig.COMMON_COLLOR.COMMON_24)
        else
            self:setTextColor(v.btn_text, GlobalConfig.COMMON_COLLOR.COMMON_25)
        end
        local data = self.m_model:getStageData(k)
        self:setObjectVisible(v.red_img, data.lucky_num ~= "" and data.self_number ~= "" and data.reced ~= 1 )
    end
    local data = self.m_model:getStageData(self.m_model.m_stage)
    self:setObjectVisible("recv_award_btn", data.reced ~= 1)
    local self_number = string.split(data.self_number, "|")
    local lucky_num = string.split(data.lucky_num, "|")
    for i=1, 6 do
        if self_number[i] and self_number[i] ~= "" then
            self:setText("my_num" .. i, self_number[i])
        else
            self:setText("my_num" .. i, "?")
        end

        if lucky_num[i] and lucky_num[i] ~= "" then
            self:setText("lucky_num" .. i, lucky_num[i])
        else
            self:setText("lucky_num" .. i, "?")
        end
    end

    if data.lucky_num and data.lucky_num ~= "" then
        self:setObjectVisible("des_text", true)
        self:setObjectVisible("wait_text", false)
        local id, reward = self.m_model:getLotteryReward()
        if data.self_number ~= "" then
            if id == 1 then
                self:setTextByLanKey("des_text", "half_year_text_0038")
                self:setTextByLanKey("award_level_txt", "half_year_text_0011")
                self:setObjectVisible("award_level_txt", true)
                self:setObjectVisible("awardNode", true)
                self:setObjectVisible("noAwardNode", false)
            elseif id == 2 then
                self:setTextByLanKey("des_text", "half_year_text_0038")
                self:setTextByLanKey("award_level_txt", "half_year_text_0012")
                self:setObjectVisible("award_level_txt", true)
                self:setObjectVisible("awardNode", true)
                self:setObjectVisible("noAwardNode", false)
            elseif id == 3 then
                self:setTextByLanKey("des_text", "half_year_text_0038")
                self:setTextByLanKey("award_level_txt", "half_year_text_0013")
                self:setObjectVisible("award_level_txt", true)
                self:setObjectVisible("awardNode", true)
                self:setObjectVisible("noAwardNode", false)
            elseif id == 4 then
                self:setTextByLanKey("des_text", "half_year_text_0038")
                self:setTextByLanKey("award_level_txt", "half_year_text_0014")
                self:setObjectVisible("award_level_txt", true)
                self:setObjectVisible("awardNode", true)
                self:setObjectVisible("noAwardNode", false)
            else
                self:setTextByLanKey("des_text", "half_year_text_0037")
                self:setObjectVisible("award_level_txt", false)
                self:setObjectVisible("awardNode", false)
                self:setObjectVisible("noAwardNode", true)
            end

            UIUtil.destroyAllChild(self.scroll_content.transform)
            for i,v in ipairs(reward or {}) do
                local reward_data = RewardUtil:getProcessRewardData(v)
                GameUtil:createItemElementByData(reward_data, true, true, nil, self.scroll_content.transform)
            end
            self:setObjectVisible("recv_award_btn", data.reced ~= 1)
            self:setObjectVisible("received_img", data.reced == 1)
        else
            self:setTextByLanKey("des_text", "half_year_text_0037")
            self:setObjectVisible("award_level_txt", false)
            self:setObjectVisible("awardNode", false)
            self:setObjectVisible("noAwardNode", true)
            self:setObjectVisible("recv_award_btn", false)
            self:setObjectVisible("received_img", false)
        end
    else
        self:setObjectVisible("wait_text", true)
        self:setObjectVisible("des_text", false)
        self:setObjectVisible("award_level_txt", false)
        self:setObjectVisible("awardNode", false)
        self:setObjectVisible("noAwardNode", false)
        self:setObjectVisible("recv_award_btn", false)
        self:setObjectVisible("received_img", false)
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M