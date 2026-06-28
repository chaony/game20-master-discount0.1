local M = class("RunGainNode",LikeOO.OOUIbase)

M.m_uiName = "Hotel/HotelMall/RunGainNode"
M.m_iphoneXAdapter = true

function M:onCreate()

end

function M:onEnter()
    --self:setTextByLanKey("close_title_text", "hotel_text_001")
    --self:setTextByLanKey("close_title_text", self.m_model.m_title_name)
    --self:setTextByLanKey("hint_text", "lakes_love_text_003")
    --self:setTextByLanKey("confirm_btn_text", "new_str_0006")
    --self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 8})
	--self:refreshUI()
end

function M:refreshUI()

end

function M:destroy()
    M.super.destroy(self)
end

return M