local M = class("JewelModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self:getData("jewel_index")
	self:getData()
end

function M:onEnter()
	self.m_is_book = self.m_params.is_book or false --是否图鉴显示
	--[[self.m_jewels = {}
	for k,v in pairs(self.m_data.jewels) do
		self.m_jewels[tonumber(k)] = v --转key为数值
	end]]--
	--[[self.m_gacha = {
		total = self.m_data.gacha_total_num,
		week = self.m_data.gacha_week_num,
		wishes = self.m_data.gacha_wishes,
	}]]--
	--self.m_gacha_total_num = self.m_data.gacha_total_num
	--self.m_gacha_week_num = self.m_data.gacha_week_num
	--self.m_gacha_wishes = self.m_data.gacha_wishes
	--统计，激活宝物/图鉴宝物
	--self.m_detail_tab = ConfigManager:getCfgByName("jewel_detail")
	--self.m_chip_tab = ConfigManager:getCfgByName("jewel_chip_quality")
	--[[self.m_jewels_num = {} --统计各品质激活数量
	for k,v in pairs(self.m_detail_tab) do
		local quality = v.quality
		if self.m_jewels_num[quality] == nil then
			self.m_jewels_num[quality] = {num = 0, total = 0}
		end
		if self.m_jewels[k] ~= nil then --已激活
			self.m_jewels_num[quality].num = self.m_jewels_num[quality].num + 1
		end
		self.m_jewels_num[quality].total = self.m_jewels_num[quality].total + 1
	end]]--
end

--品质降序>星级降序>未激活（拥有碎片）
--未激活的秘宝，且秘宝碎片数量为0时，不显示
function M:filterList(quality)
	--激活的
	local list = {}
	local jewels = UserDataManager.jewel_data:getJewels()
	for k,v in pairs(jewels) do
		if quality == 0 then
			table.insert(list, {id = k})
		else
			local cfg = UserDataManager.jewel_data:getDetailCfg(k)
			if quality == cfg.quality then
				table.insert(list, {id = k})
			end
		end
	end
	--未激活且有碎片的
	local list2 = {}
	local book_jewels = UserDataManager.jewel_data:getDetailCfg()
	for k,v in pairs(book_jewels) do
		if quality == 0 or v.quality == quality then
			local is_active = UserDataManager.jewel_data:isActiveJewel(k)
			if is_active == false then
				local data, item_cfg = UserDataManager.item_data:getItemDataById(v.chip_id)
				if data.num > 0 then --有碎片
					local chip_cfg = UserDataManager.jewel_data:getChipCfg(v.quality)
					local active_num = chip_cfg.active_num
					table.insert(list2, {id = k, user_chip_num = data.num, need_chip_num = active_num})
				end
			end
		end
	end
	--排序
	local function sortFunc(a, b)
		local cfg_a = UserDataManager.jewel_data:getDetailCfg(a.id)
		local cfg_b = UserDataManager.jewel_data:getDetailCfg(b.id)
		if cfg_a.quality == cfg_b.quality then
			local jewel_a = UserDataManager.jewel_data:getJewel(a.id)
			local jewel_b = UserDataManager.jewel_data:getJewel(b.id)
			if jewel_a.awaken == jewel_b.awaken then
				return jewel_a.evo > jewel_b.evo
			else
				return jewel_a.awaken > jewel_b.awaken
			end
		else
			return cfg_a.quality > cfg_b.quality
		end
	end
	local function sortFunc2(a, b)
		local cfg_a = UserDataManager.jewel_data:getDetailCfg(a.id)
		local cfg_b = UserDataManager.jewel_data:getDetailCfg(b.id)
		if cfg_a.quality == cfg_b.quality then
			return a.user_chip_num > b.user_chip_num
		else
			return cfg_a.quality > cfg_b.quality
		end
	end
	table.sort(list, sortFunc)
	table.sort(list2, sortFunc2)
	table.insertto(list, list2)
	return list
end

function M:filterBooks(quality)
	local list = {}
	local book_jewels = UserDataManager.jewel_data:getDetailCfg()
	for k,v in pairs(book_jewels) do
		if quality == 0 or v.quality == quality then
			table.insert(list, {id = k})
		end
	end
	local function sortFunc(a, b)
		local cfg_a = UserDataManager.jewel_data:getDetailCfg(a.id)
		local cfg_b = UserDataManager.jewel_data:getDetailCfg(b.id)
		if cfg_a.quality == cfg_b.quality then
			return a.id < b.id
		else
			return cfg_a.quality > cfg_b.quality
		end
	end
	table.sort(list, sortFunc)
	return list
end

return M