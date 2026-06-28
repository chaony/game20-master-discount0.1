local M = class("NewFuncOpenModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open_func_ids = self.m_params.open_func_ids or {}
	self.m_callback = self.m_params.callback
	local first_func_id = self.m_open_func_ids[1]
	if first_func_id then
		local open_condition_cfg = ConfigManager:getCfgByName("open_condition")
		local open_condition_cfg_item = open_condition_cfg[first_func_id]
		self.m_first_func_cfg = open_condition_cfg_item
	end
	self.m_function_id = first_func_id
end

function M:getFirstOpenFuncCfg()
	return self.m_first_func_cfg
end

return M
