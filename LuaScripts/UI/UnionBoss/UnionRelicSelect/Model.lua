local M = class("UnionRelicSelectModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self:initHeirloomData()
end

function M:initHeirloomData()
	local show_data = {}
	self.m_mode = self.m_params.mode or 0 -- 1:免费获得  0:boss掉落
	local heirloom_pool = self.m_params.heirloom_pool
	local heirloom = ConfigManager:getCfgByName("heirloom")
	for k,v in pairs(heirloom_pool) do
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
