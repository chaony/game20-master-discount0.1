local M = class("JewelGachaWishPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_wishes = self.m_params.wishes --心愿秘宝
	self.m_wish_times = self.m_params.wish_times or self.m_wishes[1].times
end

--列表
function M:filterList(wish_times)
	local wish_tab = ConfigManager:getCfgByName("jewel_gacha_wish")
	return wish_tab[wish_times].candidates
	--[[local function sortFunc(a, b)
		local cfg_a = jewel_detail_tab[a.id]
		local cfg_b = jewel_detail_tab[b.id]
		if cfg_a.quality == cfg_b.quality then
			return a.id < b.id
		else
			return cfg_a.quality > cfg_b.quality
		end
	end
	table.sort(list, sortFunc)]]--
	--return list
end

--是否是已经实现的英雄
function M:checkWish(id)
	for k, v in ipairs(self.m_wishes) do
		if v.jewel == id then
			return true
		end
	end
	return false
end

--更新栏位
function M:updateWish(times, id)
	for k, v in ipairs(self.m_wishes) do
		if v.times == times then
			v.jewel = id
		end
	end
end

function M:getJewelId(times)
	for k, v in pairs(self.m_wishes) do
		if v.times == times then
			return v.jewel
		end
	end
	return 0
end

return M