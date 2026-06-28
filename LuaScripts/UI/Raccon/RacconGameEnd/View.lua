local M = class("RacconGameEndView",LikeOO.OOPopBase)

M.m_uiName = "Raccon/RacconGameEnd"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self:displayResultScore()
    self:displayResultDes()
end

function M:displayResultScore()
    local score = self.m_model:getScore()
    self:setText("score_text", score)
end

function M:displayResultDes()
    local content = self.m_model:getContent()
    local str = string.gsub(Language:getTextByKey(content or "???"), "\\n", "\n")
    self:setText("rank_text", str)
end

return M