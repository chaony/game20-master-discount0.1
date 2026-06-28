local M = class("PlayerBackMainView",LikeOO.OOPopBase)

M.m_uiName = "PlayerBack/PlayerBackMain"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	self:setTextByLanKey("word_old_text","player_back_old_text")
	self:setText("word_new_text", Language:getTextByKey("new_str_1071", GameUtil:formatValueToString(self.m_model:getYuanBaoCount()), tostring(self.m_model:getHaoGanDu()) .. "%"))
end

return M