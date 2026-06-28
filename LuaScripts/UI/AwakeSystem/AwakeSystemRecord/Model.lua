local M = class("AwakeSystemRecordModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self:initCfg()
	self.m_hero_id = self.m_params.hero_id
	self.m_hero_data = self.m_params.hero_data
	self.next_page = {}
	self:initHomePage()
end

function M:initCfg()
	self.m_awaken_book_cfg = ConfigManager:getCfgByName("awaken_book")
end

function M:initHomePage()
	self.m_home_page = 0
	self.m_max_page = 0
	local pages = table.nums(self.m_awaken_book_cfg)
	self.rate = pages%2
	for k,v in pairs(self.m_awaken_book_cfg) do
		self.next_page[v.next] = k
		if v.next == 0then
			self.m_max_page = k
		end
	end
	if self.rate == 0 then
		self.m_max_page = self.next_page[self.m_max_page]
	end
	for k1,v1 in pairs(self.m_awaken_book_cfg) do
		if not self.next_page[k1] then
			self.m_home_page = k1
		end			
	end
	local s
end

return M
