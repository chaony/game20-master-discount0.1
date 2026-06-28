local M = class("EqpBreakPopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "HeroInfo/EqpBreakPop"

function M:onEnter()
	self.parent_obj = self:findGameObject("parent_obj")
	self.m_model.is_lock = true
	self:setObjectVisible("texts", false)
	self:setObjectVisible("pan_bg", false)
	self:setObjectVisible("yun_img", false)
	self:setObjectVisible("jump_btn", false)
	self:setTextByLanKey("equip_name_text", string.cutTextForString(Language:getTextByKey(self.m_model.m_eqp_cfg.name) ) )
	self:setTextByLanKey("attr_bg_text", "union_str_0066")
	self.m_control:setOnceTimer(0.3, handler(self, self.creatEquipObj))
end

--创建动效预制体
function M:creatEquipObj()
	local wea_name = ""
	local ult_equip_cfg = nil
	if self.m_model.m_eqp_cfg.quality == 11 then
		--self:setTextByLanKey("tp_text", "可觉醒")
		wea_name, ult_equip_cfg = self.m_model:getTopQualityEquip(self.m_model.m_eqp_cfg.awake_id)
	else
		--self:setTextByLanKey("tp_text", "突破成功")
		wea_name, ult_equip_cfg = self.m_model:getTopQualityEquip(self.m_model.m_eqp_cfg.evolution_id)
	end
	if self.m_model.m_eqp_cfg.quality == 11 then
		-- self:setTextByLanKey("quality_num_text", "天")
		self:setImg("a_zbtpts_zbpinjie_tian", ResourceUtil:getLanAtlas(), "tag_img")
	elseif self.m_model.m_eqp_cfg.quality == 10 then
		-- self:setTextByLanKey("quality_num_text", "地")	
		self:setImg("a_zbtpts_zbpinjie_di", ResourceUtil:getLanAtlas(), "tag_img")
	elseif self.m_model.m_eqp_cfg.quality == 9 then
		-- self:setTextByLanKey("quality_num_text", "玄")	
		self:setImg("a_zbtpts_zbpinjie_xuan", ResourceUtil:getLanAtlas(), "tag_img")
	end
	local attr = self.m_model.m_eqp_cfg.attr or {}
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
	
    self:setTextByLanKey("attr_des", attr_name)
    self:setTextByLanKey("attr_num", attr_num)

	local fx_ui_effect = ResourceUtil:GetUIEffectItem("EquipAwaken/"..wea_name)
	if IsNull(fx_ui_effect) then
		return
	end
	fx_ui_effect.transform:SetParent(self.parent_obj.transform, false)
	local body_size = 1
	if ult_equip_cfg then
		if ult_equip_cfg.body_size == 0 then
			body_size = 1
		else
			body_size = ult_equip_cfg.body_size
		end
	end
	UIUtil.setLocalScale(fx_ui_effect.transform, body_size, body_size, 1)
	self.anim = fx_ui_effect:GetComponent("Animator")
	if self.anim then
		if self.m_model.m_eqp_cfg.quality == 9 then
			self.anim:CrossFade("01",0)
		elseif self.m_model.m_eqp_cfg.quality == 10 then	
			self.anim:CrossFade("02",0)
		elseif self.m_model.m_eqp_cfg.quality == 11 then	
			self.anim:CrossFade("03",0)
		end
	end
	self.m_control:setOnceTimer(1.9, function ()
		self:setObjectVisible("pan_bg", true)
	end)
	self.m_control:setOnceTimer(2, function ()
		self.m_model.is_lock = false
		self:setObjectVisible("texts", true)
		self:setObjectVisible("yun_img", true)
	end)
end


return M