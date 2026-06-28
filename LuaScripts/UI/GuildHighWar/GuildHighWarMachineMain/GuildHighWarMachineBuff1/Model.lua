local M = class("GuildHighWarMachineMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	--Logger.logError(self.m_data, "----------巅峰--")
	self.talent_point ={}
	self.talent_data = self.m_params.data
	self.page_id = 1
	self.m_alpha = 0 --当前透明度值 0-~1
	self.m_max = 10 --调度
	self.m_cur = 0
	self:InitData(self.talent_data)
end

function M:InitData(data)
	self.talent_data = data
	self.talent_point ={}
	local cfg = ConfigManager:getCfgByName("talent_point")
	for k,v in pairs(data) do
		local cfg_data = cfg[tonumber(k)]
		for m,n in pairs(cfg_data) do
			if n.level == v then
				local data = n
				data.point_id = tonumber(k)
				data.cur_level = v
				table.insert(self.talent_point,data)
			end
		end
	end
	--self.talent_point = {{point_id = 1001}}
end
function M:getCurDataByPointId(id)
	for k,v in pairs(self.talent_point) do
		if v.point_id ==id then
			return v
		end
	end
	return nil
end

return M
