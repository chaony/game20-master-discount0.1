local M = class("UnionUpgradeModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params or {}
end

function M:getEmblemNumber(guild_lv)
	local guild_flag = ConfigManager:getCfgByName("guild_flag")
	local num = 0
	for i,v in ipairs(guild_flag) do
		if v.unlock_level <= guild_lv then
			num = num + 1
		end
	end
	return num
end

function M:isCanUpgrade()
	local guild = ConfigManager:getCfgByName("guild")
	local cur_cfg = guild[self.m_data.guild.level]
	return self.m_data.guild.exp >= cur_cfg.exp 
end

return M
