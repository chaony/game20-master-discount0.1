local M = class("CommonMultipleItemPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_on_ok_call = self.m_params.on_ok_call
	self.m_on_cancel_call = self.m_params.on_cancel_call
	self.m_new_cancel_call = self.m_params.new_cancel_call
	self.m_ok_text = self.m_params.ok_text or Language:getTextByKey("new_str_0006")
	self.m_cancel_text = self.m_params.cancel_text or Language:getTextByKey("new_str_0007")
	self.m_tips = self.m_params.tip_text
	self.m_text = self.m_params.text or ""
	self.m_title = self.m_params.title or Language:getTextByKey("new_str_0005")
	self.m_no_close_btn = self.m_params.no_close_btn
	self.m_tow_close_btn = self.m_params.tow_close_btn
	self.m_costs = self.m_params.cost
	self.m_show_own_flag = self.m_params.show_own_flag
	self.m_consume = self.m_params.consume
	self.istoday = self.m_params.istoday
	self.m_today_text = self.m_params.today_text or Language:getTextByKey("new_str_0910")
	self.m_today_isyes = self.m_params.today_isyes or false
	self.m_on_no_call = self.m_params.on_no_call
	self.isreward = self.m_params.isreward
	self.reward_text = self.m_params.reward_text
	self.reward_isOk = false
	self.m_no_text = self.m_params.no_text or Language:getTextByKey("new_str_0007")
	self.m_is_show_limit = self.m_params.is_show_limit or false
	self.m_is_max = self.m_params.is_max or false
	self.m_cur_times = self.m_params.cur_times or 0
	self.m_max_times = self.m_params.max_times or 0
	self.m_red_ok = self.m_params.red_ok
	self.m_ontbn_light_time = self.m_params.ok_btn_light_time or 0
end


return M
