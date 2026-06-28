local M = class("PromotedPopView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/PromotedPop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	self:setObjectVisible("win_obj", self.m_model.is_win == true)
	self:setObjectVisible("fail_obj", self.m_model.is_win == false)
	self:setTextByLanKey("tips_text", "new_str_0243")
	self:setTextByLanKey("reward_fail_text", "prom_leiji_text")
	if self.m_model.is_win == true then
		local step_index = self.m_model.step or 1
		local step_name = self.m_model:getStepName(step_index)
		self:setTextByLanKey("promoted_des", Language:getTextByKey("peak_str_0021")..step_name)
		self:setTextByLanKey("promoted_des2", step_name..Language:getTextByKey("peak_str_0022"))
		self:setTextByLanKey("reward_text", "peak_str_0023")
	else
		local step_index = self.m_model.step or 1
		local step_name = self.m_model:getSetpRank(step_index)
		local step_ratio = self.m_model:getSetpRatio()
		self:setTextByLanKey("promoted_des", "peak_str_0024")
		self:setTextByLanKey("promoted_des2", Language:getTextByKey("peak_str_0025")..step_name..","..Language:getTextByKey("peak_str_0026") ..GameUtil:formatNum(step_ratio)..Language:getTextByKey("peak_str_0027"))
		self:setTextByLanKey("reward_text", "peak_str_0028")
	end
	if self.m_model.step == 7 then
		self:setObjectVisible("promoted_des2", false)
	else
		self:setObjectVisible("promoted_des2", true)
	end
	local reward_node = self:findGameObject("reward_node")
	GameUtil:createRewards(reward_node.transform, self.m_model:getReward(), true, true)
end

function M:updateTime()
	if self.m_model.is_win == true then
		local end_tim = self.m_model:getDownTime()
		if end_tim > 0 and end_tim >= UserDataManager:getServerTime() then
			local show_ts = GameUtil:formatTimeBySecond(end_tim - UserDataManager:getServerTime())
			local step_index = self.m_model.step or 1
			self:setTextByLanKey("promoted_des2", Language:getTextByKey("peak_str_0029", show_ts))
		end
	end
end

return M