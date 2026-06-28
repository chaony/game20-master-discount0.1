local M = class("OptionsTitleUpgradeModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_old_title_id = self.m_params.old_title_ID
	self.m_new_title_id = self.m_params.new_title_ID
end

-- 通过id获取称号配置
function M:getTitleCfgById(title_id)
	title_id = tonumber(title_id)
	local title_cfg = ConfigManager:getCfgByName("title") or {}
	local cfg = {}
	if title_cfg[title_id] then
		cfg = title_cfg[title_id]
		cfg.id = title_id
	else
		Logger.logWarningAlways("title表里没有找的"..title_id)
	end
	return cfg
end

-- 称号收集属性
function M:getTitleCollectAttrById(title_id)
	local attr = {}
	local title_cfg = ConfigManager:getCfgByName("title") or {}
	if title_cfg[title_id] then
		attr = title_cfg[title_id].attr1
	else
		Logger.logWarningAlways("title表里没有找的"..title_id)
	end
	return attr
end

-- 称号佩戴属性
function M:getTitleWearAttrById(title_id)
	local attr = {}
	local title_cfg = ConfigManager:getCfgByName("title") or {}
	if title_cfg[title_id] then
		attr = title_cfg[title_id].attr2
	else
		Logger.logWarningAlways("title表里没有找的"..title_id)
	end
	return attr
end

return M
