local M = class("FineClothesModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"

	self.m_open_ID = 371
	self.m_version = self.m_params.version or 1
	self:getData("active_common_gift_index", {open_id = self.m_open_ID, vsn = self.m_version})
end

function M:onEnter()
	self.m_callback = self.m_params.callback
	self.m_callback_new = self.m_params.callback_new
	self.is_tokens = false
	if self.m_params.is_token == true then --代金券进入
		self.is_tokens = true
	end
	self.m_page_cur = 1
	self.m_gift_data = {}
	self:initGiftData()
end

function M:updateData(data)
	table.merge(self.m_data, data)
end

function M:initGiftData()
	local gift_data_tab = ConfigManager:getCfgByName("tongyong_gift")
	local gift_data_open_ID = gift_data_tab[self.m_open_ID] or {}
	self.m_gift_data[1] = gift_data_open_ID[self.m_version][1][1][1][1] or {}
	self.m_gift_data[2] = gift_data_open_ID[self.m_version][1][1][2][2] or {}
end

function M:getTokenFlag()
	return self.is_tokens
end

function M:getOpenID()
	return self.m_open_ID
end

function M:getVersion()
	return self.m_version
end

function M:setCurrentPage(page_ID)
	self.m_page_cur = page_ID
end

function M:getCurrentPage()
	return self.m_page_cur
end

function M:getBackgroundImageName()
	if self.m_gift_data[1] then
		return self.m_gift_data[1].background or ""
	end
	return ""
end

function M:getGiftDataWithPageID(page_ID)
	return self.m_gift_data[page_ID] or {}
end

function M:getCurrentPos()
	return self.m_page_cur
end

function M:getCurrentGiftID()
	if self.m_gift_data[self.m_page_cur] then
		return self.m_gift_data[self.m_page_cur].id or -1
	end
	return -1
end

function M:getCurrentGiftChargeID()
	if self.m_gift_data[self.m_page_cur] then
		return self.m_gift_data[self.m_page_cur].charge_id or -1
	end
	return -1
end

----是否购买超限
function M:checkGiftTimesLimited(pos, gift_id)
	if self.m_data and gift_id then
		local gifts_data = self.m_data.gifts_data or {}
		local gifts_data_paper = gifts_data["1"] or {}
		local gifts_data_pos = gifts_data_paper[tostring(pos)] or {}
		if gift_id == gifts_data_pos.cid and gifts_data_pos.times > 0 then
			return true
		end
		return false
	end
	return true
end

function M:getEndTs()
	local active_data = UserDataManager:getActivesRechargeDataByOpenId(371) or {}
	if active_data and active_data.end_ts then
		return active_data.end_ts - UserDataManager:getServerTime()
	end
	return 0
end

return M
