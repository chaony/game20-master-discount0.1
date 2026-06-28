-------- OOUIbase 单独ui的创建
---@class OOUIbase  @单独ui的创建
local M = class("OOUIbase")

local viewSortOrder = 0
local baseViewSortOrder = 0
local __VIEW_SORT_ORDER_STEP = 1
M.m_iphoneXAdapter = false
M.m_cache_ui_flag = false

function M:ctor(control, params)
	self.m_control = control or static_rootControl
	self.m_params = params or {}
	self.m_model = self.m_control.m_model
	self:create()
	self:onEnter()
	self:runOpenAnim(self.content_node, function()
	end)
end

function M:create()
	viewSortOrder = viewSortOrder + __VIEW_SORT_ORDER_STEP
	if self.m_uiName then
		self.m_rootView = ResourceUtil:GetUIItem(self.m_uiName, self.m_control.m_view.m_rootView, "ui_prefabs")
		self.m_luaBehaviour = self.m_rootView:GetComponent("LuaBehaviour")
		local canvas = self.m_rootView:GetComponent("Canvas")
		self.m_sortOrder = self.m_sortOrder or self.m_control.m_view.m_sortOrder + viewSortOrder
		if not IsNull(canvas) then
			canvas.sortingOrder = self.m_sortOrder % 32768
			canvas.worldCamera = static_ui_camera
		end
		self.m_luaBehaviour:RegistButtonClick(handler(self, self.onButtonClick))
		self.m_luaBehaviour:RegistLanguageChanged(handler(self, self.onLanguageChanged))
		self.m_luaBehaviour:InjectionFunc()
		local screen_shot_rawimg = self:findGameObject("screen_shot_rawimg")
		if not IsNull(screen_shot_rawimg) then
			screen_shot_rawimg:GetComponent("ScreenShot"):ShotScreen()
		end
		local content_node = self:findGameObject("content_node")
		self.content_node = content_node
		--local is_iphonex = UserDataManager.client_data.is_iphonex
		self.m_iphonex_offset_x = self.m_control.m_view.m_iphonex_offset_x or 0
		if self.m_iphoneXAdapter and content_node and self.m_iphonex_offset_x > 0 then
			local rt = content_node:GetComponent("RectTransform")
			rt.offsetMin = Vector2(self.m_iphonex_offset_x, rt.offsetMin.y)
			rt.offsetMax = Vector2(-self.m_iphonex_offset_x, rt.offsetMax.y)
		end
		self.m_rt = self.m_rootView:GetComponent("RectTransform")
		self.m_rt.localPosition = Vector3.zero
		self:setParent(self.m_params.parent)
	else
		Logger.logError(self.__cname .. " ui not found ")
	end
	Logger.log(viewSortOrder, "<color=green>OOUIbase create viewSortOrder</color> : " .. tostring(self.m_uiName))
	self:onCreate()
	return self.m_rootView
end

function M:setOrder(order)
	local canvas = self.m_rootView:GetComponent("Canvas")
	if not IsNull(canvas) then
		canvas.sortingOrder = order % 32768
	end
end

function M:onButtonClick(obj, name)
	self:updateMsg(name, obj)
	local full_btn_name = self.m_uiName .. "/" .. name
	GameUtil:playBtnSound(full_btn_name)
end

function M:onLanguageChanged(mode)
	
end

function M:setParent(parent)
	if not IsNull(self.m_rootView) and not IsNull(parent) then
		self.m_rootView.transform:SetParent(parent.transform, false)
	end
end

function M:onInjectionFunc(obj, name)
	if self[name] == nil then
		self[name] = obj
	else
		Logger.logWarning("name is exist : " .. tostring(name))
	end
end

function M:onCreate()
	
end

function M:onEnter()
	
end

function M:refreshUI()
	
end

--[[
	使用方法，与参数性质同controlBase
]]
function M:updateMsg( msg , data , flag , alias)
	-- body
	if self.m_control then
		self.m_control:updateMsg( msg,data,flag,alias )
	end
end

