local M = class("ArtifactBookPopView",LikeOO.OOPopBase)

M.m_uiName = "EquipAwaken/ArtifactBookPop"
M.m_size_type = 2

--装备觉醒
M.TAG_TAB = {
    {img = "a_sbp_wuqi_li", str = "equip_awake_001"}, --武器
    {img = "a_sbp_wuqi_ming", str = "equip_awake_002"}, --武器
    {img = "a_sbp_wuqi_zhi", str = "equip_awake_003"}, --武器
    {img = "a_sbp_fangju_li", str = "equip_awake_004"}, --防具
    {img = "a_sbp_fangju_ming", str = "equip_awake_005"}, --防具
    {img = "a_sbp_fangju_zhi", str = "equip_awake_006"}, --防具
}

function M:onEnter()
    self.do_tween_tab = {}
    self.attr_fly_tab = {} --属性改变飞入预制
    self.artifact_cell_tab = {}
    self.hui_img = self:findImage("hui_img")
    self.break_btn_img = self:findImage("break_btn")
    self.break_word_img = self:findImage("break_word_img")
    self:setObjectVisible("UI_EquipAwaken_HuaBan_002", false)
    self:setObjectVisible("max_effect", false)
    for k=1,10 do
        self:setObjectVisible("hua_effect_"..k, false)
    end
    self.equip_tx_tab = {}
    self.weapon_obj = {}

    --战力改变飞入预制
    self.m_full_combat = UserDataManager.user_data:getUserStatusDataByKey("full_combat")
    self.add_combat = nil 
    local old_combat_text = self:findGameObject("old_combat_text")
    self.m_combat_change_bg_img = self:findGameObject("combat_change_bg_img")
    self.m_combat_up_effect = ResourceUtil:GetUIEffectItem("HeroBag/UI_HeroBag_ZhanLi_003", self.m_combat_change_bg_img)
    self:setParticleRenderOrder(self.m_combat_up_effect)
    self.m_combat_up_effect:SetActive(false)
    self.add_combat = self:creatEffect("add_combat", old_combat_text)
    self.add_combat:SetActive(false)
    self.m_show_combat_anim = false

    self:refreshUI()
    self:setTextByLanKey("tips_count_text", self.m_model:getBookTips())
    self:setTextByLanKey("right_sub_title_text_2", "equipAwaken_right_sub_title_2")
end

function M:refreshUI()
    self:updateTagLoopScroll()
    self:updateRightUI()
    local tag_cfg = self.m_model:getTagList()
    self:updateEquipLoopScroll(tag_cfg.eqiup_id)
end

function M:updateTagLoopScroll()
    local data = self.TAG_TAB
    if self.tag_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("tag_scroll")
        local params = {
            show_data = data,
            ui_name = self.m_uiName,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateTagCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				self:updateMsg("tag_btn", index)
			end
        }
        self.tag_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.tag_loop_scroll_view:reloadData(data)
    end
end

function M:updateTagCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    if luaBehaviour then
        if self.m_model.tag_index == index then
            LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", cell_data.img.."_dianliang", ResourceUtil:getLanAtlas())  
        else
            LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", cell_data.img, ResourceUtil:getLanAtlas())
        end
        local lv = self.m_model:getThronslvByIndex(index)
        local lv_max = self.m_model:getThronsMaxlvByIndex()
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_num",lv)
        if self.m_model:checkSeason() == true then
            if lv >= lv_max then
                --进阶                                                                                                                                        --进阶检查下一qulity的赛季限制
                local bl =  self.m_model:checkCanAdvanced() == true and self.m_model:checkCryLv() == true and self.m_model:getThronsConsByIndex2() and self.m_model:checkSeasonForNextQulity()
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_red_point", bl)
            else --升级
                local bl = self.m_model:checkCanLvUpByTag(index)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_red_point", bl)
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_red_point", false)
        end
    end
end

function M:updateRightUI()
    self:setObjectVisible("right_lock", false)
    --图鉴完成度
    local num_1 = self.m_model:degreeOfCompletion()
    self:setTextByLanKey("title_text_1", "equip_str_036", num_1)
    --图鉴收集属性
    local show_str = self.m_model:getShowAttrs()
    self:setTextByLanKey("title_text_2", "equip_str_052",show_str)
    --图鉴属性
    local show_str = self.m_model:getShowAttrs2()
    self:setTextByLanKey("title_text_3", "equip_str_037",show_str)
    if #show_str == 0 then
        self:setObjectVisible("title_text_3", false)
    else
        self:setObjectVisible("title_text_3", true)   
    end
    self:updateLvUpUI()
