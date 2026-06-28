local M = class("FulwinArenaDoorView", LikeOO.OOPopBase)

M.m_uiName = "FulwinArena/FulwinArenaDoor"
M.m_size_type = 2
function M:onEnter()
    self:setTextByLanKey("common_title_text", "fylt_str_0042")
    self:setTextByLanKey("text_moni_title", "fylt_str_0019")
    self:setTextByLanKey("text_geren_title", "fylt_str_0020")
    self:setTextByLanKey("text_jinji_title", "fylt_str_0021")
    self:setTextByLanKey("text_moni_tips1", "fylt_str_0043")
    self:setTextByLanKey("text_moni_tips2", "fylt_str_0044")
    self:setTextByLanKey("text_geren_tips1", "fylt_str_0045")
    self:setTextByLanKey("text_geren_tips2", "fylt_str_0046")
    self:setTextByLanKey("text_jinji_tips1", "fylt_str_0047")
    self:setTextByLanKey("text_jinji_tips2", "fylt_str_0046")

    --local is_open1 = BtnOpenUtil:isBtnOpen(334)
    --if is_open1 then
    --    local btn_geren = self:findImage("btn_geren")
    --    btn_geren.material = nil
    --end
    local is_open2 = BtnOpenUtil:isBtnOpen(335)
    if is_open2 then
        local btn_jinji = self:findImage("btn_jinji")
        btn_jinji.material = nil
    end
end

return M














