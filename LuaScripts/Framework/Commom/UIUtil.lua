----------------- UIUtil

local M = {}

local Text = U3DUtil:Get_Text()
local Image = U3DUtil:Get_Image()
local Button = U3DUtil:Get_Button()
local InputField = U3DUtil:Get_InputField()
local Slider = U3DUtil:Get_Slider()
local ScrollRect = U3DUtil:Get_ScrollRect()
local RectTransform = U3DUtil:Get_RectTransform()
local Toggle = U3DUtil:Get_Toggle()
local Outline = U3DUtil:Get_Outline()
local OutlineEx = U3DUtil:Get_OutlineEx()
local CanvasGroup = U3DUtil:Get_CanvasGroup()
local LuaBehaviour = U3DUtil:Get_LuaBehaviour()
local VerticalLayoutGroup = U3DUtil:Get_VerticalLayoutGroup()
local ContentSizeFitter = U3DUtil:Get_ContentSizeFitter()
local Camera = U3DUtil:Get_Camera()

function M.getChild(trans, index)
	return trans:GetChild(index)
end

-- 注意：根节点不能是隐藏状态，否则路径将找不到
function M.findComponent(trans, ctype, path)
	assert(trans ~= nil)
	assert(ctype ~= nil)
	
	local targetTrans = trans
	if path ~= nil and type(path) == "string" and #path > 0 then
		targetTrans = trans:Find(path)
	end
	if targetTrans == nil then
		return nil
	end
	local cmp = targetTrans:GetComponent(ctype)
	if cmp ~= nil then
		return cmp
	end
	return targetTrans:GetComponentInChildren(ctype)
end

function M.findTrans(trans, path)
	if path == nil then
		return trans
	end
	return trans:Find(path)
end

function M.findText(trans, path)
	return M.findComponent(trans, typeof(Text), path)
end

function M.findImage(trans, path)
	return M.findComponent(trans, typeof(Image), path)
end

function M.findButton(trans, path)
	return M.findComponent(trans, typeof(Button), path)
end

function M.findInput(trans, path)
	return M.findComponent(trans, typeof(InputField), path)
end

---@return CS.wt.framework.LuaBehaviour
function M.findLuaBehaviour(trans, path)
	return M.findComponent(trans, typeof(LuaBehaviour), path)
end

function M.findSlider(trans, path, func)
	local slider = M.findComponent(trans, typeof(Slider), path)
	if func then
	    slider.onValueChanged:RemoveAllListeners()
		slider.onValueChanged:AddListener(func)
	end
	return slider
end

function M.findToggle(trans, path)
	return M.findComponent(trans, typeof(Toggle), path)
end

function M.findScrollRect(trans, path)
	return M.findComponent(trans, typeof(ScrollRect), path)
end

function M.findRectTransform(trans, path)
	return M.findComponent(trans, typeof(RectTransform), path)
end

function M.findContentSizeFitter(trans, path)
	return M.findComponent(trans, typeof(ContentSizeFitter), path)
end

function M.findCamera(trans, path)
	return M.findComponent(trans, typeof(Camera), path)
end

function M.setLocalPosition(trans, x, y, z)
	local rtrans = M.findComponent(trans, typeof(RectTransform))
	local lpos = rtrans.localPosition
	if x then
		lpos.x = x
	end
	if y then
		lpos.y = y
	end
	if z then
		lpos.z = z
	end
	rtrans.localPosition = lpos
	return rtrans
end

function M.setLocalScale(trans, x, y, z)
	local rtrans = M.findComponent(trans, typeof(RectTransform))
	local lscale = rtrans.localScale
	if x then
		lscale.x = x
	end
	if y then
		lscale.y = y
	end
	if z then
		lscale.z = z
	end
	rtrans.localScale = lscale
	return rtrans
end

function M:setLocalDelta(trans, width, height)
	local rect = M.findComponent(trans, typeof(RectTransform))
	if rect then
		rect.sizeDelta = Vector2.New(width, height)
	end
end

function M.setButtonClick(trans, func, params, path, ui_name)
	local btn = M.findButton(trans, path)
	if btn then
		btn.onClick:RemoveAllListeners()
		if params then
			btn.onClick:AddListener(function ()
				func(trans,params)
				ui_name = ui_name or ""
				GameUtil:playBtnSound(ui_name .. "/" .. btn.name)
			end)
		else
			btn.onClick:AddListener(func)
		end
	end
	return btn
end

function M.setText(trans, text_msg, path)
	local text = M.findText(trans, path)
	if text and text_msg then
		text.text = text_msg
	end
	return text
end

function M.setTextColor(trans, color, path)
	local text = M.findText(trans, path)
	if text then
		text.color = color
	end
	return text
end

function M.setTextByLanKey(trans, path, lan_key, arg1, ...)
	return M.setText(trans, Language:getTextByKey(lan_key, arg1, ...), path)
end

--img_msg:图片名字 img_atlas：隶属于图集的名字
function M.setImg(trans, img_msg, img_atlas, path)
	local img = M.findImage(trans, path)
	if img then
		img.sprite = ResourceUtil:GetSprite(img_msg,img_atlas)
	end
	return img
end

function M.setScale(trans, scale1, scale2)
	scale1 = scale1 or 1
	if scale2 then
		trans.localScale = Vector3.New(scale1,scale2,1)
	else
		trans.localScale = Vector3.New(scale1,scale1,1)
	end