end

--升级UI
function M:updateLvUpUI()
    local is_open, tips = BtnOpenUtil:isBtnOpen(258)
    if is_open == false or self.m_model:openEquipLvUp() == false then 
        self:setObjectVisible("right_lock", true)
        self:setTextByLanKey("right_lock_1_text", "equip_awake_015")
        self:setTextByLanKey("right_lock_2_text", "equip_awake_043")
        return
    end
    self:refreshRedPoint()
    local max_lv = self.m_model:getThronsMaxlvByIndex()
    local lv = self.m_model:getThronslvByIndex(self.m_model.tag_index)
    local yu = lv%10 --取余
    if lv <= 10 then
        yu = lv
    end
    if lv > 0 and yu == 0 then
        yu = 10
    end
    local star = self.m_model:getThronsStarByIndex()
    if lv < max_lv and yu == 10 then --进阶后10朵花瓣合一为0
        yu = 0
    end
    --花✿
    for i = 1 , 10 do
        self:setObjectVisible("hua_"..i, yu>=i) 
    end
    self:setObjectVisible("max_effect", yu == 10)
    --星☆
    for i = 1 ,3 do 
        self:setObjectVisible("star_"..i, star>=i) 
    end
    local show_quality = self.m_model:getThronsShowQualityByIndex()
    if show_quality > 10 then
        show_quality = 10
    end
    local star_lv_key = 30 + show_quality
    self:setTextByLanKey("star_lev_text", "equip_awake_0" .. star_lv_key)
    if self.m_model:checkIsMaxLv() then    --当前页签满级
        if self.m_model:checkCanAdvanced() == true and self.m_model:checkCryLv() == true then --其他页签达到上限
            self:setObjectVisible("lv_btn", true)
            self:setObjectVisible("lv_lock_btn", false)
            self:setObjectVisible("break_effect_node", true)
            self:setTextByLanKey("lv_btn_text", "equip_str_051")
            self.break_btn_img.material = nil
            self.break_word_img.material = nil
        else
            self:setObjectVisible("lv_btn", false)
            self:setObjectVisible("lv_lock_btn", true)
            self:setObjectVisible("break_effect_node", false)
            self:setTextByLanKey("lv_lock_btn_text", "options_str_0039")
            self.break_btn_img.material = self.hui_img.material
            self.break_word_img.material = self.hui_img.material
        end
        self:setObjectVisible("break_node", true)
        self:setObjectVisible("cost_node", false)
    else
        if self.m_model:checkCanLvUp() == true then 
            self:setObjectVisible("lv_btn", true)
            self:setObjectVisible("lv_lock_btn", false)
        else
            self:setObjectVisible("lv_btn", false)
            self:setObjectVisible("lv_lock_btn", true)    
        end
        self:setTextByLanKey("lv_lock_btn_text", "new_str_0407")
        self:setTextByLanKey("lv_btn_text", "new_str_0407")

        self:setObjectVisible("break_node", false)
        self:setObjectVisible("cost_node", true)
    end
    self:setTextByLanKey("lv_num_text", Language:getTextByKey("equip_awake_018") .. lv.."/"..max_lv)
    self:setObjectVisible("open_type_img", self.m_model.quick_lv_up == true)
    self:setObjectVisible("close_type_img", self.m_model.quick_lv_up == false)
    local cons = {}
    if self.m_model.quick_lv_up == true then
        cons = self.m_model:getQuickLvThronsConsByIndex(self.m_model.tag_index)
    else
        cons = self.m_model:getThronsConsByIndex(self.m_model.tag_index) 
    end
    if next(cons) ~= nil then
        local cons_data1 = RewardUtil:getProcessRewardData(cons[1])
        local cons_data2 = RewardUtil:getProcessRewardData(cons[2])
        self:setImg(cons_data1.icon_name, cons_data1.atlas_name, "cons_1_img")
        self:setImg(cons_data2.icon_name, cons_data2.atlas_name, "cons_2_img")
        if cons_data1.user_num >= cons_data1.data_num then 
            self:setTextByLanKey("cons_num_1", GameUtil:formatValueToString(cons_data1.data_num)  .."/".. GameUtil:formatValueToString(cons_data1.user_num))
        else
            self:setTextByLanKey("cons_num_1", "<color=#F1431F>".. GameUtil:formatValueToString(cons_data1.data_num).."</color>/".. GameUtil:formatValueToString(cons_data1.user_num))
        end

        if cons_data2.user_num >= cons_data2.data_num then 
            self:setTextByLanKey("cons_num_2", GameUtil:formatValueToString(cons_data2.data_num).."/"..GameUtil:formatValueToString(cons_data2.user_num))
        else
            self:setTextByLanKey("cons_num_2", "<color=#F1431F>"..GameUtil:formatValueToString(cons_data2.data_num).."</color>/"..GameUtil:formatValueToString(cons_data2.user_num))   
        end
    end
    local type_data = self.TAG_TAB[self.m_model.tag_index]
    self:setTextByLanKey("equip_type_text", type_data.str)
    self:setTextByLanKey("right_sub_title_text_1", "equip_awake_017", Language:getTextByKey(type_data.str))
    self:setTextByLanKey("tips_title_text", "equip_awake_007", Language:getTextByKey(type_data.str) )
    self:setImg(type_data.img.."_dianliang" ,ResourceUtil:getLanAtlas(),"hua_xin_img")
    
    local lv = self.m_model:getLvUpLock()
    local lv_need_for_all = self.m_model:getThronsMaxlvByIndex()
    if self.m_model:checkCryLv() == true then
        self:setTextByLanKey("break_tips_2_text", "equip_awake_025", lv)
    else
        self:setTextByLanKey("break_tips_2_text", "equip_awake_026", lv)
    end
    self:setObjectVisible("break_tips_2_text", lv ~= 0)
    if self.m_model:checkCanAdvanced() == true then
        self:setTextByLanKey("break_tips_1_text", "equip_awake_023", lv_need_for_all)
    else
        self:setTextByLanKey("break_tips_1_text", "equip_awake_024", lv_need_for_all)
    end
    
    --装备属性
    local attr = self.m_model:getThronsAttrByIndex()
    local attr_index = 0
    for k=1,3 do
        self:setObjectVisible("equip_attr_name_"..k, false)
        self:setObjectVisible("equip_attr_num_"..k, false)
    end
    for k,v in ipairs(attr) do
        local key = GameUtil:getAttrsKey(v[1])
        local name = GameUtil:getAttrsName(key)
        attr_index = attr_index + 1
        local num = v[2]
        local str_num = ""
        if self.m_model:equipBookAttrRatioById(v[1]) > 0 then
            num = num * (1 + self.m_model:equipBookAttrRatioById(v[1]))
        end
        if GameUtil:canPerAttrTransition(key)== true then
            num = num*100
        end
        if GameUtil:attrTransition(key)== true then
            str_num = GameUtil:formatValueToString(num).."%"
        else
            str_num = GameUtil:formatValueToString(num)
        end
        self:setTextByLanKey("equip_attr_name_"..k, name)
        self:setTextByLanKey( "equip_attr_num_"..k, str_num)
        self:setObjectVisible("equip_attr_name_"..k, true)
        self:setObjectVisible("equip_attr_num_"..k, true)
    end
