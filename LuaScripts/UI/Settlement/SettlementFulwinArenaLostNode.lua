--- 风云擂台 失败

local M = class("SettlementFulwinArenaLostNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementFulwinArenaLostNode"

function M:onEnter()
    self:setTextByLanKey("loser_title_text", "new_str_0254")
    self:setTextByLanKey("adjust_btn_text", "new_str_0258")
    self:setTextByLanKey("intensify_btn_text", "new_str_0257")
    self:setTextByLanKey("no_open_btn_text", "new_str_0259")
    self:setTextByLanKey("open_lv_text", "new_str_0260", 99)
end

function M:refreshUI()

end

function M:playAnim()
    if self.m_luaBehaviour then
        self.m_luaBehaviour:RunAnim("SettlementChapterLostNode_show",nil, 1)
    end
end

function M:updateButtonVisible(flag)
    self:setTextByLanKey("loser_title_text", "new_str_0466")
    self:setObjectVisible("lost_ok_btn", flag)
    self:setObjectVisible("intensify_btn", flag)
    self:setObjectVisible("adjust_btn", flag)
    self:setObjectVisible("ok_text", flag)
    self:setObjectVisible("adjust_btn_text", flag)
    self:setObjectVisible("intensify_btn_text", flag)
end

return M