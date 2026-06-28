local M = class("TitleDetailModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_show_data = self.m_params.show_data
	self.m_cost = self.m_params.cost
	self.m_ok_call_func = self.m_params.ok_call_func
	self.m_display = self.m_params.display
	self.m_show_buy_btn = self.m_params.show_buy_btn
	self.m_look_model = self.m_params.look_model
	if self.m_show_buy_btn == nil then
		self.m_show_buy_btn = true
	end
	self.m_isToday = self.m_params.isToday
	self.m_today_text = self.m_params.today_text or Language:getTextByKey("new_str_0910")
	self.m_today_btn_value = self.m_params.today_btn_value
end


-- 获取格式化称号属性
function M:getFormatTitleCollectAttrByAttr(attr)
	if not attr then return {} end
	local base_attrs = {} -- 基础属性
	local attr_list = {}
	local sort_attrs = {} -- 筛选为两两一组
	base_attrs = table.copy(attr) or {}
	base_attrs = UserDataManager:newAppendAttrs(base_attrs) -- 属性id转换成key
	for i, v in pairs(base_attrs) do
		table.insert(attr_list, {i, v})
	end
	for i = 1, math.ceil(#attr_list/2) do
		table.insert(sort_attrs,{attr_list[i*2-1],attr_list[i*2]})
	end
	return sort_attrs
end

-- 通过id获取称号配置
function M:getTitleCfgById(title_id)
	title_id = tonumber(title_id)
	local title_cfg = ConfigManager:getCfgByName("title") or {}
	local cfg = {}
	if title_cfg[title_id] then
		cfg.id = title_id
		cfg = title_cfg[title_id]
	else
		Logger.logWarningAlways("title表里没有找的"..title_id)
	end
	return cfg
end

function M:getUseNum()
	return self.m_use_num
end

return M
