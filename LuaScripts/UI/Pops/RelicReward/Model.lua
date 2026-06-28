local M = class("RelicRewardModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_heirlooms = self.m_params.heirlooms or {}
	self:initHeirloomData()
end

function M:initHeirloomData()
	local show_data = {}
	local heirlooms = self.m_heirlooms or {}
	local heirloom = ConfigManager:getCfgByName("heirloom")
	for k,v in pairs(heirlooms) do
		local cfg = heirloom[v]
		if cfg then
			table.insert(show_data, {id = v, cfg = cfg})
		end
	end
	self.m_heirlooms_data = show_data
end

function M:getHeirloomData()
	return self.m_heirlooms_data or {}
end

return M
