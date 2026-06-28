local M = class("CustomMadePopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self:getData()
end

function M:onEnter()
	self.m_gift_id = self.m_params.id or 1
	self.m_gift_version = self.m_params.version
	self.m_select_index = self.m_params.index or 1
	self.m_cont_data = self.m_params.cont_data or {}
	self.m_slot = self.m_params.slot or {}
	self:initSlot()
	self.reiginal_slot = table.copy(self.m_slot)
end

function M:initSlot()
	local cust_tab = ConfigManager:getCfgByName("custom_gift")
	local cust_data = cust_tab[self.m_gift_version][self.m_gift_id]
	for i=2, #cust_data.reward do
		local pos = self:getContRewardByIndex(i)
		self.m_slot[i-1] = pos or 0
	end
end

function M:getContRewardByIndex(index)
	local tab = self.m_cont_data[tostring(self.m_gift_version)] or {}
	local gift_rewards = tab[tostring(self.m_gift_id)]
	if gift_rewards == nil then
		return 0
	end
	return gift_rewards.pos_lst[index-1]
end


function M:checkCanSave()
	for k,v in pairs(self.m_slot) do
		if v == 0 then
			return false
		end
	end
	for k,v in pairs(self.m_slot) do
		if v ~= self.reiginal_slot[k] then
			return true
		end
	end
	return false
end

function M:checkFull()
	for k,v in pairs(self.m_slot) do
		if v == 0 then
			return false
		end
	end
	return true
end

function M:setNextPos()
	local positions = self:getSlot()
	if self.m_select_index < #positions then
		self.m_select_index = self.m_select_index +1
	else
		for i = 1, #self.m_slot do
			if self.m_slot[i] == 0 then
				self.m_select_index = i
				return
			end
		end
	end
end

function M:getTitleName()
	local cust_tab = ConfigManager:getCfgByName("custom_gift")
	local cust_data = cust_tab[self.m_gift_version][self.m_gift_id]
	return cust_data.gift_name
end

function M:setSoltReward(pos)
	self.m_slot[self.m_select_index] = pos
end

function M:getItemBySolt(index)
	return self.m_slot[index]
end

function M:getItemData(data)
	return RewardUtil:getProcessRewardData(data)	
end

function M:getSlot()
	return self.m_slot
end

function M:function_name( )
	
end

function M:getCurRewardItems()
	local cust_tab = ConfigManager:getCfgByName("custom_gift")
	local cust_data = cust_tab[self.m_gift_version][self.m_gift_id]
	if cust_data then
		return cust_data.reward[self.m_select_index+1] or {}
	end
	return {}
end

function M:getCurRewardByIndex(index, pos)
	local cust_tab = ConfigManager:getCfgByName("custom_gift")
	local cust_data = cust_tab[self.m_gift_version][self.m_gift_id]
	local rewards = cust_data.reward[index+1]
	return rewards[pos]
end



return M