local M = class("WindAndCloudMainView",LikeOO.OOPopBase)

M.m_uiName = "WindAndCloud/WindAndCloudMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
 	self.m_gray_material = self:findText("material_node").material
	if self.m_model.active_data then
		self:setTextByLanKey("close_title_text", self.m_model.active_data.name)
	end
	local items = self.m_model:getAllItem()
	for k, v in pairs(items) do
		local show_active_data = self.m_model:getActiveData(v.open_id)
		if show_active_data then
			self:setTextByLanKey(v.btn_name .. "_text", show_active_data.name)
		end
	end
	self:refreshUI()
end

function M:refreshUI()
	--self:refreshRedPoint()
	self:refreshRedPoint()
	self:refreshTimeLimit()
end

function M:refreshRedPoint(flag)
	local items = self.m_model:getAllItem()
	for k, v in pairs(items) do
		if v.open_id == 407 then
			local active_data = UserDataManager:getActivesDataByOpenId(407)
			if active_data then
				local function netCallback(response)
					local states = response.status or 0
					local falg = states == 1 or RedPointUtil:hasRedPointById(v.open_id)
					self:setObjectVisible(v.btn_name .. "_red_point_img", falg and self.m_model:getItemTimeLimit(v.btn_name) == 1)
				end
				local params = {}
				params.open_id = active_data.open_id
				params.vsn = active_data.version
				self.m_model:getNetData("redbag_red_dot", params, netCallback)
			else
				self:setObjectVisible(v.btn_name .. "_red_point_img", false)
			end
		else
			self:setObjectVisible(v.btn_name .. "_red_point_img", RedPointUtil:hasRedPointById(v.open_id) and self.m_model:getItemTimeLimit(v.btn_name) == 1)
		end
		--特殊处理名扬四海
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
			--btn_img.material = self.m_gray_material
			--btn_text.material = self.m_gray_material
		else --未开启
			--self:setObjectVisible(v.btn_name, false)
		end
	end
end

return M