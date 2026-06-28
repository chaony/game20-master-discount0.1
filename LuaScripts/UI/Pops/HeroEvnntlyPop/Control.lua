local M = class("HeroEvnntlyPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
        self:closeView()
	elseif msg == "cancle_btn" then
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
		self:closeView()
	elseif msg == "open_btn" then
		self.m_view:opneCount()
	elseif msg == "last_btn" then
		self.m_view:closeCount()
	elseif msg == "get_reward_btn" then
		self:getKillReward()
	end
end

--领取奖励
function M:getKillReward()
    local function callfunc(response)
		RewardUtil:rewardTipsByData(response.reward)
		UserDataManager.hero_data:updateOneHeroCollect(self.m_model.herocfg.id)
		self:updateMsg("update_equip", nil, "HeroInfo")
		self.m_view:hideReward()
	end
    local data = {
        hero_id = self.m_model.hero_id
    }
    self.m_model:getNetData("hero_collect_receive", data, callfunc)
end


return M;