function M:destroy()
	self:runCloseAnim(self.content_node, function()
		if not IsNull(self.m_rootView) then
			viewSortOrder = viewSortOrder - __VIEW_SORT_ORDER_STEP
			Logger.log(viewSortOrder, "<color=green>OOUIbase destroy viewSortOrder</color> : " .. tostring(self.m_uiName))
			if self.m_cache_ui_flag then
				ResourceUtil:ReturnItem(self.m_rootView)
			else
				U3DUtil:DestroyAndBundle(self.m_rootView, self.m_uiName)
			end
			self.m_rootView = nil
			self.m_luaBehaviour = nil
		end
		self.m_model = nil
		self.m_control = nil
	end)
end

-- 设置粒子特效的order
function M:setParticleRenderOrder(obj, order)
	if self.m_luaBehaviour then
		self.m_luaBehaviour:SetParticleSystemRendererOrder(obj, order or self.m_sortOrder + 1)
	end
end

function M:setText(key, text_msg)
	local text = self:findText(key)
	if text then
		text.text = text_msg
	end
	return text
end

function M:setTextColor(key, color)
	local text = self:findText(key)
	if text then
		text.color = color
	end
	return text
end

function M:setTextByLanKey(key, lan_key, arg1, ...)
	return self:setText(key, Language:getTextByKey(lan_key, arg1, ...))
end

function M:setObjectVisible(key, visible)
	local obj = self:findGameObject(key)
	if obj then
		obj:SetActive(visible)
	end
	return obj
end

function M:setImg(img_msg, img_atlas, key)
	local img = self:findImage(key)
	img.sprite = ResourceUtil:GetSprite(img_msg,img_atlas)
	return img
end

function M:setTexture(key, img_msg, ab_name)
	local img = self:findImage(key)
	if img then
		img.sprite = ResourceUtil:LoadSprite(img_msg, ab_name)
	end
	return img
end

