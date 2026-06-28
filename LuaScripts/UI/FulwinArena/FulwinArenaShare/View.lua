local M = class("FulwinArenaShareView",LikeOO.OOPopBase)

M.m_uiName = "FulwinArena/FulwinArenaShare"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:refreshUI()
	self:setTextByLanKey("common_title_text", "castingSword_str_0016")
	self:setTextByLanKey("world_chat_text", "fylt_str_0079")
	self:setTextByLanKey("union_chat_text", "fylt_str_0080")
	self:setTextByLanKey("friend_chat_text", "fylt_str_0081")
	self:setTextByLanKey("local_btn_text", "fylt_str_0082")
end

function M:refreshUI()

end

return M