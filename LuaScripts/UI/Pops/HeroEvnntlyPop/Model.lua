local M = class("HeroEvnntlyPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.hero_id = self.m_params.hero_id
	self:getHeroData()
end

function M:getHeroData()
	self.herocfg =	self:getHeroById(self.hero_id)
end

function M:getHeroById(id)
	return UserDataManager.hero_data:getHeroConfigByCid(id)
end

function M:checkRedPoint()
	return UserDataManager.hero_data:checkHeroCollectPoint(self.herocfg.id)
end

function M:checkReward()
	local reward_cost = ConfigManager:getCommonValueById(110)
	return reward_cost[1]
end

return M
