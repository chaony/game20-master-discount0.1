local M = class("WorldMemoryAttrPopView",LikeOO.OOPopBase)

M.m_uiName = "WorldMapNew/WorldMapOldMemory/WorldMemoryAttrPop"
M.m_size_type = 2

function M:onEnter()
	
	self:refreshUI()
end

function M:refreshUI()
	local attr_list = self.m_model:getAttrListData()
	for i = 1, 5 do
		local slider = self:findSlider("active_point_slider"..i)
		local obj = self:findGameObject("active_point_slider"..i)
		local luaBehaviour = UIUtil.findLuaBehaviour(obj)
		local attr_name = luaBehaviour:FindText("attr_name")
		local lv_name = luaBehaviour:FindText("lv_name")
		local next_lv_name = luaBehaviour:FindText("next_lv_name")
		local exp_text = luaBehaviour:FindText("exp_text")
		if attr_list[i] then
			local attrData = attr_list[i]
			slider.value = attrData.exp / attrData.need_exp
			attr_name.text = Language:getTextByKey(attrData.name)
			lv_name.text = Language:getTextByKey(attrData.name_lv)
			next_lv_name.text = Language:getTextByKey(attrData.next_name_lv)
			if attrData.need_exp == 1 then
				exp_text.text = Language:getTextByKey("world_memory_str_003")
			else
				exp_text.text = tostring(attrData.exp).. "/" .. tostring(attrData.need_exp)
			end
		end
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M