local M = class("ArtifactBookPopView",LikeOO.OOPopBase)

M.m_uiName = "EquipAwaken/EquipAwakenPop"
M.m_size_type = 2

function M:onEnter()
    self.parent_obj = self:findGameObject("parent_obj")
    self:refreshUI()
end

function M:refreshUI()
    local cfg = nil 
    if self.m_model.m_equip_data then
        cfg = UserDataManager.equip_data:getEquipConfigByCid(self.m_model.m_equip_data.equ_cfg.awake_id)
        self:setObjectVisible("Fx", true) --觉醒打开该界面 需要显示爆炸特效
    elseif self.m_model.m_equip_cfg then  
        cfg = self.m_model.m_equip_cfg  
        self:setObjectVisible("Fx", false) --查看打开该界面 不显示爆炸特效
    end
    if cfg == nil then
        return
    end
    self:setTextByLanKey("equip_title", string.cutTextForString(Language:getTextByKey(cfg.name)))
    self:setTextByLanKey("equip_des2", Language:getTextByKey(cfg.des))
    local attr = cfg.attr or {}
    local attr_name = ""
    local attr_num = ""
    for k,v in pairs(attr) do
        if #v > 0 then
            local key = GameUtil:getAttrsKey(v[1])
            local atr_data = GameUtil:getAttrCfg(v[1])
            local atr_num = 0
            if atr_data.is_percent and  atr_data.is_percent == 1 then
                atr_num = v[2] * 100
            else
                atr_num = v[2] 
            end
            if GameUtil:attrTransition(key) == true then
                attr_num = attr_num..atr_num.."%".."\n"
            else
                attr_num = attr_num..atr_num.."\n"    
            end
            attr_name = attr_name..Language:getTextByKey(GameUtil:getAttrsName(key)).."\n"
        end
    end
    self:setTextByLanKey("attr_des",attr_name)
    self:setTextByLanKey("attr_num",attr_num)
    local equip_icon = self:findImage("equip_icon")
    GameUtil:updateResourcesImg(equip_icon,  "Texture/equip_awake/" ..cfg.equip_picture)
    self:setObjectVisible("equip_icon", false)

    self:RefreshThronesPhase(cfg);
    -- local front_fx_eccect = ResourceUtil:GetUIEffectItem("EquipAwaken/"..cfg.picture_effect.."_002")
    -- local back_fx_eccect = ResourceUtil:GetUIEffectItem("EquipAwaken/"..cfg.picture_effect.."_001")
    -- local back_obj = self:findGameObject("fx_back")
    -- local front_obj = self:findGameObject("fx_front")
    -- front_fx_eccect.transform:SetParent(front_obj.transform, false)
    -- back_fx_eccect.transform:SetParent(back_obj.transform, false)
    -- local pos_x = 0
    -- local pos_y = 0
    -- local scale = 0.9
    -- UIUtil.setLocalPosition(front_fx_eccect.transform,pos_x,pos_y)
    -- UIUtil.setLocalPosition(back_fx_eccect.transform,pos_x,pos_y)
    -- UIUtil.setLocalScale(front_fx_eccect.transform, scale,scale)
    -- UIUtil.setLocalScale(back_fx_eccect.transform, scale,scale)
    self.m_control:setOnceTimer(0.1,function ()
        self:creatEquipObj(cfg)
    end)
end

--创建动效预制体
function M:creatEquipObj(equip_cfg)
    local str_name
    local str = string.split(equip_cfg.picture_effect, "UI_")
    str_name = str[2]
    local fx_ui_effect = ResourceUtil:GetUIEffectItem("EquipAwaken/"..str_name)
    fx_ui_effect.transform:SetParent(self.parent_obj.transform, false)
	if IsNull(fx_ui_effect) then
		return
	end
    local body_size = 1
	if equip_cfg then
		if equip_cfg.body_size == 0 then
			body_size = 1
		else
			body_size = equip_cfg.body_size
		end
	end
	UIUtil.setLocalScale(fx_ui_effect.transform, body_size, body_size, 1)
    self.anim = fx_ui_effect:GetComponent("Animator")
	if self.anim then
        self.anim:CrossFade("03",1)
        self.anim.enabled = false
	end
    local childrens = fx_ui_effect.transform.childCount
    local forn_name = ""
    for i,v in pairs(fx_ui_effect.transform) do
        local img = UIUtil.findImage(fx_ui_effect.transform, v.name)
        if not IsNull(img) then
            img.material = nil
        end
    end
    UIUtil.setObjectVisible(fx_ui_effect.transform, true, "Fx_H")
    UIUtil.setObjectVisible(fx_ui_effect.transform, true, "Fx_Hou")
    UIUtil.setObjectVisible(fx_ui_effect.transform, true, "Fx_Q")
    UIUtil.setObjectVisible(fx_ui_effect.transform, true, "Fx_Qian")
end

function M:RefreshThronesPhase(equip_cfg)
    local thronePhase = self.m_model:getThronesPhase()
    local thronePhaseData = self.m_model:getCurThronesPhaseData()

    if next(thronePhase) then
        local isWeapon = equip_cfg.pos == 1
        local curPhase = thronePhaseData[thronePhase.lv]
        local nextPhase = thronePhaseData[thronePhase.lv + 1]
        local addAttr = ConfigManager:getCommonValueById(837,{600,300})
        local addValue = isWeapon and addAttr[1] or addAttr[2]
        self:setObjectVisible("thrones_phase", true)
        local exp = thronePhase.exp
        local nextExp = nextPhase ~= nil and  nextPhase.exp or exp
        local slider = self:findSlider("thrones_phase_bar")
        --slider.value = exp / nextExp
        --self:setText("thrones_phase_value", exp.."/"..nextExp .. "<color=#00ff00>+"..addValue .. "</color>")
        self:setText("thrones_phase_value", "<color=#00ff00>+"..addValue .. "</color>")
        self:setTextByLanKey("thrones_phase_text", curPhase.name)
        self:setImg(curPhase.icon, "item_icon","thrones_phase_Ico")
        local sequence = Tweening.DOTween.Sequence()
        sequence:AppendInterval(0.5)
        if exp < addValue then
            sequence:Append(DOTweenModuleUI.DOValue(slider, 1, 0.2):SetEase(CS.DG.Tweening.Ease.OutQuad))
            sequence:Append(DOTweenModuleUI.DOValue(slider, exp / nextExp, 0.2):SetEase(CS.DG.Tweening.Ease.OutQuad))
            self:setTextByLanKey("thrones_phase_info","equip_throne_new_attr", curPhase.effect_tips)
        else
            sequence:Append(DOTweenModuleUI.DOValue(slider, exp / nextExp, 0.4):SetEase(CS.DG.Tweening.Ease.OutQuad))
            self:setText("thrones_phase_info", "")
        end

        sequence:SetAutoKill(true)

    else
        self:setObjectVisible("thrones_phase", false)
    end
end


return M