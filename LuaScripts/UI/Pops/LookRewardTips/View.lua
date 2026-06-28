local M = class("LookRewardTipsView",LikeOO.OOPopBase)

M.m_uiName = "Pops/LookRewardTips"
M.m_size_type = 2

function M:onEnter()
	self.m_reward_content = self:findGameObject("reward_content")
	self.m_reward_bg = self:findGameObject("reward_bg")
	self.m_look_cards_node = self:findGameObject("look_cards_node")
	self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_look_model == 0 then
		local scale = self.m_model.m_scale
		UIUtil.setScale(self.m_reward_bg.transform, scale, scale)
		self.m_reward_bg:SetActive(true)
		self.m_look_cards_node:SetActive(false)
		local num = math.min(6,#self.m_model.m_rewards)
		for i = 1, num do
			local data = self.m_model.m_rewards[i]
			local item, ui_element = GameUtil:createItemElement(data, true, true)
			if self.m_model.m_show_check_mark then
				ui_element.duigoudi_img:SetActive(true)
			else
				ui_element.duigoudi_img:SetActive(false)
			end
			local luaBehaviour = UIUtil.findLuaBehaviour(item)
			if self.m_model.m_tips then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"tips_img", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"tips_text", self.m_model.m_tips)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"tips_img", false)
			end
			item.transform:SetParent(self.m_reward_content.transform, false)
		end
		if self.m_model.m_click_transform then
			local pos = self.m_reward_bg.transform.parent:InverseTransformPoint(self.m_model.m_click_transform.position)
			local click_transform_h = self.m_model.m_click_transform.rect.height
			local content_w,content_h = num*100+20, self.m_reward_bg.transform.rect.height
	        pos.y = pos.y + content_h*0.5 + click_transform_h*0.5 + self.m_model.m_offset_y
	        local width,height = self.m_rt.rect.width, self.m_rt.rect.height
			if UserDataManager.client_data.is_iphonex == true then
				width = width - (GlobalConfig.UI_LEFT_OFFSET_X*2)
			end
	        pos.y = math.max(math.min(pos.y,height*0.5 - content_h*0.5), - height*0.5)
			local scene_max = math.min(pos.x,width*0.5 - content_w*0.5)
	        pos.x = math.max(scene_max, - width*0.5 + content_w*0.5)
			self.m_reward_bg.transform.localPosition = pos
		end
	else
		self:setTextByLanKey("title_text", "new_str_0097")
		self.m_reward_bg:SetActive(false)
		self.m_look_cards_node:SetActive(true)
		self:updateLoopScroll()
	end
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model.m_rewards or {}
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	GameUtil:updateItemElement(cell_object, data, false, false, nil)
end

return M