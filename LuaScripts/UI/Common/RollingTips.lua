--- 信息查看
local M = class("RollingTips",LikeOO.OOUIbase)

M.m_uiName = "Common/RollingTips"
M.m_sortOrder = 9999
M.m_queue = {}

function M:onCreate()
	self.m_content = self:findGameObject("content")
	self.bg_width = self.m_content:GetComponent("RectTransform").rect.width
	self.m_content:SetActive(false)
	self.des_text = self:findGameObject("des_text")
	self.m_position = self.des_text:GetComponent("RectTransform").localPosition
end

function M:addTips(data)
	table.insert(self.m_queue, data)
end

function M:getTips()
	local data = self.m_queue[1]
	table.remove(self.m_queue, 1)
	return data
end

function M:onEnter()
	UIUtil.setLocalPosition(self.des_text.transform, self.bg_width*0.5)
	local sequence = Tweening.DOTween.Sequence()
	sequence:AppendInterval(self.m_params.delay_open or 0.1)
	sequence:OnComplete(function()
		self.m_delay_open_sequence = nil
		self.m_content:SetActive(true)
		self:refreshUI() 
	end)
	sequence:SetAutoKill(true)

end

function M:refreshUI()
	self:doTipsMove()
end

function M:doTipsMove()
	UIUtil.setLocalPosition(self.des_text.transform, self.bg_width*0.5)
	local text = self:getTips()
	if text then
		self:setText("des_text", text)
		self.des_text:GetComponent('ContentSizeFitter'):SetLayoutHorizontal();
		local width = self.des_text:GetComponent("RectTransform").rect.width
		local speed = 100
		local sequence = Tweening.DOTween.Sequence()
		sequence:Append(self.des_text.transform:DOLocalMoveX(- width - self.bg_width*0.5, (width + self.bg_width)/speed):SetEase(Tweening.Ease.Linear))
		sequence:OnComplete(function()
			self.m_tips_sequence = nil
			self:refreshUI()
		end)
		sequence:SetAutoKill(true)
		self.m_tips_sequence = sequence
	else
		self:destroy()
	end
end

function M:destroy()
	if self.m_delay_open_sequence then
		self.m_delay_open_sequence:Kill()
		self.m_delay_open_sequence = nil
	end

	if self.m_tips_sequence then
		self.m_tips_sequence:Kill()
		self.m_tips_sequence = nil
	end
	
	M.super.destroy(self)
end

return M