local M = class("GuJianQiTanMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("ancient_sword_and_wonderland_index")
end

function M:onEnter()
	if self.m_data.akuma_open_time == nil then
		self.m_data.akuma_open_time = 0
	end
	self.m_show_done_flag = false
	self:updateShowDoneFlag()
end

function M:updateMainData(data)
	table.merge(self.m_data, data)
end

function M:getMainData()
	return self.m_data
end

function M:getVersion()
	return self.m_data.version
end

function M:activeDateCheck()
	if self.m_data and self.m_data["end"] == 1 then
		return false
	end
	return true
end

--古剑现世是否已通关
function M:updateShowDoneFlag()
	if self.m_show_done_flag == false then
		for k, v in pairs(self.m_data.finish_level_ids or {}) do
			if v == 301 then
				self.m_show_done_flag = true
				break
			end
		end
	end
end

function M:isActivityShowDone()
	return self.m_show_done_flag
end

function M:getMazeOpenTime()
	return self.m_data.akuma_open_time or 0
end

--获取桃花活动url
function M:getActiveURL()
	local active_tab = ConfigManager:getCfgByName("active")
	local url = ""
	for i, v in pairs(active_tab) do
		if v.open_id == 280 then
			url = v.link
		end
	end
	local token = UserDataManager.client_data:getSdkToken()
	local role_id = UserDataManager.user_data:getUid()
	local server_id = UserDataManager.server_data:getServerId()
	if url:find("?") then
		url = url.."&"
	else
		url = url.."?"
	end
	local new_url = url.."access_token="..token.."&role_id="..role_id.."&server_id="..server_id or ""
	return new_url
end

return M
