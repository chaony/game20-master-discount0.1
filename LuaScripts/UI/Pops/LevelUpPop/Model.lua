local M = class("LevelUpPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_old_lv = self.m_params.old_lv
	self.m_lv = self.m_params.lv
	self.m_rewards = self:getRewards()
end

function M:getRewards()
	local rewards = {}
	local pl = ConfigManager:getCfgByName("player_level")
	for i = self.m_old_lv+1, self.m_lv do
		local m_pl = pl[i]
		if m_pl then
			for k,v in pairs(m_pl.reward) do
				if self:checkInTab(rewards, v) == true then
					self:checkInRewards(rewards, v)
				else
					--table.insertto(rewards, v)	
					table.insert( rewards, v)
				end
			end
		end
	end
	return rewards
end

function M:checkInRewards(rewards, data)
	for k,v in pairs(rewards) do
		if v[1] == data[1] and v[2] == data[2] then
			v[3] = v[3] + data[3]
		end
	end	
	return rewards
end

function M:checkInTab(rewards, data)
	for k,v in pairs(rewards) do
		if v[1] == data[1] and v[2] == data[2] then
			return true
		end
	end	
	return false
end

return M
