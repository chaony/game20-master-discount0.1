local M = class("GuessPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_currency_num = 9999
	self.m_once_max = ConfigManager:getCommonValueById(416) 
	self.m_cur_num = 0
	local cost_data = RewardUtil:getProcessRewardData({135,0,0})
	self.m_cost_num = cost_data.user_num --我身上拥有的货币数量
	self.m_play_data = self.m_params.data
	self.m_pos = self.m_params.pos
end	

function M:subNum()
	if self.m_cur_num <= 1 then
		self.m_cur_num = 1
		return
	end
	self.m_cur_num = self.m_cur_num - 10
end

function M:subMoreNum()
	if self.m_cur_num <= 1 then
		self.m_cur_num = 1
		return
	end
	self.m_cur_num = self.m_cur_num - 100
end

function M:AddNum()
	if self.m_cur_num >= self.m_once_max then
		self.m_cur_num = self.m_once_max
		return
	end
	self.m_cur_num = self.m_cur_num + 10
	if self.m_cur_num > self.m_cost_num then
		self.m_cur_num = self.m_cost_num
	end
end

function M:addMoreNum()
	if self.m_cur_num >= self.m_once_max then
		self.m_cur_num = self.m_once_max
		return
	end
	self.m_cur_num = self.m_cur_num + 100
	if self.m_cur_num > self.m_cost_num then
		self.m_cur_num = self.m_cost_num
	end
end


function M:setNumByValue(data)
	if data >= 1 then
		self.m_cur_num = self.m_once_max
		return
	elseif	data <= 0 then
		self.m_cur_num = 0
		return
	end
	self.m_cur_num = math.floor(data*self.m_once_max) 
end


return M
