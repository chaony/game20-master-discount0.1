local M = class("PromotionEventPopModel", LikeOO.OODataBase)

local _Rank_Range = {
	[-2] = {-3 , -2},
	[-1] = {-1 , -1},
	[1] = {1 , 1},
	[2] = {2 , 3},
	[4] = {4 , 7},
	[8] ={8 , 15},
	[16] = {16 , 31},
	[32] = {32 , 63},

	[99] = {1 , 63},
}

function M:onCreate()
	M.super.onCreate(self)
	self.raceType = self.m_params.raceType --1天赛 ， 2 地赛
	self.m_version = self.m_params.version or 1
	self.m_active_day = self.m_params.active_day or 33
	self:getData("full_service_top_chart", {typ = self.raceType})
end

function M:onEnter()
	--local cfg = ConfigManager:getCfgByName("") --获取配置表数据
	local netData = self.m_data  --获取服务器数据
	local m_params = self.m_params --获取参数
	self.m_player_data = self.m_data.players

end

function M:checkPromotionDataByIndex(index)
	if index then
		local father_pos = 0
		if index < 0 then
			father_pos = math.ceil(index/2)
		else
			father_pos = math.floor(index/2)
		end
		return self.m_data.players[tostring(father_pos)]
	else
		return nil
	end
end

function M:updateData( response )
	table.merge(self.m_data , response)
	self:initData()
end

function M:getRankRange(range_idx)
	local result = {}
	if not range_idx or not _Rank_Range[range_idx] then return result end
	if self.m_data.players then
		for i = _Rank_Range[range_idx][1], _Rank_Range[range_idx][2] do
			local player = self.m_data.players[tostring(i)]
			if player then
				table.insert(result , {rank = i , player = player})
			else 
				table.insert(result , {rank = i , player = nil})
			end
		end
	end
	return result
end

function M:destroy()

	M.super.destroy(self)
end

return M