function M:findGameObject(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindGameObject(name)
	end
end

function M:findButton(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindButton(name)
	end
end

function M:findText(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindText(name)
	end
end

function M:findImage(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindImage(name)
	end
end

function M:findSlider(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindSlider(name)
	end
end

function M:addSliderListener(name, func)
	if self.m_luaBehaviour then
		local slider = self.m_luaBehaviour:FindSlider(name)
	    slider.onValueChanged:RemoveAllListeners()
		slider.onValueChanged:AddListener(func)
	end
end

function M:findRawImage(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindRawImage(name)
	end
end

function M:findToggle(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindToggle(name)
	end
end

function M:findScrollbar(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindScrollbar(name)
	end
end

function M:findDropdown(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindDropdown(name)
	end
end

function M:findInputField(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindInputField(name)
	end
end

function M:findRectTransform(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindRectTransform(name)
	end
end

function M:findParticleSystem(name)
	if self.m_luaBehaviour then
		return self.m_luaBehaviour:FindParticleSystem(name)
	end
end

function M:addSpineComplete(state,action)
	if self.m_luaBehaviour then
		self.m_luaBehaviour:SpineCompleteEvent(state,action)
	end
end

--[[
	长按事件(第二版)
	action1 -- 普通点击
	action2 -- 长按
]]
function M:addActionChangAn(name,action1,action2)
	if self.m_luaBehaviour then
		local changAn_obj = self:findGameObject(name)
		local changAn_btn = changAn_obj:GetComponent("ChangAn")
		if changAn_btn then
			changAn_btn:RegistButtonClick(action1, action2)
		end
	end
end

--[[
    @desc: 长按事件 
	--@action1:按下
	--@action2:抬起
]]
function M:addTrigger(name, action1, action2)
	if self.m_luaBehaviour then
		self.m_luaBehaviour:AddTrigger(name, U3DUtil:Get_EventTriggerType("PointerDown") , action1)
		self.m_luaBehaviour:AddTrigger(name, U3DUtil:Get_EventTriggerType("PointerUp"), action2)
	end
end

--设置按钮进入事件
function M:addTriggerEnter(name)
	if self.m_luaBehaviour then
		local function callback_enter()
			self:updateMsg("btn_enter", name)
		end
		local function callback_exit()
			self:updateMsg("btn_exit", name)
		end
		local function callback_down()
			self:updateMsg("btn_down", name)
		end
		local function callback_up()
			self:updateMsg("btn_up", name)
		end
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerEnter") ,callback_enter)
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerExit"),callback_exit)
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerDown") ,callback_down)
		self.m_luaBehaviour:AddTrigger(name,U3DUtil:Get_EventTriggerType("PointerUp"),callback_up)
	end
end

function M:findSkeletonGraphic(name)
	local obj = self:findGameObject(name)
	if obj then
		local sg = obj:GetComponent("SkeletonGraphic")
		return sg
	end
end

--- 打开ui动画
function M:runOpenAnim( anim_node, callBackFunc )
	local transfer = self.m_transfer
	if anim_node and transfer then
		self.m_control.m_view:lockTouch("TAG:runOpenAnim")
		local function endCallFunc()
			self.m_control.m_view:unlockTouch("TAG:runOpenAnim")
			callBackFunc()
		end
		--增加pop框的弹出效果
		local transform = anim_node.transform
		if transfer == "scale" then
			transform.localScale = Vector3(0.8,0.8,0.8)
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOScale(1.2, 0.15))
			sequence:Append(transform:DOScale(1.0, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "up_to_down" then
			local pos = transform.localPosition
			transform.localPosition = Vector3(pos.x, pos.y + GlobalConfig.UI_DESIGN_HEIGHT, pos.z)
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveY(pos.y - 10, 0.25))
			sequence:Append(transform:DOLocalMoveY(pos.y, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "right_to_left" then
			local pos = transform.localPosition
			transform.localPosition = Vector3(pos.x + GlobalConfig.UI_DESIGN_WIDTH, pos.y, pos.z)
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveX(pos.x - 10, 0.35))
			sequence:Append(transform:DOLocalMoveX(pos.x, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "left_to_right" then
			local pos = transform.localPosition
			transform.localPosition = Vector3(pos.x - GlobalConfig.UI_DESIGN_WIDTH, pos.y, pos.z)
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveX(pos.x + 10, 0.35))
			sequence:Append(transform:DOLocalMoveX(pos.x, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "scale_and_up_to_down" then
			transform.localScale = Vector3.zero
			local pos = transform.localPosition
			transform.localPosition = Vector3(pos.x - GlobalConfig.UI_DESIGN_WIDTH, pos.y + GlobalConfig.UI_DESIGN_WIDTH, pos.z)
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMove(pos, 0.25))
			sequence:Join(transform:DOScale(1, 0.25))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "animation" then
			if self.m_luaBehaviour and self.m_anim_name then
				self.m_luaBehaviour:RunAnim(self.m_anim_name, endCallFunc, 1)
			else
				endCallFunc()
			end
	    else
	    	endCallFunc()
		end
	else
		callBackFunc()
	end
end

--- 关闭ui动画
function M:runCloseAnim( anim_node, callBackFunc)
	local transfer = self.m_transfer
	if anim_node and transfer then
		self.m_control.m_view:lockTouch("TAG:runCloseAnim")
		local function endCallFunc()
			self.m_control.m_view:unlockTouch("TAG:runCloseAnim")
			callBackFunc()
		end
		local transform = anim_node.transform
		if transfer == "scale" then
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOScale(0, 0.2))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "up_to_down" then
			local pos = transform.localPosition
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveY(pos.y + GlobalConfig.UI_DESIGN_HEIGHT, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "right_to_left" then
			local pos = transform.localPosition
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveX(pos.x - GlobalConfig.UI_DESIGN_WIDTH, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		elseif transfer == "left_to_right" then
			local pos = transform.localPosition
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOLocalMoveX(pos.x + GlobalConfig.UI_DESIGN_WIDTH, 0.15))
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		else
			endCallFunc()
		end
	else
		callBackFunc()
	end
end

function M:openView(name, params, alias, ismulity)
	self.m_control:openView(name, params, alias, ismulity)
end

function M:setBaseViewSortOrder()
	baseViewSortOrder = viewSortOrder + 5
	Logger.log(viewSortOrder, "<color=green>OOUIbase setBaseViewSortOrder</color> : ")
end

function M:resetViewSortOrder()
	viewSortOrder = baseViewSortOrder or 0
	Logger.log(viewSortOrder, "<color=green>OOUIbase resetViewSortOrder</color> : ")
end

return M