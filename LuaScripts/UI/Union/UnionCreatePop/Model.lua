local M = class("UnionCreateModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_emblem = 1
	self.m_apply = 1
	self.common_value = ConfigManager:getCfgByName("common")[211].value
	self.m_apply_lv = self.common_value[1]
	self.m_on_ok_call = self.m_params.on_ok_call
	self.m_cost = ConfigManager:getCfgByName("system_cost")[1].cost[1]
end

function M:setEmblem(emblem)
	self.m_emblem = emblem
end

function M:changeTypeValue(value)
	self.m_apply = self.m_apply + value
	if self.m_apply < 1 then
		self.m_apply = 3
	elseif self.m_apply > 3 then
		self.m_apply = 1
	end
end

function M:changeLevelValue(value)
	self.m_apply_lv = math.min(math.max(self.m_apply_lv + value, self.common_value[1]),self.common_value[2])
end

return M
