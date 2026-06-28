local M = class("ServiceJiangHuPopControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
	elseif msg == "box_Btn" then --宝箱领取
		local click_obj= self.m_view:findGameObject("box_Img_di")
		local progress = self.m_model.serverOpenTime/self.m_model.current_data.cfg.unlock
		if progress >= 1 then --可领取
			if self.m_model:hasReward(self.m_model.current_data.cfg.stage_id) then --已领取
				local rewards = self.m_model.current_data.cfg.reward or {}
				self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = click_obj.transform, show_check_mark = true})
			else --未领取
				self:receiveReward()
			end
		else
			local rewards = self.m_model.current_data.cfg.reward or {}
			self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = click_obj.transform, show_check_mark = false})
		end
	elseif msg == "hero_info" then --英雄信息
		if data.cell_data.user ~= nil then
			self:openView("Pops.PlayerInfo", {uid = data.cell_data.user.uid, look_model = 1})
		else
			GameUtil:lookInfoTips(self, {msg = "new_str_0838", delay_close = 2})
		end
	end
end

--领取奖励
function M:receiveReward(data)
	local function netCallback(response)
		if self.m_view then
			RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
			self.m_model:updateServerData(response)
			self.m_view:refreshUI()
			self:updateMsg("refresh", { server_level_rcvd = response.server_level_rcvd },"Xian.ServiceWorldProgress")
		end
	end
	local params = {
		stage_id = self.m_model.current_data.stage_id
	}
	self.m_model:getNetData("stage_server_level_receive", params,netCallback)
end

return M