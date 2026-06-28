local M = class("RacconFinalPopView",LikeOO.OOPopBase)

M.m_uiName = "Raccon/RacconFinalPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0732")
	--"a_xhx_bklq_btn" a_xhx_klq_btn a_xhx_ylj_btn
	self:setImg(self.m_model:getBtnImg(), "language_zh_cn", "get_btn")
	RedPointUtil:saveLocalRedPointFreshTime("voyage_bag_once")
end

function M:updateActivityTimer()
	local end_ts = self.m_model:getEndTs()
	if end_ts >= 0 then
		local text = GameUtil:formatTimeBySecond(end_ts, 999)
		--text = Language:getTextByKey("new_str_0919") .. text
		self:setTextByLanKey("time_down_text", text)
	else
		self:updateMsg(99999)
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M