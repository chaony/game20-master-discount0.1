local M = class("RecruitPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/Recruit/RecruitPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setText("close_title_text", "")
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 2})
	self.m_btns = {}
	for i=1,5 do
		self.m_btns[i] = self:findButton(string.format("day_%d_btn",i))
		UIUtil.setTextByLanKey(self.m_btns[i].transform, "Text", "day_str_" .. i)
		self.m_btns[i].interactable = self.m_model.m_open_day >= i
		local lock_img = self:findGameObject("lock_img_" .. i)
		lock_img:SetActive(self.m_model.m_open_day < i)
		local color = self.m_model.m_open_day < i and Color(0.5,0.5,0.5,1) or Color(1,1,1,1)
		local btn_img = self:findImage(string.format("day_%d_btn",i))
		btn_img.color = color
	end
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
	self:refreshRedPoint()
end

function M:updateListScroll()
	local data = self.m_model:getListData()
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

function M:listHandle(obj, id, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local reward_content = luaBehaviour:FindGameObject("reward_content")
	local slider = luaBehaviour:FindSlider("slider")
	local receive_btn = luaBehaviour:FindButton("receive_btn")
	local name_text = luaBehaviour:FindText("name_text")
	local slider_text = luaBehaviour:FindText("slider_text")
	slider_text.text = tostring(data.data.value) .. "/" .. data.cfg.target_value
	slider.value = data.data.value/data.cfg.target_value
	local status = self.m_model:getStatus(id)
	receive_btn.interactable = status == 1
	if status == 0 then
		UIUtil.setTextByLanKey(receive_btn.gameObject.transform, "Text", "new_str_0057")
	elseif status == 1 then
		UIUtil.setTextByLanKey(receive_btn.gameObject.transform, "Text", "new_str_0056")
	else
		UIUtil.setTextByLanKey(receive_btn.gameObject.transform, "Text", "new_str_0080")
	end
	GameUtil:createRewards(reward_content.transform, data.cfg.reward, true, true, nil, nil, true)
	name_text.text = Language:getTextByKey(data.cfg.name)
end

function M:refreshRedPoint()
	for k,v in pairs(self.m_btns) do
		local bl = self.m_model.red_point[k]
		local red_point = UIUtil.findImage(v.transform, "red_point")
		red_point.gameObject:SetActive(bl)
	end
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M