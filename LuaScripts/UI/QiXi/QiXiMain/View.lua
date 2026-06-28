local M = class("QiXiMainView",LikeOO.OOPopBase)

M.m_uiName = "QiXi/QiXiMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
 	self.m_gray_material = self:findText("material_node").material
	local active_data = self.m_model:getActiveData() or {}
	self:setText("close_title_text", active_data.name or "")
	local items = self.m_model:getAllItem()
	for k, v in pairs(items) do
		local itemData = self.m_model:getItemData(v.btn_name) or {}
		self:setText(v.btn_name .. "_text", itemData.name or "")
	end
	self:refreshUI()
end

function M:refreshUI()
	self:refreshRedPoint()
	self:refreshTimeLimit()
end

function M:refreshRedPoint()
	local items = self.m_model:getAllItem()
	for k, v in pairs(items) do
		self:setObjectVisible(v.btn_name .. "_red_point_img", RedPointUtil:hasRedPointById(v.open_id) and self.m_model:getItemTimeLimit(v.btn_name) == 1)
	end
end

function M:refreshTimeLimit()
	local items = self.m_model:getAllItem()
	for k, v in pairs(items) do
		local time_limit = self.m_model:getItemTimeLimit(v.btn_name)
		if time_limit == 1 then --活动期
			self:setObjectVisible(v.btn_name, true)
		elseif time_limit == 2 then --展示期，置灰
			local btn_img = self:findImage(v.btn_name)
			local btn_text = self:findText(v.btn_name .. "_text")
			btn_img.material = self.m_gray_material
			btn_text.material = self.m_gray_material
		else --未开启
			self:setObjectVisible(v.btn_name, false)
		end
	end
end

return M