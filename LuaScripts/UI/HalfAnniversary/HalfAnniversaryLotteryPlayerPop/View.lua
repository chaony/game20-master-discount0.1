---@class HalfAnniversaryLotteryPlayerPopView: OOPopBase
---@field m_model HalfAnniversaryLotteryPlayerPopModel
local M = class("HalfAnniversaryLotteryPlayerPopView", LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversaryLotteryPlayerPop"
M.m_size_type = 2

function M:onEnter()
    self:bindUI()
    self:refreshSlider()
end


function M:bindUI()
    self:setTextByLanKey("close_title_text", "half_year_text_0004")
    self:setTextByLanKey("desc_text", "half_year_text_0018")
    self:setTextByLanKey("level_text1", "half_year_text_0011")
    self:setTextByLanKey("level_text2", "half_year_text_0012")
    self:setTextByLanKey("level_text3", "half_year_text_0013")
    self:setTextByLanKey("level_text4", "half_year_text_0014")
    self:setTextByLanKey("text_timer_title", "half_year_text_0015")
    self:setTextByLanKey("lucky_text", "half_year_text_0016")
    self:setTextByLanKey("lotteryBtn_text", "half_year_text_0017")
    --self:setTextByLanKey("resultBtn_text", "half_year_text_0013")
end







function M:destroy()
    M.super.destroy(self)
end


return M