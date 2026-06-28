local M = class("WorldMemoryAttrPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.attr_list = UserDataManager:getNewMapAttrsData()
end

--获取属性配置
function M:getAttrConfigById(group, id)
	if not id then return end
	local new_regional_attr_cfg = ConfigManager:getCfgByName("new_regional_attr")
	for i, v in pairs(new_regional_attr_cfg) do
		for m, n in pairs(v) do
			if i == group and m == id then
				return n
			end
		end
	end
	return {}
end

function M:getAttrListData()
	local group_data_list = {}
	for i, v in pairs(self.attr_list) do
		local attr_cfg = self:getAttrConfigById(tonumber(i), v.id)
		local need_attr_cfg = self:getAttrConfigById(tonumber(i), attr_cfg.next)
		if attr_cfg.next and attr_cfg.next ~= 0 then
			group_data_list[tonumber(i)] = {id = v.id, name = attr_cfg.name, name_lv = attr_cfg.name_lv,
								  next_name_lv = need_attr_cfg.name_lv, need_exp = attr_cfg.exp, exp = v.exp}
		else
			group_data_list[tonumber(i)] = {id = v.id, name = attr_cfg.name, name_lv = attr_cfg.name_lv,
								  next_name_lv = "", need_exp = 1, exp = 1}
		end
		
	end
	return group_data_list
end

return M
