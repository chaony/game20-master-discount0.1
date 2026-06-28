local M = class("LuckyRabbitHutTimesPopControl", LikeOO.OOControlBase)

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
	elseif msg == "ok_btn" then
		if self.m_model:getMaxItemNum() <= 0 then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("lucky_rabbit_hut_main_014"), delay_close = 2})
			return
		end
		if self.m_model.m_click_buy ~= nil then
			self.m_model.m_click_buy(self.m_model.m_cur_num)
		end
		self:closeView()
		return
	elseif msg == "add_btn" then
		self:changeCurNum(1)
	elseif msg == "reduce_btn" then
		self:changeCurNum(-1)
	elseif msg == "max_btn" then
		self:changeCurNum(10)
	elseif msg == "min_btn" then
		self:changeCurNum(-10)
	end
	self.m_view:refreshUI()
end

function M:changeCurNum(num)
	local result = 1
	local cur_num = self.m_model.m_cur_num
	local max_num = self.m_model:getMaxItemNum()
	if cur_num + num >= max_num then
		result = max_num
	elseif cur_num + num <= 1 then
		result = 1
	else
		result = cur_num + num
	end
	self.m_model.m_cur_num = result
end

return M;
