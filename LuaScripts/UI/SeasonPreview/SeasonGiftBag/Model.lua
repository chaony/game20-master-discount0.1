local M = class("SeasonGiftBagModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self.m_act_data = self.m_params.active_data or nil
	self.m_open_id = 313
	if self.m_act_data then
		self.m_version = self.m_act_data.version
		self:getData("active_common_gift_index", {open_id = self.m_open_id, vsn = self.m_version})
	else
		self:getData("")
	end
end

function M:onEnter()
	self.m_is_token = self.m_params.is_token or false
	self:initData()
end

function M:initData(data)
	table.merge(self.m_data, data or {})
	self:initGiftBagData()
end

function M:initGiftBagData()
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

--检查页签是否解锁
function M:getPaperStatus(paper_index)
	paper_index = paper_index - 1
	if paper_index <= 0 then
		return 1
	end
	return self.m_paper_done_data[paper_index] ~= nil and 1 or 0
end

function M:getGiftBagData()
	return self.m_gift_data or {}
end

return M
