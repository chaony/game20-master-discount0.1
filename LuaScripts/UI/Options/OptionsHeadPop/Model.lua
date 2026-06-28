local M = class("OptionsHeadPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_tab = 1
	self.m_head_index = 1
	self.m_border_index = 1
	self.m_use_head_index = 1
	self.m_upgrade_btn_status = 1 --1升级，2兑换元宝
	self.m_sel_title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
	self.m_title_data = {}	--称号数据
	self.m_title_material_data = {} --称号材料数据
	self.m_title_preview_data = {} --称号预览数据
	self.m_head = {}
	local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
	self.m_avatar = tonumber(avatar)
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	local player_picture_cfg = ConfigManager:getCfgByName("player_picture")
	local unlock_head = {}
	local cur_season = UserDataManager:getCurSeason()

	for k,v in pairs(player_picture_cfg) do
		local activation_state = self:playerPictureIsActivationState(k)
		local cfg_season = v.season or 0
		if cur_season >= cfg_season then
			if v.unlock == 1 then
				local hero_detail_item = hero_detail[k]
				if hero_detail_item and hero_detail_item.unlock_playericon == 1 then
					if activation_state then
						table.insert(self.m_head, k)
					else
						table.insert(unlock_head, k)
					end
				end
			elseif v.unlock == 2 or v.unlock == 3 then
				if activation_state then
					table.insert(self.m_head, k)
				else
					table.insert(unlock_head, k)
				end
			end
		end
	end

	local function headSort(d1, d2)
		return d1 < d2
	end
	table.sort( self.m_head, headSort )
	table.sort( unlock_head, headSort )
	table.insertto(self.m_head, unlock_head)

	for k,v in pairs(self.m_head) do
		if v == self.m_avatar then
			self.m_head_index = k
			break
		end
	end

	local frame = UserDataManager.user_data:getUserStatusDataByKey("frame")
	self.m_border = {}
	local player_frame_cfg = ConfigManager:getCfgByName("player_frame") or {}
	local unlock_border = {}
	for id, v in pairs(player_frame_cfg) do
		local cfg_season = v.season or 0
		if cur_season >= cfg_season then
			if v.show == 1 then
				local activation_state = self:playerFrameIsActivationState(id)
				if activation_state then
					table.insert(self.m_border, {id = id, cfg = v, activation_state = activation_state})
				else
					table.insert(unlock_border, {id = id, cfg = v, activation_state = activation_state})
				end
			else
				local activation_state = self:playerFrameIsActivationState(id)
				if activation_state then
					table.insert(self.m_border, {id = id, cfg = v, activation_state = activation_state})
				end
			end
		end
	end
	local function frameSort(d1, d2)
		return d1.cfg.order < d2.cfg.order
	end
	table.sort( self.m_border, frameSort)
	table.sort(unlock_border, frameSort )
	table.insertto(self.m_border, unlock_border)

	for k,v in pairs(self.m_border) do
		if v.id == frame then
			self.m_border_index = k
			break
		end
	end
	
	self:updateAllTitleData()
end

function M:setTab(index)
	self.m_tab = index
end

function M:setHeadSelect(index)
	self.m_head_index = index
end

function M:setBorderSelect(index)
	self.m_border_index = index
end

-- 头像是否激活
function M:playerPictureIsActivationState(id)
	id = tonumber(id)
	local player_picture_cfg_item = ConfigManager:getPlayerPictureCfg(id)
	local activation_state = false
	local lock_type = 1 -- 1侠客未获得，无法使用头像， 2好感度不足
	if player_picture_cfg_item then
		local unlock = player_picture_cfg_item.unlock or 0 -- 1 获得卡牌激活 2 运营投放 3 激活头像激活
		if unlock == 1 then
			activation_state = UserDataManager.hero_data:checkHeroCollect(id)
			if activation_state == true then 
				--英雄头像激活方式修改 
				-- 按最大 evo等级解锁
				local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
				if cfg ~= nil and cfg.evo > 3 then
					local maxData = UserDataManager:getHeroMaxEvo(id) or {}
					local evo = maxData.max_evo or 0
					if evo < player_picture_cfg_item.unlock_evo then
						activation_state = false
						lock_type=2
					end
				end
			end
		elseif unlock == 2 then
			local avatars = UserDataManager:getAvatars()
			for k,v in pairs(avatars) do
				if tonumber(v) == id then
					activation_state = true
					break
				end
			end
		elseif unlock == 3 then
			local skins = UserDataManager:getHeroSkins()
			for k,v in pairs(skins) do
				if tonumber(k) == id then
					activation_state = true
					break
				end
			end
		end
	end
	return activation_state,lock_type
end

-- 头像框是否激活
function M:playerFrameIsActivationState(id)
	local activation_state = false
	local frames = UserDataManager:getFrames()
	for k,v in pairs(frames) do
		if tonumber(v) == id then
			activation_state = true
			break
		end
	end
	return activation_state
end

-- 称号收集属性
function M:getTitleCollectAttrById(title_id)
	local attr = {}
	local title_cfg = ConfigManager:getCfgByName("title") or {}
	if title_cfg[title_id] then
		attr = title_cfg[title_id].attr1
	else
		Logger.logWarningAlways("title表里没有找的"..title_id)
	end
	return attr
end

-- 称号佩戴属性
function M:getTitleWearAttrById(title_id)
	local attr = {}
	local title_cfg = ConfigManager:getCfgByName("title") or {}
	if title_cfg[title_id] then
		attr = title_cfg[title_id].attr2
	else
		Logger.logWarningAlways("title表里没有找的"..title_id)
	end
	return attr
end
-- 通过id获取称号配置
function M:getTitleCfgById(title_id)
	title_id = tonumber(title_id)
	local title_cfg = ConfigManager:getCfgByName("title") or {}
	local cfg = {}
	if title_cfg[title_id] then
		cfg.id = title_id
		cfg = title_cfg[title_id]
	else
		Logger.logWarningAlways("title表里没有找的"..title_id)
	end
	return cfg
end

-- 获取所有称号配置
function M:updateTitleData()
	self.m_title_data = {}
	local title_cfg = ConfigManager:getCfgByName("title") or {}
	local titleIds = UserDataManager.title_data:getTitlesId()
	local cur_season = UserDataManager:getCurSeason() -- 获取赛季
	table.sort(title_cfg, function(item1, item2) return item1.id < item2.id end)
	for i, v in pairs(title_cfg) do
		if v.season <= cur_season then -- 根据赛季获取称号配置
			v.id = i
			v.owner = table.indexof(titleIds, tostring(i)) == false and 0 or 1
			if v.level == 1 or v.owner == 1 then --一个称号的多个等级，只展示最低等级的，和拥有的等级
				table.insert(self.m_title_data, v)
			end
		end
	end
	local remove_flag = true 
	while(remove_flag) do
		remove_flag = false
		for _, item in pairs(self.m_title_data) do
			if table.indexof(titleIds, tostring(item.id)) then
				for index, v in pairs(self.m_title_data) do
					if v.id == item.order and item.id ~= item.order then -- 如果我拥有某个称号，最低等级的那个就不再展示，除非我拥有的是最低等级的
						table.remove(self.m_title_data, index)
						remove_flag = true
						break
					end
				end
			end
		end
	end
	
	local function sortFunc(data1, data2)
		local cfg1 = self:getTitleCfgById(data1.id)
		local cfg2 = self:getTitleCfgById(data2.id)
		if data1.owner == data2.owner then
			if cfg1.order == cfg2.order then
				return data1.id > data2.id
			else
				return cfg1.order < cfg2.order
			end
		else
			return data1.owner > data2.owner
		end
	end
	table.sort(self.m_title_data, sortFunc)
end

function M:getTitleData()
	return self.m_title_data
end

-- 获取预览称号配置
function M:updateTitlePreviewData()
	self.m_title_preview_data = {}
	local title_cfg = ConfigManager:getCfgByName("title") or {}
	local cur_season = UserDataManager:getCurSeason() -- 获取赛季
	for i, v in pairs(title_cfg) do
		if v.season <= cur_season then -- 根据赛季获取称号配置
			v.id = i
			if v.preview and v.preview == 1 then
				if self.m_title_preview_data[v.group] == nil then
					self.m_title_preview_data[v.group] = {}
				end
				table.insert(self.m_title_preview_data[v.group], v)
			end
		end
	end
	for i, group_title_data in pairs(self.m_title_preview_data) do
		table.sort(group_title_data, function(item1, item2) return item1.id < item2.id  end)
	end
end

function M:getTitlePreviewData(groupID)
	if groupID then
		return self.m_title_preview_data[groupID] or {}
	end
	return {}
end

function M:getDetailTitleData(groupID)
	if groupID then
		local group_title_data = self.m_title_preview_data[groupID] or {}
		for k , v in pairs(group_title_data) do
			return v
		end
	end
	return {}
end

-- 获取材料称号配置
function M:updateTitleMaterialData()
	self.m_title_material_data = {}
	local title_material_data = UserDataManager.title_data:getTitlePackagesData()
	local title_cfg
	for titleID, titleCount in pairs(title_material_data) do
		title_cfg = self:getTitleCfgById(titleID)
		if title_cfg then
			if self.m_title_material_data[title_cfg.group] == nil then
				self.m_title_material_data[title_cfg.group] = {}
			end
			table.insert(self.m_title_material_data[title_cfg.group], {ID = titleID, count = titleCount})
		end
	end
	for _, titles in ipairs(self.m_title_material_data) do
		table.sort(titles, function(item1, item2) return item1.ID < item2.ID end)
	end
end

function M:getTitleMaterialData(groupID)
	if groupID then
		return self.m_title_material_data[groupID] or {}
	end
	return {}
end

--我拥有的称号，有没有有材料的，即，可以升级或兑换元宝
function M:getTitleMaterialStatus()
	local count = 0
	local titleIds = UserDataManager.title_data:getTitlesId() or {}
	local title_cfg
	for i, titleID in pairs(titleIds) do
		title_cfg = self:getTitleCfgById(titleID)
		if self:canTitleUpgrade(title_cfg) and title_cfg.exp and title_cfg.exp > 0 then --有exp表示此称号配置了升级和兑换，没配置就不允许升级和兑换
			count = count + 1
		end
	end
	return count > 0 and true or false
end

function M:canTitleUpgrade(title_cfg)
	if title_cfg and title_cfg.group then
		local material_data = self:getTitleMaterialData(title_cfg.group)
		if next(material_data) then
			return true, material_data[1]
		end
	end
	return false, {}
end

function M:titleUpgradeLimited(groupID)
	if groupID then
		local group_title_data = self:getTitlePreviewData(groupID)
		local length = 0
		for K, v in pairs(group_title_data) do
			length = length + 1
		end
		return length <= 1
	end
	return true
end

function M:updateAllTitleData()
	self:updateTitleData()
	self:updateTitlePreviewData()
	self:updateTitleMaterialData()
end

function M:setTitleSelectId(title_id)
	self.m_sel_title_id = title_id
end

return M
