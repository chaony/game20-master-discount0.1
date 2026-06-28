---@class PrestigeGetPopModel : OODataBase
local M = class("PrestigeGetPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	-- 1 全部, 2 一星, 3 二星, 4 三星, 5 四星
	self.view_sort_type = 1
	
	self.selected_gridId_tab = {}
	self.self_time_data = {}
	self.block_shape_cfg = ConfigManager:getCfgByName("prestige_piece_shape")
	self.affix_cfg = ConfigManager:getCfgByName("prestige_piece_affix")
	self.allBlockDataList = table.copy(self.m_params.data)
end

function M:getViewList()
	for _, v in pairs(self.allBlockDataList) do
		v.times = 0
		if v.expire and v.expire > 0  then
			v.times = v.expire - UserDataManager:getServerTime()
		else
			v.times = 0
		end
	end
	return self.allBlockDataList
end

function M:getStarByShape(block_shape)
	return self.block_shape_cfg[block_shape].star
end

function M:getAnchorPointOfBlockShape(block_shape)
	return self.block_shape_cfg[block_shape].anchor_point
end

function M:setAllSelectedGrid()
	self.selected_gridId_tab = {}
	local list = self:getViewList()
	for _, v in pairs(list) do
		if v.status ~= 0 then
			table.insert(self.selected_gridId_tab, v.id)
		end
	end
end

function M:getAttrByAffixID(id)
	return self.affix_cfg[id].attr
end
function M:clearAllSelectedGrid()
	self.selected_gridId_tab = {}
end
function M:UpdateDataTime()
	for k,v in pairs(self.self_time_data) do
		if v.cell_data then
			if v.cell_data.times and v.cell_data.times > 0 then
				v.cell_data.times = v.cell_data.times - 1
			end
		end
	end
end

return M
