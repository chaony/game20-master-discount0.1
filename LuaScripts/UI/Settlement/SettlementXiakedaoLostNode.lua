---@class SettlementXiakedaoLostNode:OOUIbase
local M=class("SettlementXiakedaoLostNode",LikeOO.OOUIbase)

M.m_uiName="Settlement/SettlementXiakedaoLostNode"

function M:onEnter()
    self:setTextByLanKey("loser_text", "loser_tex")
    self:setTextByLanKey("qianwang_1_text", "new_str_0970")
    self:setTextByLanKey("adjust_btn_text", "new_str_0258")
    self:setTextByLanKey("losenumtip_text","new_str_1122")
    local lose_num=self.m_model.m_data.lose_num
    if lose_num<0 then
        lose_num=0
    end
    self:setTextByLanKey("losenum_text","new_str_0568",lose_num)
end

return M