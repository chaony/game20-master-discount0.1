local M = class("CompareSwordResultModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_version = self.m_params.active.version or 1
	self.m_open_id = self.m_params.active.open_id or 414
	self:getData("full_service_history_top3", {vsn = self.m_version})
end

function M:onEnter()
	self.m_actives = self.m_params.active or {}
	self.m_all_actives_cfg = {}
	self.m_top_data = {}
	local pharse_data = self.m_actives.phase_info or {}
	self.m_pharse = pharse_data.phase or 3
	self:initData()
	self:initCfg()
end

function M:initCfg()
	local cfg = ConfigManager:getCfgByName("active")
	for k,v in pairs(cfg) do
		if v.open_id == self.m_open_id then
			table.insert(self.m_all_actives_cfg,v)
		end
	end
end

function M:initData()
	self.m_top_data = self.m_data.users or {}
end

function M:getTopData()
	return self.m_top_data or {}
end


function M:updateData( response )		
	table.merge(self.m_data , response)
	self:initData()
end

function M:getDataByVersion(call_back)
	local function netCallback(response)
		if response then
			self.m_top_data = response.users
			call_back()
		end
	end
	self:getNetData("full_service_history_top3", {vsn = self.m_version }, netCallback)
end

function M:destroy()
	M.super.destroy(self)
end

return M