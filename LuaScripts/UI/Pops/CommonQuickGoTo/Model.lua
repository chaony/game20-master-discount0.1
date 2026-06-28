local M = class("CommonQuickGoToModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_item_data = self.m_params.item_data
end

function M:getShowData()
	local show_data = {}
	local go_type = self.m_item_data.money_guide_cfg.go_type or {} -- 产出途径(有跳转)
	if self.m_item_data.money_guide_cfg.itype == 2 then
		go_type = self.m_item_data.item_cfg.go_type or {}
	end
	local jump = ConfigManager:getCfgByName("jump")
	for k,v in ipairs(go_type) do
		local jump_item = jump[v]
		if jump_item then
			local open_condition_id = jump_item.open_condition_id or 0
			local cfg = BtnOpenUtil:getBtnCfg(open_condition_id)
			local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_condition_id, cfg)
			table.insert(show_data, {id = v, open_flag = open_flag, tips_str = tips_str, cfg = cfg, sort_id = open_flag and 1 or 2})
		end
	end
	table.sort(show_data, function(data1, data2) 
		return data1.sort_id < data2.sort_id
	end)
	return show_data
end

return M
