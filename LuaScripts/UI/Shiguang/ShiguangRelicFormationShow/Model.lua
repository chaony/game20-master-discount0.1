local M = class("ShiguangRelicFormationShowModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self:initData(self.m_params.data)
end

function M:initData(data)
	self.m_data = data or self.m_data
	self:initHeirloomData()
end

function M:initHeirloomData()
	local show_data = {}
	local heirlooms = self.m_data.heirlooms or {}
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
	self.m_heirlooms_data = show_data
end

function M:getHeirloomData()
	return self.m_heirlooms_data or {}
end

function M:getHeirloomNum()
	local heirlooms = self.m_data.heirlooms or {}
	return GameUtil:getHeirloomNum(heirlooms)
end

return M
