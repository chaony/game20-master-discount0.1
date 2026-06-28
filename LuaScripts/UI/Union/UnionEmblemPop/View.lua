local M = class("UnionEmblemView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionEmblemPop"
M.m_size_type = 2

function M:onEnter()	
	self:setTextByLanKey("cancle_text", "new_str_0007")
	self:setTextByLanKey("ok_text", "new_str_0006")
	self:setTextByLanKey("common_title_text", "union_str_1022")
	self:setTextByLanKey("tips_text", "union_str_1023")

	if self.m_model.m_guild then
		self:setText("lv_text", Language:getTextByKey("union_str_1025") .. self.m_model.m_guild.level)
	else
		self:setTextByLanKey("lv_text", "union_str_1024")
	end
	self.gray_img = self:findImage("gray_img")
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
	local data = self.m_model.m_list_data
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				if index%8 == 0 then
					cell_object:SetActive(false)
				else
					cell_object:SetActive(true)	
					self:listHandle(cell_object, cell_data.id, cell_data)
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, index)
			end,
			ui_name = self.m_uiName
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data,true)
	end
end

function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local select_img = luaBehaviour:FindGameObject("select_img")
	local icon_img = luaBehaviour:FindImage("icon_img")
	local have_bg = luaBehaviour:FindImage("have_bg")
	local cell_btn = luaBehaviour:FindGameObject("cell_btn")
	if data.kong == true then
		have_bg.gameObject:SetActive(false)
		select_img.gameObject:SetActive(false)
		icon_img.gameObject:SetActive(false)
		cell_btn:SetActive(false)
	else
		select_img:SetActive(self.m_model.m_select == id)
		have_bg.gameObject:SetActive(true)
		icon_img.gameObject:SetActive(true)
		cell_btn:SetActive(true)
		--LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", data.icon, "maze_stage_ui")
		GameUtil:updateResourcesImg(icon_img, "Texture/union_emblem/" .. data.icon)
		if self.m_model.m_select == id then
			icon_img.material = nil
		else
			if self.m_model.m_lv < data.unlock_level then
				icon_img.material = self.gray_img.material
			else
				icon_img.material = nil
			end
		end
	end
end

return M