end

function M:refreshCombat()
    local full_combat =  UserDataManager.user_data:getUserStatusDataByKey("full_combat")
    if self.m_full_combat < full_combat then
        self:playCombatChangeAnim(self.m_full_combat, full_combat)
    end
    self.m_full_combat = full_combat
end

function M:playCombatChangeAnim(last_combat, cur_combat)
    if self.m_combat_change_bg_img then
        self:setObjectVisible("combat_change_bg_img", true)
        self.m_combat_up_effect:SetActive(last_combat < cur_combat)
        self:AddCombatNumber(last_combat, cur_combat)
        --self:setText("old_combat_text", tostring(last_combat))
    end
end


function M:AddCombatNumber(num1, num2)
    if IsNull(self.add_combat) then
        return
    end
    if self.add_combat_sequence then
        self.add_combat_sequence:Kill()
        self.add_combat_sequence = nil
    end

    if self.combat_time then
        self.m_control:removeTimer(self.combat_time)
        self.combat_time = nil
    end

    local show_text = self:setText("old_combat_text", GameUtil:formatValueToString(num1))
    local text_rt = show_text.gameObject:GetComponent("RectTransform")
    local rect = text_rt.rect
    local num = rect.width
    local combat_text = UIUtil.findText(self.add_combat.transform)
    local text_color = num2 - num1 > 0 and Color(74/255,237/255,109/255,1) or Color(255/255,23/255,5/255,1)
    local text_flag = num2 - num1 > 0 and "+" or ""
    combat_text.text = text_flag ..(num2 - num1)
    self.add_combat.transform.localPosition = Vector3.New((num - 55), 0, 0)
    UIUtil.setTextColor(self.add_combat.transform, text_color)
    self.add_combat:SetActive(true)
    local function awaitPlay()
        if not IsNull(self.add_combat) then
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(self.add_combat.transform:DOLocalMoveX(0, 0.5))
            sequence:Insert(0, DOTweenModuleUI.DOFade(combat_text, 0, 0.5))
            sequence:OnComplete(function ()
                if not IsNull(self.add_combat) then
                    self.m_sequence = self:NumberChange(num1, num2)
                    --self:setText("old_combat_text", GameUtil:formatValueToString(num2))
                    self.add_combat:SetActive(false)
                    --self:setObjectVisible("combat_change_bg_img", false)
                end
                audio:SendEvtUI("Play_UI_Power_Increase")
            end
            )
            sequence:SetAutoKill(false)
            self.add_combat_sequence = sequence
        end
        if self.combat_time then
            self.m_control:removeTimer(self.combat_time)
            self.combat_time = nil
        end
    end
    self.combat_time = self.m_control:setTimer(0.5, awaitPlay)
