local M = class("JuBaoShanSendPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData()
end

function M:onEnter()
	--建筑格子
	self.buildingData = self.m_params.cells;
	--
	self.lv_gifts = self.m_params.lv_gifts;
	--圈数
	self.cycle = self.m_params.cycle;
	local cycleReward_config = ConfigManager:getCommonValueById(451);
	local len = #cycleReward_config;
	if self.cycle >= len then
		self.cycleReward = cycleReward_config[len];
	else
		self.cycleReward = cycleReward_config[self.cycle+1];
	end
end

--获取圈数奖励
function M:getCycleReward()
	return self.cycleReward;
end


function M:getBuildingData()
	return self.buildingData;
end


function M:updateRewardData( cell_data)
	local m_reward = self:getRewardData(cell_data);
	return m_reward;
end


function M:getRewardData( cell_data )
	local building = self.lv_gifts[tostring(cell_data.id)]
	local reward = nil;
	if building ~= nil then
		reward = building[tostring(cell_data.lv)]
	end
	return reward;
end

return M
