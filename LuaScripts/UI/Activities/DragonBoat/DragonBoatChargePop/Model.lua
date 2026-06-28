local M = class("DragonBoatChargePopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	--Logger.logError(self.m_data,"data~~~~~~~~~~~~~~")
	self.version = self.m_params.version or 1
	self.title_name = self.m_params.title_name or "new_str_0794"
	self.milepost_reward = self.m_params.milepost_reward or {}
	self.total_cook_times = self.m_params.total_cook_times or 0
end





--数据获取
function M:get_recharge_cfg()
	local meituan_dumpling_stage = ConfigManager:getCfgByName("meituan_dumpling_stage")
	local server_tab = meituan_dumpling_stage[self.version]
	local new_tab = {}
	for k,v in pairs(server_tab) do
		local cfg = server_tab[tonumber(k)]
		cfg.id = tonumber(k)
		table.insert(new_tab, cfg)
	end
	local function sortFunc(id_one, id_two)
		--已领
		local data_one = self:checkReceived(id_one.id) == true and 1 or 0 
		local data_two = self:checkReceived(id_two.id) == true and 1 or 0
		if data_one == data_two then
			if id_one.amount == id_two.amount then 
				return id_one.id < id_two.id
			else
				return id_one.amount < id_two.amount
			end
		else
			return data_one < data_two
		end
	end
	table.sort(new_tab, sortFunc)
	return new_tab
end



--是否已领取
function M:checkReceived(id)
	for kk,vv in pairs(self.milepost_reward) do
		if id == vv then
			return true
		end
	end
	return false
end

--是否可领取
function M:getCmltReceived(id)
	if self.milepost_reward then
		for k,v in pairs(self.milepost_reward) do
			if id == v then
				return true
			end
		end
		return false
	end
	return false
end

return M