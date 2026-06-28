local M = class("GuildHighWarThreeWorldModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("")
end

function M:onEnter()
	--Logger.logError(self.m_data, "----------巅峰--")

end

function M:getTalentDataById(id)
	local cfg = ConfigManager:getCfgByName("talent_point")
	if cfg then
		for k,v in pairs(cfg) do
			if tonumber(k) == id then
				return v
			end
		end
	end
	return nil
end

return M
