local M = class("HeroGatherPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData("active_hero_gather_index")
end

function M:onEnter()
	Logger.log(UserDataManager.elite_hero_nums,"UserDataManager.elite_hero_nums ====")
end

function M:updateData(data)
	self.m_data= data
end

function M:getStatus(index)
	local hero_gather = ConfigManager:getCfgByName("hero_gather")
	local cfg = hero_gather[index]
	if UserDataManager.elite_hero_nums < cfg.num then
		return 0 -- 未完成
	end

	-- local receive_ts = self:canGetTime()
	-- local server_ts = UserDataManager:getServerTime()
	-- if receive_ts > server_ts then
	-- 	return 3 -- 完成
	-- end

	for i,v in ipairs(self.m_data.hero_gather_received) do
		if v == index then
			return 2 -- 已领取
		end
	end
	return 1 -- 可领取
end

function M:canGetTime()
	local reg_ts = UserDataManager.reg_ts
	local data = ConfigManager:getCommonValueById(901)
	local receive_ts = reg_ts + data*86400
	return receive_ts
end

return M
