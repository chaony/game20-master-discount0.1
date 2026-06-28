---@class PetEvolveLvUpPopModel: OODataBase
local M = class("PetEvolveLvUpPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_on_ok_call = self.m_params.on_ok_call
	self.m_on_cancel_call = self.m_params.on_cancel_call
	self.m_no_tips = true
	self.m_isOk = false
end

function M:changeTipsState()
	if self.m_no_tips then
		self.m_no_tips = false
	else
		self.m_no_tips = true
	end
end

function M:getLevelUpNeedMoney()
	return self.m_params.need_coin, self.m_params.need_exp
end

function M:updateResourceData()
	self.data_exp = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.PET_EXP, 0, 0})
	self.data_coin = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0})
end

function M:destroy()
	if self.m_no_tips and self.m_isOk then
		local curTime = UserDataManager:getServerTime()
		local cur_day = TimeUtil.gmTime(curTime).yday
		UserDataManager.local_data:setUserDataByKey("PetEvolveLvUpTips", cur_day)
	end
	
end

return M
