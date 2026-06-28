local M = class("GuJianQiTanDateView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanDate"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("common_title_text", "gu_jian_qi_tan_str_006")
    self:refreshUI()
end

function M:refreshUI()
    local data = self.m_model:getDateData()
    self:setText("title_text", data.title)
    self:setText("content_text", data.content)
    self:setText("reward_text", data.reward)
    self:setText("day_text", data.time_left)
end

return M