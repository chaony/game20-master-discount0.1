---@class SetHeroAndBackModel: OODataBase
local M = class("SetHeroAndBackModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_hero_id = self.m_params.hero_id
	self.m_back_img = self.m_params.back_img
	self.m_back_state = 1
	self:getData()
end

function M:onEnter()
	self.m_bg_cfg = ConfigManager:getCfgByName("main_bg")
end

function M:getHeroIDs(race)
	local hero_list = UserDataManager.hero_data.hero_collect
	local tmp_list = {}
	self.hero_list = {}
	for k,v in pairs(hero_list) do
		local cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(k))
		if race == 0 or race == cfg.race  then
			if tonumber(k) == self.m_hero_id then
				self.hero_list[#self.hero_list + 1] = tonumber(k) --当前侠客放到第一个
			else
				tmp_list[#tmp_list + 1] = tonumber(k)
			end
		end
	end
	local function sortFunc(d1,d2)
		return d2 < d1
	end
	table.sort(tmp_list, sortFunc)
	for k,v in pairs(tmp_list) do
		self.hero_list[#self.hero_list + 1] = v
	end
	return self.hero_list
end

function M:getHeroIDByIndex(index)
	return self.hero_list[index]
end

function M:checkRaceTypeCount(race)
	local hero_list = UserDataManager.hero_data:getHerosId()
	for k,v in pairs(hero_list) do
		local l_hero_data, l_hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
		if race == l_hero_cfg.race then
			return true
		end
	end
	return false
end

function M:getBGList()
	local list = {}
	for k,v in pairs(self.m_bg_cfg) do
		if v.big_img == self.m_back_img then
			local index = #list + 1
			list[index] = v --当前背景放到第一个
			list[index].id = k
			break
		end
	end
	for k,v in pairs(self.m_bg_cfg) do
		if v.big_img ~= self.m_back_img then
			local index = #list + 1
			list[index] = v
			list[index].id = k
		end
	end
	return list
end

function M:checkBGOpen(cfg)
	if cfg.is_free == 1 then
		return 1
	end
	local openIDs = UserDataManager.m_main_bgs
	if openIDs == nil then
		return 0
	end
	for k,v in pairs(openIDs) do
		if cfg.id == v then
			return 1
		end
	end
	return 0
end

return M