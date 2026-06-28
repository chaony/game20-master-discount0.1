local M = class("UnionContributionPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_guild_donate_times = self.m_params.times or 0
	self.m_times = 1
	self.m_select_id = 1
	self.m_max_times = ConfigManager:getVipValueByKey("contribution_times", 1)

	--local contribution_cfg = ConfigManager:getCfgByName("guild_contribution")
	--local ids = {}
	--for k,v in pairs(contribution_cfg) do
	--	ids[#ids + 1] = k
	--end
	--local function sortT(d1,d2)
	--	return d1 < d2
	--end
	--table.sort( ids, sortT )
	--Logger.log(ids)
	--self.m_ids = ids
end

function M:addTimes()
	self.m_times = self.m_times + 1
	Logger.log(self.m_max_times - self.m_guild_donate_times,"self.m_max_times - self.m_guild_donate_times-->")
	if self.m_times + self.m_guild_donate_times > self.m_max_times then
		self.m_times = math.max(self.m_max_times - self.m_guild_donate_times, 1)
	end
end

function M:subTimes()
	self.m_times = self.m_times - 1
	if self.m_times < 1 then
		self.m_times = 1
	end
end

function M:getCost()
	local cost = 0
	local rewards = {}
	local contribution_cfg = ConfigManager:getCfgByName("guild_contribution")
	--for i=self.m_guild_donate_times+1,self.m_guild_donate_times + self.m_times do
	--	for k, v in ipairs(self.m_ids) do
	--		if i <= v then
	--			local cfg = contribution_cfg[v]
	--			cost = cost + cfg.cost[3]
	--			RewardUtil:mergeCfgReward(rewards, cfg.reward)
	--			break
	--		end
	--	end
	--end
	cost = contribution_cfg[self.m_select_id].cost
	return cost, rewards
end


return M
