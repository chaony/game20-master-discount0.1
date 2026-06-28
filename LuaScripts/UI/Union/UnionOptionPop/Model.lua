local M = class("UnionOptionModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.guild or {}
end

function M:setEmblem(emblem)
	self.m_data.flag = emblem
end

function M:changeTypeValue(value)
	self.m_data.apply = self.m_data.apply + value
	if self.m_data.apply < 1 then
		self.m_data.apply = 3
	elseif self.m_data.apply > 3 then
		self.m_data.apply = 1
	end
end

function M:changeLevelValue(value)
	local v = ConfigManager:getCommonValueById(211)
	self.m_data.apply_lv = math.min(math.max(self.m_data.apply_lv + value, v[1]),v[2])
end

return M
