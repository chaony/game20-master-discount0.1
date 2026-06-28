local M = class("ServiceGoodFeelPopControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 or msg == "CloseBtn" then    -- 返回
		self:updateMsg("updateUI", nil, "Xian")
		self:closeView()
	elseif msg == "Sliding_right" then
		if self.m_model.select_index < self.m_model.m_max_vip then
			self.m_model.select_index = self.m_model.select_index + 1
			local vip_tab = ConfigManager:getCfgByName("vip")
			if table.nums(vip_tab) <= self.m_model.select_index then
				self.m_model.select_index = table.nums(vip_tab) - 1
			end
			self.m_view:refreshUI()
		end
	elseif msg == "Sliding_left" then
		self.m_model.select_index = self.m_model.select_index - 1
		if self.m_model.select_index < 0 then
			self.m_model.select_index = 0
		end
		self.m_view:refreshUI()
	elseif msg == "left_btn" then	
		self:updateMsg("Sliding_left")
	elseif msg == "right_btn" then	
		self:updateMsg("Sliding_right")
	elseif msg == "get_reward" then
		local function readCallback(response)
			if response then
				if next(response.reward) then
					RewardUtil:rewardTipsByData(response.reward)
				end
				self.m_model:autoSelectIndex()
				self.m_view:refreshUI()
			end
		end
		local params = {}
		params.lv = self.m_model.select_index
		self.m_model:getNetData("recv_vip_reward", params, readCallback)
	elseif msg == "hint_btn" then
        self:openView("Pops.CommonHelpPop", {title = "hero_ui_str_0050", content = "tid#Vip_1"})
	end
end


return M