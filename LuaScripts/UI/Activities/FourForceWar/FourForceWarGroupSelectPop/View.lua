local M = class("FourForceWarGroupSelectPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/FourForceWar/FourForceWarSelectPop"
M.m_size_type = 2

function M:onEnter()
	local cfg = self.m_model:getLiteratureCfg()
	if cfg then
		local text_table = string.split(cfg.dec, ",") or {}
		self:setTextByLanKey("tips_text_1", text_table[1] or "")
		self:setTextByLanKey("tips_text_2", text_table[2] or "")
		self:setTextByLanKey("text_1","enjoySpring_str_0036")
		local icon = self:findGameObject("icon_img")
		GameUtil:updateResourcesImg(icon,"Texture/EnjoySpring/" .. cfg.icon)
		local num = self.m_model:getGroupPeopleCount()
		local num_des, num_color = self.m_model:getNumsDesByNums(num)
		self:setTextByLanKey("num_text", num_des)
		self:setTextColor("num_text", num_color)
		local word = string.cutText(Language:getTextByKey(cfg.name))
		--for k=1, 2 do
		--	self:setText("name_" .. k, word[k] or "")
		--end
		self:updateListScroll()
	end
end

function M:updateListScroll()
	local data = self.m_model:getRewardList()
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				GameUtil:updateItemElement(cell_object, cell_data,true, true)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

return M