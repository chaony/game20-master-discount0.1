local M = class("GuJianQiTanGiftModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_open_id = 284
	self.m_version = self.m_params.version or 1
	self:getData("active_common_gift_index", {open_id = self.m_open_id, vsn = self.m_version})
end

function M:onEnter()
	self.m_toggle_selected_index = 1
	self.m_hero_skin_id = 1
	self.m_hero_skin_cfg = {}
	self.m_paper_done_data = {}
	self.m_gift_data = {}
	self.is_tokens = self.m_params.is_token
	if self.m_params.is_token == true then --代金券进入
		self.is_tokens = true
	else
		self.is_tokens = false
	end
	self:initData()
	self.m_toggle_selected_index = self:getCurIndex()
end

--数据初始化
function M:initData()
	self:initGiftData()
	self:initHeroSkinCfg()
end

function M:getCurIndex()
	local cur_index = 1
	for i = 1, #self.m_gift_data do
		local sell_out = false
		for j = 1, #self.m_paper_done_data do
			if i == self.m_paper_done_data[j] then
				sell_out = true
				break
			end
		end
		if sell_out == false then
			return  i
		end
	end
	return cur_index
end

----数据初始化-礼包
function M:initGiftData()
	self.m_paper_done_data = self.m_data.paper_done or {}
	
	self.m_gift_data = {}
	local gift_tab = ConfigManager:getCfgByName("tongyong_gift")[self.m_open_id] or {}
	local gift_version_tab = gift_tab[self.m_version] or {}
	local gift_data = self.m_data.gifts_data or {}
	local status, status_paper
	local day_config = self.m_data.config_day or {}
	local day_index = 0
	for paper_index, v in pairs(gift_data) do
		paper_index = tonumber(paper_index)
		day_index = day_config[tostring(paper_index)]
		for place_index, vv in pairs(v) do
			place_index = tonumber(place_index)
			local cfg
			if gift_version_tab and gift_version_tab[paper_index] and gift_version_tab[paper_index][day_index] and gift_version_tab[paper_index][day_index][place_index] then
				cfg = gift_version_tab[paper_index][day_index][place_index][vv.cid]
			end
			if cfg then
				status = 1 --可购买
				if vv.times >= cfg.time_limit then
					status = 2 --已超过限购，不可购买
				end
				status_paper = self:getPaperStatus(paper_index)
				if self.m_gift_data[paper_index] == nil then
					self.m_gift_data[paper_index] = {}
				end
				table.insert(self.m_gift_data[paper_index], {cfg = cfg, paper_index = paper_index, place_index = place_index, status_paper = status_paper, status = status, times = vv.times})
			end
		end
	end
	for paper_index, v in pairs(self.m_gift_data) do
		table.sort(v, function(a, b)
			if a.status == b.status then
				return a.place_index < b.place_index
			else
				return a.status < b.status
			end
			
		end)
	end
end

----数据初始化-英雄皮肤
function M:initHeroSkinCfg()
	local clothes_tab = ConfigManager:getCfgByName("tongyong_hero_gift")[self.m_open_id] or {}
	local clothes_version_tab = clothes_tab[self.m_version] or {}
	self.m_hero_skin_cfg = clothes_version_tab[1] or {}
end

--数据更新
function M:updateData(data)
	table.merge(self.m_data, data)
	self:initData()
end

function M:updateGiftData(data)
	table.merge(self.m_paper_done_data, data.paper_done)
	table.merge(self.m_data.gifts_data, data.gifts_data)
	self:initGiftData()
end

function M:updateHeroSkinData(data)
	table.merge(self.m_data.clothes_gifts, data)
end

--数据获取
function M:getTokenFlag()
	return self.is_tokens
end

function M:getVersion()
	return self.m_version
end

function M:getGiftData()
	return self.m_gift_data[self.m_toggle_selected_index]
end

function M:getHeroSkinCfg()
	return self.m_hero_skin_cfg
end

--检查页签是否解锁
function M:getPaperStatus(paper_index)
	paper_index = paper_index - 1
	if paper_index <= 0 then
		return 1
	end
	return self.m_paper_done_data[paper_index] ~= nil and 1 or 0
end

----是否购买超限
function M:checkHeroSkinTimesLimited()
	local hero_skin_done_data = self.m_data.clothes_gifts or {}
	for k,v in pairs(hero_skin_done_data) do
		if tonumber(k) == self.m_hero_skin_id then
			return true
		end
	end
	return false
end

----活动结束时间
function M:getTimeEnd()
	local server_time = UserDataManager:getServerTime()
	local next_fresh_time = TimeUtil.getIntTimestamp(server_time)
	local end_times = next_fresh_time + 24 * 3600
	return end_times
end

----帮助说明
function M:getHelpCfg()
	local gift_value_tab = ConfigManager:getCfgByName("lantern_festival")
	return gift_value_tab[self.m_version]
end

--机制数据
function M:getOpenID()
	return self.m_open_id
end

function M:setSelectedIndex(index)
	self.m_toggle_selected_index = index
end

function M:getSelectedIndex()
	return self.m_toggle_selected_index
end

function M:checkToggleOpenStatus(index)
	return self.m_gift_data[index] ~= nil
end

function M:checkToggleRedPoint(paper_index)
	local gift_data = self.m_gift_data[paper_index] or {}
	for place_index, v in pairs(gift_data) do
		if v.cfg.price == 0 and v.status == 1 then
			return true
		end
	end
	return false
end

return M
