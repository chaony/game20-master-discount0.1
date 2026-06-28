local M = class("UnionRelicFormationShowModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self:initHeirloomData()
end

function M:initHeirloomData()
	local show_data = {}
	local show_guild_data = {}
	local heirlooms = self.m_params.heirlooms
	local guild_heirlooms = self.m_params.guild_heirlooms
	local heirloom = ConfigManager:getCfgByName("heirloom")
	for k,v in pairs(heirlooms) do
		local cfg = heirloom[v]
		if cfg then
			table.insert(show_data, {id = v, cfg = cfg})
		end
	end
	table.sort(show_data, function(data1, data2)
		return data1.cfg.quality > data2.cfg.quality
	end)
	for k,v in pairs(guild_heirlooms) do
		local cfg = heirloom[v]
		if cfg then
			table.insert(show_guild_data, {id = v, cfg = cfg})
		end
	end
	table.sort(show_guild_data, function(data1, data2)
		return data1.cfg.quality > data2.cfg.quality
	end)
	self.m_heirlooms_data = show_data
	self.m_guild_heirlooms = show_guild_data
end

function M:getHeirloomData()
	return self.m_heirlooms_data or {}
end

function M:getHeirloomNum()
	local heirlooms = {}
	return GameUtil:getHeirloomNum(heirlooms)
end

return M