end

function M:NumberChange(num1, num2)
    local sequence = Tweening.DOTween.Sequence()
    sequence:SetAutoKill(false)
    sequence:Append(Tweening.DOTween.To(function(index)
        local temp = math.floor(index)
        self:setText("old_combat_text", GameUtil:formatValueToString(temp))
    end, num1, num2, 0.5))
    sequence:AppendInterval(0.2)
    sequence:OnComplete(function ()
        self.m_combat_up_effect:SetActive(false)
        self:setObjectVisible("combat_change_bg_img", false)
    end)
    return sequence
end

function M:refreshRedPoint()
    if self.m_model:checkSeason() == true then
        if self.m_model:checkIsMaxLv() == true then
            --进阶
            self:setObjectVisible("lv_up_btn_red_point", self.m_model:checkCanAdvanced() == true and self.m_model:checkCryLv() == true and self.m_model:getThronsConsByIndex2())
        else --升级
            self:setObjectVisible("lv_up_btn_red_point", self.m_model:checkCanLvUp() == true)
        end
    else
        self:setObjectVisible("lv_up_btn_red_point", false)
    end
end

function M:updateEquipLoopScroll(data)
    if self.eqp_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("equip_scroll")
        local params = {
            show_data = data,
            ui_name = self.m_uiName,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateEquipItem(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				self:updateMsg("tag_btn", index)
			end
        }
        self.eqp_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.eqp_loop_scroll_view:reloadData(data)
    end
end

function M:updateEquipItem(index, cell_object, cell_data)
    self.artifact_cell_tab[cell_data] = cell_object
    local equip_cfg = UserDataManager.equip_data:getEquipConfigByCid(cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local equip_obj = luaBehaviour:FindGameObject("equip_icon")
    self:creatEquipObj(equip_cfg, equip_obj, cell_data)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "equip_name", equip_cfg.name)
end

--播放升级属性变化特效
function M:playAttrNumEffect(last_lv, new_lv)
    --local tag_cfg = self.m_model:getTagList()
    --for k,v in pairs(tag_cfg.eqiup_id) do
    --    self:playCellEffect(self.artifact_cell_tab[v], v, last_lv, new_lv)
    --end
    self:playCellEffect(last_lv, new_lv)
end

function M:playCellEffect(lase_lv, new_lv)
    local attr = self.m_model:getThronsAttrByIndexAndLv(lase_lv)
    local attr_new = self.m_model:getThronsAttrByIndexAndLv(new_lv)
    local attr_index = 0
    for k,v in ipairs(attr) do 
        local key = GameUtil:getAttrsKey(v[1])
        local name = GameUtil:getAttrsName(key)
        attr_index = attr_index + 1
        local num = v[2]
        local next_num = v[2]
        for n,m in pairs(attr_new) do
            if m[1] == v[1] then
                next_num = m[2]
            end
        end
        local str_num = ""
        if self.m_model:equipBookAttrRatioById(v[1]) > 0 then
            num = num * (1 + self.m_model:equipBookAttrRatioById(v[1]))
            next_num = next_num * (1 + self.m_model:equipBookAttrRatioById(v[1]))
        end
        if GameUtil:canPerAttrTransition(key)== true then
            num = num*100
            next_num = next_num*100
        end
        self:setObjectVisible("attr_effect_"..k, true)
        local text_obj =  self:findText("equip_attr_num_"..k)
        local fly_attr = self:creatEffect("add_combat", text_obj.gameObject)
        local fly_do_tween = self:AddAtteNumber(fly_attr, num, next_num, function ()
                                    if not IsNull(fly_attr) then
                                        UIUtil.destroyObject(fly_attr)
                                    end
                            end)
        if fly_do_tween then
            table.insert(self.do_tween_tab, fly_do_tween)
        end
        self.m_control:setOnceTimer(0.5, function ()
            self:setObjectVisible("attr_effect_"..k, false)
            local do_tween = self:AttrNumberChange(text_obj, num, next_num)
            table.insert(self.do_tween_tab, do_tween)
        end)
    end
end

function M:AddAtteNumber(fly_attr, num1, num2, callback)
	local combat_text = UIUtil.findText(fly_attr.transform)
	combat_text.text = "+".. GameUtil:formatValueToString( GameUtil:formatNum(num2 - num1))
	fly_attr.transform.localPosition = Vector3.New(40, 0, 0)
    UIUtil.setTextColor(fly_attr.transform, Color.New(61/255, 116/255, 13/255))
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(fly_attr.transform:DOLocalMoveX(-60, 0.6))
    sequence:Insert(0, DOTweenModuleUI.DOFade(combat_text, 0.3, 0.6))
    sequence:OnComplete(function ()
        audio:SendEvtUI("Play_UI_Power_Increase")
        callback()
    end
    )
    sequence:SetAutoKill(false)
    return sequence
end

function M:creatEffect(tx_name, prent)
    local item = ResourceUtil:GetUIEffectItem("HeroInfo/"..tx_name, prent)
	return item
end

--属性滚动 tween
function M:AttrNumberChange(text_obj, num1, num2)
	if num2 > num1 then
		local sequence = Tweening.DOTween.Sequence()
		sequence:SetAutoKill(false)
		sequence:Append(Tweening.DOTween.To(function(index)
            local num = GameUtil:getPreciseDecimal(index,2)
            text_obj.text = GameUtil:formatValueToString(num)
		end, num1, num2, 0.5))
		self.m_control:setOnceTimer(0.6, function ()
            text_obj.text = GameUtil:formatValueToString(num2)
		end)
		return sequence
	else
        text_obj.text = GameUtil:formatValueToString(num2)
	end
	return nil
end


function M:clearWeaponObj()
    self.weapon_obj = {}
    for k,v in pairs(self.do_tween_tab) do
		if v then
			v:Kill()
		end
	end
	self.do_tween_tab = {}
end

--创建动效预制体
function M:creatEquipObj(equip_cfg, parent_obj, equip_id)
    --if self.weapon_obj[equip_id] then
    --    return
    --end
    UIUtil.destroyAllChild(parent_obj.transform)
    local str_name
    local str = string.split(equip_cfg.picture_effect, "UI_")
    str_name = str[2]
    local fx_ui_effect = ResourceUtil:GetUIEffectItem("EquipAwaken/"..str_name)
    fx_ui_effect.transform:SetParent(parent_obj.transform, false)
    self.weapon_obj[equip_id] = fx_ui_effect
	if IsNull(fx_ui_effect) then
		return
	end
    local equip_get = self.m_model:checkEquipThroneById(equip_id)
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
            if equip_get == true then
                img.material = nil
            else
                img.material = self.hui_img.material  
            end
        end
    end
    UIUtil.setObjectVisible(fx_ui_effect.transform, equip_get == true, "Fx_H")
    UIUtil.setObjectVisible(fx_ui_effect.transform, equip_get == true, "Fx_Hou")
    UIUtil.setObjectVisible(fx_ui_effect.transform, equip_get == true, "Fx_Q")
    UIUtil.setObjectVisible(fx_ui_effect.transform, equip_get == true, "Fx_Qian")
end

function M:showRightTips(bl) 
    self:setObjectVisible("tips_mask", bl == true)
    self:setObjectVisible("right_tips_img", bl == true)
end

function M:showHuaBan(last_lv, new_lv)
    --战力变化检测
    self:refreshCombat()
    
    last_lv = self:getIndexForLv(last_lv)
    new_lv = self:getIndexForLv(new_lv)
    for k=1,10 do
        self:setObjectVisible("hua_effect_"..k, false)
    end
    if new_lv - last_lv == 1 then
        audio:SendEvtUI("UI_XJDian")
        self:setObjectVisible("hua_".. new_lv, true)
        local hua_dffect = self:setObjectVisible("hua_effect_"..new_lv, true)
        self:play_spine(hua_dffect)
        self.m_control:setOnceTimer(1, function ()
            self:setObjectVisible("hua_effect_"..new_lv, false)
        end)
    else
        local i_index = 0
        for i = last_lv+1, new_lv do
            i_index = i_index + 1
            self.m_control:setOnceTimer(0.05+(i_index*0.3), function ()
                audio:SendEvtUI("UI_XJDian")
                local hua_dffect = self:setObjectVisible("hua_effect_"..i, true)
                self:setObjectVisible("hua_"..i, true)
                self:play_spine(hua_dffect)
            end)
        end
        i_index = 0
        for i = last_lv+1, new_lv do
            i_index = i_index + 1
            self.m_control:setOnceTimer(0.3+(i_index*0.3), function ()
                self:setObjectVisible("hua_effect_"..i, false)
            end)
        end
    end
end

function M:play_spine(obj)
    if IsNull(obj) then
        return
    end
    local UI_EquipAwaken_HuaBan01 = UIUtil.findTrans(obj.transform,"UI_EquipAwaken_HuaBan01")
    if IsNull(UI_EquipAwaken_HuaBan01) then
        return
    end
    local spine = UIUtil.findTrans(UI_EquipAwaken_HuaBan01,"HuaBan")
    if IsNull(spine) then
        return
    end
    local obj_sp = spine.gameObject:GetComponent("SkeletonGraphic")
    if not IsNull(obj_sp) then
        obj_sp.AnimationState:ClearTracks()
        obj_sp.AnimationState:SetAnimation(0, "EquipAwaken_HuaBan", true)
    end
end

function M:getIndexForLv(lv)
    local yu = lv%10 --取余
    if lv <= 10 then
        yu = lv
    end
    if lv > 0 and yu == 0 then
        yu = 10
    end
    local star = self.m_model:getThronsStarByIndex()
    local max_lv = self.m_model:getThronsMaxlvByIndex()
    if lv < max_lv and yu == 10 then --进阶后10朵花瓣合一为0
        yu = 0
    end
    return yu
end

function M:showHuaBan2()
    local function callback()
        --战力变化检测
        self:refreshCombat()
        
        audio:SendEvtUI("UI_DJDian")
        local hua_dffect = self:setObjectVisible("UI_EquipAwaken_HuaBan_002", true)
        if IsNull(hua_dffect) then
            return
        end
        local SkeletonGraphic = UIUtil.findTrans(hua_dffect.transform,"SkeletonGraphic")
        if IsNull(SkeletonGraphic) then
            return
        end
        local obj_sp = SkeletonGraphic.gameObject:GetComponent("SkeletonGraphic")
        if not IsNull(obj_sp) then
            obj_sp.AnimationState:ClearTracks()
            obj_sp.AnimationState:SetAnimation(0, "EquipAwaken_HuaBan_002", true)
        end
        self.m_control:setOnceTimer(1.3, function ()
            self:setObjectVisible("UI_EquipAwaken_HuaBan_002", false)
        end)
    end
    local cur_combat = UserDataManager.user_data:getUserStatusDataByKey("full_combat")
    self.m_control:openView("Pops.CommonSuccessPop", {sound_name = "UI_Tupo_Success", last_combat = self.m_full_combat, cur_combat = cur_combat, callback = callback})
end


function M:destroy()
	for k,v in pairs(self.do_tween_tab) do
		if v then
			v:Kill()
		end
	end
	self.do_tween_tab = {}
    M.super.destroy(self)
end

return M