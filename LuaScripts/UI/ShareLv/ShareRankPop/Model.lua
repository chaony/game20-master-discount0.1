local M = class("ShareRankPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("hero_crystal_get_rank")
end

function M:onEnter()
	self:setData()
	self.m_select_index = 0
	self.m_open_hint = false
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local crystal = crystal_upgrade[UserDataManager.m_clv] 
	self.m_clv = crystal and crystal.display_level or 0
	if next(self.m_ranks_sky) ~= nil then
		self.m_select_index = 3
	elseif next(self.m_ranks_land) ~= nil then
		self.m_select_index = 2
	else
		self.m_select_index = 1	
	end
end

function M:setData(data)
	if data and next(data) ~= nil then
		self.m_data = data
	end
	self.m_ranks_sky = self.m_data.ranks_sky or {} --天
	self.m_ranks_people = self.m_data.ranks_people or {} -- 人
	self.m_ranks_land = self.m_data.ranks_land or {}  -- 地
end

function M:getDispLv(lv)
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local crystal = crystal_upgrade[lv] 
	if crystal then
		return crystal.display_level
	end
	return 0
end

return M
