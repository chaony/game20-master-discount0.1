local M = class("GuildHighWarMachineMainModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.talent_point ={}
	self.m_point_data = self.m_params.data
	self.talent_point = self.m_params.talent_point
	self.page_id = self.m_params.page_id
	self.is_cur_text = 1
	self:getData("guild_high_war_learn_point_num",{point = self.m_point_data.point_id})
end

function M:onEnter()
	--Logger.logError(self.m_data, "----------巅峰--")
	self.m_num = self.m_data.num or 0
end

function M:getCurDataByPointId(id)
	for k,v in pairs(self.talent_point) do
		if v.point_id ==id then
			return v
		end
	end
	return nil
end

function M:getCurMaxPointData(id)
	local cfg = ConfigManager:getCfgByName("talent_point")
	local data = cfg[id]
	for k,v in pairs(data) do
		if v.level == v.level_max then
			return v
		end
	end
	return nil
end

return M
