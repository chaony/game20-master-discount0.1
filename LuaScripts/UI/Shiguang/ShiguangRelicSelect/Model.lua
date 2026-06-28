local M = class("ShiguangRelicSelectModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_cell_data = self.m_params.data
	self.m_show_tips = self.m_params.show_tips
	if self.m_show_tips == nil then
		self.m_show_tips = true
	end
	self:initData(self.m_data)
end

function M:initData(data)
	self.m_data = data or self.m_data
	self:initHeirloomData()
end

function M:initHeirloomData()
	local show_data = {}
	local heirloom_pool = self.m_cell_data.heirloom_pool or {}
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
