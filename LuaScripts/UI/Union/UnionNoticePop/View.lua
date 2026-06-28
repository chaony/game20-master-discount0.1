local M = class("UnionNoticeView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionNoticePop"
M.m_size_type = 2

function M:onEnter()	
	self:setTextByLanKey("cancle_text", "new_str_0007")
	self:setTextByLanKey("ok_text", "new_str_0006")
	self:setTextByLanKey("common_title_text", "union_str_0027")
	self.notice_input = self:findInputField("notice_input")
	self.notice_input.placeholder.text = Language:getTextByKey("union_str_1045")
	local desc = GameUtil:formatInputText(self.m_model.m_guild.desc)
	self.notice_input.text = desc

	self:refreshUI()
end

function M:refreshUI()

end

function M:getText( )
	local text = GameUtil:formatInputText(self.notice_input.text)
	return text
end

return M