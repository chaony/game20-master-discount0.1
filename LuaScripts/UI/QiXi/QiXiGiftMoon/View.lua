local M = class("QiXiGiftMoonView",LikeOO.OOPopBase)

M.m_uiName = "QiXi/QiXiGiftMoon"
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
	self.avtive_data = self.m_model:getActiveData()
	self.receive_btn = self:findImage("receive_btn")
	self.gray_img = self:findImage("hui")
	self:setTextByLanKey("Intimacy_title_text", "qi_xi_101")
	self:setTextByLanKey("my_record_text", "qi_xi_102")
	self:setTextByLanKey("tips_text_1", "qi_xi_104")
	self:setTextByLanKey("tips_text_2", "qi_xi_103")
	self:setTextByLanKey("notreached_text", "qi_xi_017")
	self:setTextByLanKey("shoping_text", "qi_xi_105")
	self:setTextByLanKey("tips_text_3", "qi_xi_108",self.m_model:getPeopleIntegra())
	self:setTextByLanKey("close_title_text", self.avtive_data.name)
	self:refreshUI()
end

function M:refreshUI()
	self:setTextByLanKey("current_Intimacy_text", "qi_xi_106",self.m_model.m_data.score)
	local Intimacy_text = self.m_model.m_data.cur_integra.."/"..self.m_model:getIntegra()
	self:setTextByLanKey("Intimacy_text", Intimacy_text)
	self:refreshReward()
	self:refreshIntimacy()
	self:refreshReceiveBtn()
end

--刷新奖励
function M:refreshReward()
	--奖励
	local reward = self.m_model:getReward() or {}
	local reward_node = self:findGameObject("reward_Content")
	local function callBack()
		audio:SendEvtUI("UI_TJL_Gold")
	end
	GameUtil:createRewards(reward_node.transform, reward, true, true, callBack, 1)
end

--刷新亲密度
function M:refreshIntimacy()
	--个人亲密度是否满足条件 true满足
	local perpleIntimacy = self.m_model.m_data.score >= self.m_model:getPeopleIntegra()
	--全服亲密度是否满足条件 true满足
	local intimacy = self.m_model.m_data.cur_integra >= self.m_model:getIntegra()
	local receive_isShow = perpleIntimacy and intimacy
	self:setObjectVisible("notreached_img",not receive_isShow) --未达成
	self:setObjectVisible("receive_btn",receive_isShow) --领取
	--月亮
	self:setObjectVisible("moon_1",not intimacy) --半月
	self:setObjectVisible("moon_2",intimacy) --满月
end

--刷新领取按钮显示
function M:refreshReceiveBtn()
	if self.m_model:getIsReceive() == 0 then
		self:setTextByLanKey("receive_text", "qi_xi_016")
		self.receive_btn.material = nil
	else
		self:setTextByLanKey("receive_text", "new_str_0058")
		self.receive_btn.material = self.gray_img.material
	end
end

--倒计时
function M:updateActivityTimer()
	local time_left = self.m_model:getTimeLeft()
	if time_left > 0 then
		self:setTextByLanKey("time_text", Language:getTextByKey("qi_xi_026") .. GameUtil:formatTimeBySecond(time_left))
	else
		self:updateMsg(99999)
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M