---@class LookInfoTips:OOUIbase
--- 信息查看
local M = class("LookInfoTips",LikeOO.OOUIbase)

M.m_uiName = "Common/LookInfoTips"
M.m_sortOrder = 19999

function M:onCreate()
	self.m_content = self:findGameObject("content")
	self.m_content:SetActive(false)
	self.finish = self.m_params.finish
	local delay_open = self.m_params.delay_open or 0.1
	local delay_close = self.m_params.delay_close or 0
	local bg_type = self.m_params.bg_type or 1
	self.m_text_anchor_value = self.m_params.text_anchor_value
	if bg_type == 1 then
		self:setImg("a_ui_currency_tips", "common_ui", "content")
	elseif bg_type == 2 then
		self:setImg("a_map_jq_tips", "common_ui", "content")
	end
	if delay_close > 0 then
		local sequence = Tweening.DOTween.Sequence()
		sequence:AppendInterval(delay_open + delay_close)
		sequence:OnComplete(function()
			self.m_delay_close_sequence = nil
			self:destroy()
		end)
		sequence:SetAutoKill(true)
		self.m_delay_close_sequence = sequence
		self:setObjectVisible("close_btn", false)		
	end
end

function M:setParent(parent)
	if static_root_node then
		self.m_rootView.transform:SetParent(static_root_node.transform, false)
	end
end

function M:onButtonClick(obj, name)
	if name == "close_btn" then
		self:destroy()
	elseif name == "goto_btn" then
		if self.m_params.callback then
			self.m_params.callback()
			self:destroy()
		end
	end
end

function M:onEnter()
	local sequence = Tweening.DOTween.Sequence()
	sequence:AppendInterval(self.m_params.delay_open or 0.1)
	sequence:OnComplete(function()
		self.m_delay_open_sequence = nil
		self:refreshUI() 
	end)
	sequence:SetAutoKill(true)
	self.m_delay_open_sequence = sequence
end

function M:refreshUI()
	self.m_content:SetActive(true)
	if self.m_params.title then
		self:setObjectVisible("title_text", true)
		self:setObjectVisible("title_line_img", true)
		self:setTextByLanKey("title_text", self.m_params.title)
	else
		self:setObjectVisible("title_text", false)
		self:setObjectVisible("title_line_img", false)
	end

	if self.m_params.btn_text then
		self:setObjectVisible("goto_btn", true)
		self:setObjectVisible("goto_line_img", true)
		self:setTextByLanKey("goto_btn_text", self.m_params.btn_text)
	else
		self:setObjectVisible("goto_btn", false)
		self:setObjectVisible("goto_line_img", false)
	end
	if self.m_params.fh_num then
		self:setObjectVisible("show_yb_line_img", true)
		self:setObjectVisible("show_yb_obj", true)
		self:setTextByLanKey("show_fh_num", self.m_params.fh_num)
		self:setTextByLanKey("show_fh", "bounty_str_0021")
	else
		self:setObjectVisible("show_yb_obj", false)	
		self:setObjectVisible("show_yb_line_img", false)
	end
	if self.m_params.status_text then
		self:setObjectVisible("status_text", true)
		self:setObjectVisible("status_line_img", true)
		self:setTextByLanKey("status_text", self.m_params.status_text)
	else
		self:setObjectVisible("status_text", false)
		self:setObjectVisible("status_line_img", false)
	end
	local msg = "???"
	if self.m_params.data then
		local item_data = RewardUtil:getProcessRewardData(self.m_params.data)
		msg = item_data.story
	else
		msg = self.m_params.msg or msg
	end
	self.m_des_text = self:setTextByLanKey("des_text", msg)
	if self.m_text_anchor_value then
		local text_anchor = U3DUtil:Get_TextAnchor(self.m_text_anchor_value)
		if text_anchor then
			self.m_des_text.alignment = text_anchor
		end
	end
	self.m_click_transform = self.m_params.click_transform
	if self.m_click_transform then
		local pos = self.m_content.transform.parent:InverseTransformPoint(self.m_click_transform.position)
		local click_transform_h = self.m_click_transform.rect.height
		local click_transform_w = self.m_click_transform.rect.width
		local content_w,content_h = 360, self.m_des_text.preferredHeight + 20
		if self.m_params.top == true then
			pos.y = pos.y + content_h*0.5 + click_transform_h*0.5
		elseif self.m_params.right == true then
			pos.x = pos.x + content_w*0.5 + click_transform_w*0.5
		else
        	pos.y = pos.y - content_h*0.5 - click_transform_h*0.5
		end
        local width,height = self.m_rt.rect.width, self.m_rt.rect.height
        pos.y = math.max(math.min(pos.y ,height*0.5 - content_h*0.5), - height*0.5)
        pos.x = math.max(math.min(pos.x ,width*0.5 - content_w*0.5), - width*0.5 + content_w*0.5) 
		self.m_content.transform.localPosition = pos
	end
	
	self.m_pos_offset = self.m_params.pos_offset
	if self.m_pos_offset then
		self.m_content.transform.localPosition = self.m_content.transform.localPosition + self.m_pos_offset
	end

	local delay_close = self.m_params.delay_close or 0
	if delay_close > 0 then
		local sequence = Tweening.DOTween.Sequence()
		sequence:AppendInterval(0.5)
		sequence:Append(self.m_content.transform:DOLocalMoveY(180,delay_close - 0.5))
		sequence:SetAutoKill(true)
		self.m_move_sequence = sequence
	end
end

function M:destroy()
	if self.m_delay_close_sequence then
		self.m_delay_close_sequence:Kill()
		self.m_delay_close_sequence = nil
	end
	if self.m_delay_open_sequence then
		self.m_delay_open_sequence:Kill()
		self.m_delay_open_sequence = nil
	end
	if self.m_move_sequence then
		self.m_move_sequence:Kill()
		self.m_move_sequence = nil
	end
	if self.finish ~= nil then
		self.finish()
	end
	M.super.destroy(self)
	GameUtil:resetLookInfoTips()
end

return M