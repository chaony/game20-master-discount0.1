local M = class("MysticSelectPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_pos = self.m_params.slot_id
	self.m_oid = self.m_params.oid
	self.m_callfunc = self.m_params.callback
	local mystic_ids = UserDataManager.mystic_data:getMysticesId()
	local mystices = {}
	local solt_type = {0,1,2,3,4}
	for i,v in ipairs(mystic_ids) do
		local data, cfg = UserDataManager.mystic_data:getMysticDataById(v)
		local oneCfg = cfg[data.evo]
		if data.is_active ~= 1 then
			if solt_type[self.m_pos] == 0 or solt_type[self.m_pos] == oneCfg.type then
				mystices[#mystices + 1] = v
			end
		end
	end
	self.m_mystices = mystices
	self.m_select = mystices[1]
end

function M:getMysticDataByIndex(index)
	return self.m_mystices[index]
end

function M:setSelectHero(oid)
	self.m_select = oid
end

return M
