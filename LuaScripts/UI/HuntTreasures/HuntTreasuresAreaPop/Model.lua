local M = class("HuntTreasuresAreaPop", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_region_id = self.m_params.region_id
	local sub_id = self.m_params.sub_id or 1
	self.m_sel_tab_index = sub_id
	self:getData("mining_region_index", {region_id = self.m_region_id, sub_id = sub_id})
end
M.open_id = {182, 183, 184, 185}
function M:onEnter()
	self.m_defautl_index = 0
	self.m_mining_region_config = ConfigManager:getCfgByName("mining_region") or nil
	self.m_mining_location_config = ConfigManager:getCfgByName("mining_location") or nil
	self.m_area_group = {}
	self.m_location_tab = {}
	self:updateData()
	self:initAreaCfg()

end

function M:getCrossData()
	local cross_team = self.m_data.cross_team or 0
	local cross_time = self.m_data.cross_time or 0
	return cross_team, cross_time
end

function M:updateData(response)
	self.m_data = response and response or self.m_data
end

local location2_name_tab = {"huo", "mu", "jin", "shui"}
function M:getRegionNameById(index)
	local region_name = "tid#mining_location2_"
	region_name = region_name .. location2_name_tab[self.m_region_id] .. "_" .. index
	return region_name
end

function M:initAreaCfg()
	local temp = {}
	local my_location_id = 0
	
	if self.m_data and self.m_data.locations then
		for i, v in pairs(self.m_data.locations) do
			my_location_id = i
			break
		end
	end
	for i = 1, #self.m_mining_location_config[self.m_region_id] do
		local region_second = self.m_mining_location_config[self.m_region_id][i].region_second
		if not(temp[region_second]) then
			temp[region_second] = {}
		end
		table.insert(temp[region_second], self.m_mining_location_config[self.m_region_id][i])
		if region_second == self.m_sel_tab_index and i ==  tonumber(my_location_id) then
			self.m_defautl_index = #temp[region_second]
		end
	end
	self.m_area_group = temp
end

function M:isOpenByStage(need_stage)
	local self_stage = UserDataManager:getCurStage()
	local tips_str = ""
	if need_stage > self_stage then
		local stage = ConfigManager:getCfgByName("stage")
		local stage_item = stage[need_stage] or {}
		local name = Language:getTextByKey(tostring(stage_item.map_point_name))
		tips_str = Language:getTextByKey("hunt_treasure_str_046", name)
	end
	return need_stage <= self_stage, tips_str
end

function M:getLocationNetData(location_id)
	local location_data = nil
	if self.m_data and self.m_data.locations and self.m_data.locations[tostring(location_id)] then
		location_data = self.m_data.locations[tostring(location_id)]
	end
	return location_data
end

function M:getAreaByRegionId(region_id)
	local show_ids =  self.m_data.show_lids
	local cur_data = self.m_area_group[region_id]
	local data = {}
	for k,v in pairs(cur_data) do 
		for m,n in pairs(show_ids) do
			if tonumber(n) == v.id then
				table.insert(data,v)
			end
		end
	end	
	return data or {}
end

function M:isUnlockByAreaData(area_data)
	local unlock_id = area_data[1].unlock
	local type = area_data[1].type -- 地区类型 1 自己 2 所有人 3 跨服
	local open_flag, tips_str = self:isOpenByStage(unlock_id)
	if type == 3 and open_flag then
		local cross_team, cross_time = self:getCrossData()
		if cross_team > 0  then
		elseif cross_time > 0 and cross_time - UserDataManager:getServerTime() > 0  then
			open_flag = false
		end
	end
	return open_flag, tips_str
end

function M:getLeftShowData()
	local unlock_num = 0
	local show_data = {}
	for i = 1, #self.m_area_group do
		local area_data = self.m_area_group[i]
		local open_flag = self:isUnlockByAreaData(area_data)
		if open_flag then
			table.insert(show_data, self.m_area_group[i])
		elseif unlock_num == 0 then
			table.insert(show_data, self.m_area_group[i])
			unlock_num = unlock_num + 1
		end
	end
	local jump_index = #show_data - unlock_num
	return show_data, jump_index
end

function M:getAreaQualityImg(index)
	local quality_img_name = ""
	if self.m_area_group[self.m_sel_tab_index][index] and self.m_area_group[self.m_sel_tab_index][index].region_quality then
		quality_img_name = self.m_area_group[self.m_sel_tab_index][index].region_quality
	end
	return tostring(quality_img_name)
end

function M:getLeftImgName(sub_id)
	local img_name = ""
	if self.m_mining_region_config[self.m_region_id] and self.m_mining_region_config[self.m_region_id].resource_lct2 then
		local resource_lct2 = self.m_mining_region_config[self.m_region_id].resource_lct2
		if resource_lct2[sub_id] then
			img_name = resource_lct2[sub_id]
		end
	end
	return img_name
end

function M:getLocationId(click_index)
	local temp = self:getAreaByRegionId(self.m_sel_tab_index)
	local location_id = self:getAreaByRegionId(self.m_sel_tab_index)[click_index].id
	return location_id
end

function M:getRefreshRemainingTime()
	local next_refresh = data.next_refresh or 0
	return next_refresh - UserDataManager:getServerTime()
end

return M
