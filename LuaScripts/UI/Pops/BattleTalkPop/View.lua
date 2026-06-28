local M = class("BattleTalkPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/BattleTalkPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("name_text", "legend_str_020")
	self.talk_list = self:findRectTransform("talk_list")
	self.item_list = {}

	--self:refreshUI()
	self:refreshUISingle()
end

function M:refreshUI()
	self.m_control:removeTimer(self.timer)
	
	local cfg = self.m_model:getNextId()
	local item = nil
	if cfg ~= nil then
		item = ResourceUtil:GetUIItem("Pops/player_talk_item", self.talk_list.gameObject, "ui_prefabs");
		local luaBehaviour = item:GetComponent("LuaBehaviour")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "talk_text", cfg.des)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "kuang_jiao", true)
		item = item:GetComponent("RectTransform")
		item.localScale = Vector3.New(0,0,0)
		item.anchoredPosition3D = Vector2.New(130,60, 0)
		local item_sequence = Tweening.DOTween.Sequence()
		item_sequence:Append(item:DOScale(1.2, 0.4):SetEase(Tweening.Ease.Linear))
		item_sequence:Append(item:DOScale(1, 0.1):SetEase(Tweening.Ease.Linear))
	end
	
	if cfg ~= nil or table.nums(self.item_list) > 0 then
		local sequence = Tweening.DOTween.Sequence()
		local isAppend = false
		if self.item_list[1] ~= nil then
			local jiao = self.item_list[1]:Find("kuang_jiao")
			jiao.gameObject:SetActive(false)
		end
		for id,item in pairs(self.item_list) do
			if isAppend == false then
				isAppend = true
				sequence:Append(DOTweenModuleUI.DOAnchorPosY(item, 60 + id * 118, 0.4):SetEase(Tweening.Ease.Linear))
			else
				sequence:Insert(DOTweenModuleUI.DOAnchorPosY(item, 60 + id * 118, 0.4):SetEase(Tweening.Ease.Linear), 0)
			end
		end
		sequence:OnComplete(function()
			local last_index = 0
			for i = 3, 1, -1 do
				if self.item_list[i] ~= nil then
					self.item_list[i+1] = self.item_list[i]
					last_index = i
				end
			end
			self.item_list[last_index] = nil

			self.item_list[1] = item
			if self.item_list[4] ~= nil then
				ResourceUtil:ReturnItem(self.item_list[4].gameObject)
				self.item_list[4] = nil
				if table.nums(self.item_list) == 0 then
					self:updateMsg(99999)
					return
				end
			end
			local time = 3
			if cfg ~= nil then
				time = cfg.time
			end
			self.timer = self.m_control:setOnceTimer(time, function() self:refreshUI() end)
		end)
	else
		self:updateMsg(99999)
	end
end

function M:refreshUISingle()
	self.m_control:removeTimer(self.timer)

	local cfg = self.m_model:getNextId()
	if cfg ~= nil then
		self:setTextByLanKey("talk_text", cfg.des)
		local time = 3
		if cfg ~= nil then
			time = cfg.time
		end
		self.timer = self.m_control:setOnceTimer(time, function() self:refreshUISingle() end)
	else
		self:updateMsg(99999)
	end
end

function M:destroy()
	self.m_control:removeTimer(self.timer)
	for id,item in pairs(self.item_list) do
		ResourceUtil:ReturnItem(item.gameObject)
	end
	self.item_list = {}
	M.super.destroy(self)
end
return M