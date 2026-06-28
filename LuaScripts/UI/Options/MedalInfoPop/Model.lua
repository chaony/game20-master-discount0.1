local M = class("MedalInfoPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_medalId = self.m_params.id or 101 	
	self.m_isWear = self.m_params.isWear or false
	self.m_lookSelf = self.m_params.lookSelf or false
	self.m_overTimer = UserDataManager:getMedalDataById(self.m_medalId) or -1
	self.m_medalXlsxData = ConfigManager:getMedalCfgById(self.m_medalId)
end

-- 获取格式化功勋基础属性
--function M:getFormatMedalAttr()
--	local base_attrs = {} 
--	local idle_attrs = {}
--	local attr_list = {}
--	local sort_attrs = {} -- 筛选为两两一组
--	idle_attrs = {table.copy(self.m_medalXlsxData.idle)} or {}
--	local moneyXlsxData = ConfigManager:getCfgByName("money_guide")
--	--for _, v in pairs(idle_attrs) do
--	--	local moneyId = v[1]
--	--	local moneyName = moneyXlsxData[moneyId].name
--	--	moneyName = Language:getTextByKey("moneyName")
--	--	table.insert(attr_list, {itemType = 1, attr = {moneyName, v[2]}})
--	--end
--	base_attrs = table.copy(self.m_medalXlsxData.attr) or {}
--	base_attrs = UserDataManager:appendAttrs(base_attrs) -- 属性id转换成key
--	for i, v in pairs(base_attrs) do
--		table.insert(attr_list, {i, v})
--	end
--	for i = 1, math.ceil(#attr_list/2) do
--		table.insert(sort_attrs,{itemType = 2, attr = {attr_list[i*2-1],attr_list[i*2]}})
--	end
--	return sort_attrs
--end

return M
