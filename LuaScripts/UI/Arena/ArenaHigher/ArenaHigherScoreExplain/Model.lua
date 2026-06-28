local M = class("ArenaHigherScoreExplainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	
end

function M:getShowData()
	local show_data = {}
	local high_arena = ConfigManager:getCfgByName("high_arena")
	for k, v in pairs(high_arena) do
		table.insert(show_data, {id = k, cfg = v})
	end
	table.sort(show_data, function(data1, data2) 
		return data1.id < data2.id
	end)
	return show_data
end

return M
