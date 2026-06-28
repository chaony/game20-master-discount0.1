local M = class("MazeStageShopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("maze_detail", {cell_id = self.m_params.data.id, mver = self.m_params.mver})
end

function M:onEnter()
	self.m_cell_data = self.m_params.data
	self.m_open_flag = self.m_params.open_flag
	self.m_callBack = self.m_params.callBack
	self:initData(self.m_data)
end

function M:initData(data)
	self.m_data = data or self.m_data
end

function M:getShowData()
	local show_data = {}
	local goods = self.m_data.goods or {}
	for k,v in pairs(goods) do
		v.index = k
		local item = v.item or {}
		local hero_ids = {}
		if #item > 2 then
			if item[1] == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
				hero_ids = GameUtil:getCanEquipHeroIds(item[2])
			end
		end
		v.hero_ids = hero_ids
		table.insert(show_data, v)
	end
	return show_data
end

function M:updateData(data)
	if data then
		table.merge(self.m_data.goods, data.goods or {})
	end
end

return M
