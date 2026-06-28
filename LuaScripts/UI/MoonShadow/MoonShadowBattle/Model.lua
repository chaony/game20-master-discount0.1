local M = class("MoonShadowBattleModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_rank_type = 0 --1日排行数据, 0期排行数据
	self.m_version = self.m_params.version or 0
	self.m_max_damage = self.m_params.max_damage or 0
	self.m_open_status = self.m_params.open_status or 0
	self.m_rank_data = {}
end

function M:getVersion()
	return self.m_version
end

function M:getRankType()
	return self.m_rank_type
end

function M:updateRankData(data)
	self.m_rank_data = data
end

function M:getRankData()
	if self.m_rank_data then
		return self.m_rank_data.ranks or {}
	end
	return {}
end

function M:getEnemy()
	if self.m_params then
		return self.m_params.enemy
	end
	return {}
end

function M:getHeirloom()
	if self.m_params then
		return self.m_params.heirloom
	end
	return {}
end

function M:setMaxDamageData(damage)
	self.m_max_damage = damage
end

function M:getMaxDamage()
	return self.m_max_damage
end

return M