end

function M.setObjectVisible(trans, visible, path)
	local obj = M.findTrans(trans, path)
	if obj then
		obj.gameObject:SetActive(visible)
	end
	return obj
end

-- 设置透明度0~1
function M.setOpacity(trans, opacity)
	local canvas_group = M.findComponent(trans, typeof(CanvasGroup))
	if canvas_group then
		canvas_group.alpha = opacity or 1
	end
end

function M:findGroup(trans)
	local canvas_group = M.findComponent(trans, typeof(CanvasGroup))
	return canvas_group
end


function M.setToggleIsOn(trans, visible)
	local togBtn = M.findComponent(trans, typeof(Toggle))
    togBtn.isOn = visible
	return togBtn
end

function M.addToggleListener(toggle_btn, func, params, ui_name)
    toggle_btn.onValueChanged:RemoveAllListeners()
	toggle_btn.onValueChanged:AddListener(function (check)
		func(check, params)
		if check then
			ui_name = ui_name or ""
			GameUtil:playBtnSound(ui_name .. "/" .. toggle_btn.gameObject.name)
		end
	end)
end

function M.destroyObject(obj)
	U3DUtil:Destroy(obj)
end

function M.destroyAllChild(trans)
	local count = trans.childCount
	if count > 0 then
		for i=count-1,0,-1 do
			U3DUtil:Destroy(trans:GetChild(i).gameObject)
		end
	end
end

function M.loadGameObject(prefabs, parent)
	local gameObjiec = ResourceUtil:LoadUIGameObject(prefabs, Vector3.zero, nil)
	gameObjiec.transform:SetParent(parent.transform,false)
	return gameObjiec
end

function M.addInputFieldListener(trans, func)
	local input = M.findComponent(trans, typeof(InputField))
    input.onValueChanged:RemoveAllListeners()
	input.onValueChanged:AddListener(func)
	return input
end

function M.worldToScreenPoint(pos)
	return static_ui_camera:WorldToScreenPoint(pos)
end

function M.UITo3D(uipos)
	local screenPos = static_ui_camera:WorldToScreenPoint(uipos)
	screenPos.z = 15;
	--SceneManager.curScene.cameraController.Camera_3D.transform.position.z;
	local pos_3d = SceneManager:getCurSceneView().cameraController.Camera_3D:ScreenToWorldPoint(screenPos);
	return pos_3d;
end

function M.ScenePosToUI(pos)
	local screenPos = SceneManager:getCurSceneView().cameraController.Camera_3D:WorldToScreenPoint(pos);
	local ui_pos = static_ui_camera:ScreenToWorldPoint(screenPos)
	return ui_pos
end

function M.screenToWorldPoint(pos)
	return static_ui_camera:ScreenToWorldPoint(pos)
end

function M.findOutline(trans, path)
	return M.findComponent(trans, typeof(Outline), path)
end

function M.setOutlineEffectColor(trans, path, color)
	local outline = M.findComponent(trans, typeof(Outline), path)
	if outline then
		outline.effectColor = color
	end
	return outline
end

function M.findOutlineExt(trans, path)
	return M.findComponent(trans, typeof(OutlineEx), path)
end

function M.setOutlineExEffectColor(trans, path, color, width)
	local outline = M.findComponent(trans, typeof(OutlineEx), path)
	if outline then
		outline.OutlineColor = color
		if width then
			outline.OutlineWidth = width
		end
	end
	return outline
end

function M.setVerticalLayoutGroupSpacing(trans, num)
	local obj = M.findComponent(trans, typeof(VerticalLayoutGroup))
	if obj then
		obj.spacing = num
	end
end	

function M.setContentSizeFitterLayoutVertical(trans, path)
	local csf = M.findContentSizeFitter(trans, path)
	if csf then
		csf:SetLayoutVertical()
	end
end	

function M.setContentSizeFitterLayoutHorizontal(trans, path)
	local csf = M.findContentSizeFitter(trans, path)
	if csf then
		csf:SetLayoutHorizontal()
	end
end

function M:registerDragEvent(obj, event_func)
	local dragEventHelper = obj:GetComponent("DragEventHelper")
	local begin_pos = nil
	if dragEventHelper then
		local function OnBeginDrag(eventData)
			--Logger.log(eventData, "OnBeginDrag ===")
			begin_pos = eventData.position
		end

		local function OnDrag(eventData)
			--Logger.log(eventData, "OnDrag ===")
		end

		local function OnEndDrag(eventData)
			--Logger.log(eventData, "OnEndDrag ===")
			if begin_pos then
				local end_pos = eventData.position
				local dis = end_pos.x - begin_pos.x
				if dis > 150 then
					event_func(true)
				elseif dis < -150 then
					event_func(false)
				end
			end
			begin_pos = nil
		end
		dragEventHelper.mOnBeginDragHandler = OnBeginDrag
		dragEventHelper.mOnDragHandler = OnDrag
		dragEventHelper.mOnEndDragHandler = OnEndDrag
	end
end

function M.setImgAlpha(obj, alpha)
	local img = UIUtil.findImage(obj)
	local star_color = img.color
	star_color.a = alpha or 0
	img.color = star_color
end

return M