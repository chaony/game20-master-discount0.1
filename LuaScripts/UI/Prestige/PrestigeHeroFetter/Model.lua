local M = class("PrestigeHeroFetterPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_xiake_data = {}
	self.m_current_data = {}
	self.m_curent_index = self.m_params and self.m_params.index or 1
	self.m_block_data = PrestigeUtil:getHeroOnBoard() or {}
	self:InitData()
end

function M:InitData()
	self.m_xiake_data = {}
	local cfgdata = ConfigManager:getCfgByName("prestige_checkerboard_fetter")
	local data1 = {}
	local data2 = {}
	local data3 = {}
	local data4 = {}
	local data5 = {}
	local data6 = {}
	local data7 = {}
	for k,v in ipairs(cfgdata) do
		if v.checkerboard == 1 then
			table.insert(data1,v)
		elseif v.checkerboard == 2 then
			table.insert(data2,v)
		elseif v.checkerboard == 3 then
			table.insert(data3,v)
		elseif v.checkerboard == 4 then
			table.insert(data4,v)
		elseif v.checkerboard == 5 then
			table.insert(data5,v)
		elseif v.checkerboard == 6 then
			table.insert(data6,v)
		elseif v.checkerboard == 7 then
			table.insert(data7,v)
		end
    end
	self.m_xiake_data[1] = data1
	self.m_xiake_data[2] = data2
	self.m_xiake_data[3] = data3
	self.m_xiake_data[4] = data4
	self.m_xiake_data[5] = data5
	self.m_xiake_data[6] = data6
	self.m_xiake_data[7] = data7
	local player_data = ConfigManager:getCfgByName("player_picture")
	if self.m_xiake_data then 
		local currentData = self.m_xiake_data[self.m_curent_index]
		for k,v in ipairs(currentData) do 
			local data = {}
			data.name = v.name
			data.id = v.id 
			data.des = v.des  --无
			data.effect_des1 = v.effect_des1  --3 
			data.effect_des2 = v.effect_des2  --5
			data.itemNdoeList = {}
			for m,n in ipairs(v.hero_fetter) do
				local data_ = {}
				data_.player_data = player_data[n]
				local cell_data = {}
				data_.hero_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, tonumber(n), 1})
				data_.status = self:isHaveHeroId(self.m_curent_index,tonumber(n))
				data.itemNdoeList[m] = data_
			end
			--data.all_status = 1  -- 0  未激活 1 激活  --一条激活
			--data.statusNum = 5  -- 1 3 5 激活个数
			data.statusNum,data.all_status = self:GetCurrentNumAndStatus(v.hero_fetter)
			if data.statusNum <3 then
				data.real_des = data.des
			elseif data.statusNum >=3 and data.statusNum < 5 then
				data.real_des = data.effect_des1
			elseif data.statusNum >=5 then
				data.real_des = data.effect_des2 
			else
				data.real_des = data.des
			end
			table.insert(self.m_current_data,data)
		end
	end
	--local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero.id, 0})
end

--判断单个侠客是否有
function M:isHaveHeroId(current_index,hero_id)
	local status = 0
	local data = self.m_block_data[current_index]
	for k,v in pairs(data) do
		if tonumber(k) == hero_id then
			status = 1
		end
	end
    return status
end

--判断整条 数量和 状态
function M:GetCurrentNumAndStatus(all_data)
	local num = 0
	local all_num = #all_data or 5
	local data = self.m_block_data[self.m_curent_index]
	for k,v in ipairs(all_data) do
		for m,n in pairs(data) do
			if tonumber(m) == v then
				num = num + 1
			end
		end
	end
	local status = num == 0 and 0 or 1
	return num,status
end

function M:getXiaKeData()
	return self.m_current_data or {}
end

return M
