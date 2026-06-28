local M = class("ItemDetailModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_show_data = self.m_params.show_data
	self.m_cost = self.m_params.cost
	self.m_use_num = self:getMaxNum()
	self.m_ok_call_func = self.m_params.ok_call_func
	self.m_display = self.m_params.display
	self.m_show_buy_btn = self.m_params.show_buy_btn
	if self.m_show_buy_btn == nil then
		self.m_show_buy_btn = true
	end
	self.m_isToday = self.m_params.isToday
	self.m_today_text = self.m_params.today_text or Language:getTextByKey("new_str_0910")
	self.m_today_btn_value = self.m_params.today_btn_value
end

function M:addUseNum(value)
	local new_count = self.m_use_num + value
	self.m_use_num = math.min(math.max(1,new_count),self:getMaxNum())
end

function M:getMaxNum()
	local max_num = self.m_show_data.user_num
	local item_cfg = self.m_show_data.item_cfg or {}
	if item_cfg.type == 12 then --双倍充值券
		local item_id = self.m_show_data.data_id
		local item_data = UserDataManager.item_data:getItemDataById(item_id)
		max_num = math.floor(item_data.value/item_cfg.effect)
	else
		if item_cfg.use_num and item_cfg.use_num > 0 then
			max_num = math.floor(max_num/item_cfg.use_num)
		end
	end
	return max_num
end

function M:getTempStr()
	local temp_str = ""
	if self.m_show_data.data_type == 103 and self.m_show_data.item_cfg.type == 18 then
		local min_num, change_lv = self:getMinLv()
		local sub_type_name = Language:getTextByKey('tid#haoganleixingname_'..self.m_show_data.item_cfg.sub_type)
		if change_lv > 0 then
			temp_str = Language:getTextByKey("tid#haogandutips_3", sub_type_name, min_num).."\n"..Language:getTextByKey("tid#haogandutips_5", change_lv)
		else
			temp_str = Language:getTextByKey("tid#haogandutips_3", sub_type_name, min_num)
		end
	end
	return temp_str
end

function M:getMinLv()
	local tab = {}
	for k,v in pairs(self.m_show_data.item_cfg.effect) do
		table.insert(tab, {lv = v[1], num =v[2]})
	end
	local init_num = tab[1].num or 0
	table.sort(tab, function(data1, data2)
		return data1.lv < data2.lv
	end)
	for i = 1, #tab do
		if tab[i].num < init_num then
			return init_num, tab[i].lv
		end
	end
	return init_num, 0
end


function M:getUseNum()
	return self.m_use_num
end

--- 网络数据回调，需要复写
function M:netData(data, tag)
	local item_id = self.m_show_data.data_id
	local item_data = UserDataManager.item_data:getItemDataById(item_id)
	self.m_show_data.user_num = item_data.num
	self.m_use_num = self:getMaxNum()
end

return M
