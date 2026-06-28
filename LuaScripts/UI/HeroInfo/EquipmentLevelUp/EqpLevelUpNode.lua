--- 升阶
local M = class("EqpLevelUpNode",LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/EqpLevelUpNode"

local eqp_list = {} --装备列表缓存
local tab_money = {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0}
local pro_tab = {}

function M:onEnter()
    self.gray_img = self:findImage("gray_img")
	self.temp_num = table.copy(self.m_model:getEqpNum()) or 0
    self:setTextByLanKey("levelup_text", "new_str_0315")
    self:setTextByLanKey("ok_text", "new_str_1105")
    self:refreshUI()    
end

function M:refreshUI()
    self:setCurEqp()
    self:updateLoopScroll()
    self:updateNeedMoney()
    --self:updateAttrLoopScroll()
end

--[[
	创建消耗品列表
]]
function M:updateLoopScroll()
    eqp_list = {}
	local data = self.m_model.cons_list
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:setItemData(cell_data, cell_object)
                table.insert(eqp_list,{data = cell_data, obj = cell_object})
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) 
                if click_name == "sub_btn" then
                    self:updateMsg("sub_eqp", cell_data)
                else
                    self:updateMsg("check_eqp", cell_data)
                end
			end,
            ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--配置消耗品信息
function M:setItemData(data, obj)
    local ui_element = GameUtil:updateItemElementByData(obj, data,true, false)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local count_text_bg_img = luaBehaviour:FindGameObject("count_text_bg_img")
    count_text_bg_img:SetActive(true)
    local sub_btn = luaBehaviour:FindGameObject("sub_btn")
    local eqp_num = self.m_model:checkNumInList(data)
    if eqp_num > 0 then
        sub_btn:SetActive(true)
        local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", eqp_num.."/"..data.user_num)
    else
        sub_btn:SetActive(false)    
        local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", data.user_num)
    end
end

--更新当前被强化的装备信息
function M:setCurEqp()
    local cur_eqp_data, cur_eqp_cfg = self.m_model:getEqpData()
	self.m_icon_node = self:findGameObject("icon_node")
    if cur_eqp_cfg then
        if not IsNull(self.curEqp) then
            ResourceUtil:ReturnItem(self.curEqp)
            self.curEqp = nil
        end
		if cur_eqp_data then
			self.curEqp = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, cur_eqp_data.id, cur_eqp_data.race}, false, false)
			self.curEqp.transform:SetParent(self.m_icon_node.transform, false)
			GameUtil:updateItemEquipInfo(self.curEqp, cur_eqp_data, nil, self.m_model.m_heroid)
		else
			self.curEqp = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, self.m_model.m_equip_cfg_id, 0}, false, false)
			self.curEqp.transform:SetParent(self.m_icon_node.transform, false)
		end
	end
    self:setTextByLanKey(cur_eqp_cfg.name, "equip_text")
    self:setTextByLanKey("equip_text", cur_eqp_cfg.name)
    self:setTextByLanKey("cell_title","new_str_0066") 
    self:setTextByLanKey("levelup_num", cur_eqp_data.lv.."/"..cur_eqp_cfg.lv_limit) 
    local color = GlobalConfig.QUALITY_COMMON_SETTING[cur_eqp_cfg.quality]
    self:setTextColor("equip_text",color.RGBA)
    self:setImg(cur_eqp_cfg.icon,"equip_icon","eqp_icon_img")
    local kk = GlobalConfig.QUALITY_COMMON_SETTING[cur_eqp_cfg.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
    self:setImg(kk.frame_name,"equip_icon","eqp_icon_bg_img")
    self:setObjectVisible("eqp_icon_bg_img+",kk.is_add)
    self:updateNeedMoney()
    local pro_parent = self:findGameObject("pro_parent")
    local pre_lv = self.m_model:getPreviewLevel()
    if pre_lv == 1 then
        self:setTextByLanKey("cur_up_text",Language:getTextByKey("new_str_0355"))
    else
        self:setTextByLanKey("cur_up_text",Language:getTextByKey("new_str_0066").." "..pre_lv - 1) 
    end
    if pre_lv >= self.m_model.cur_eqpcfg.lv_limit then
        self:setTextByLanKey("next_up_text",Language:getTextByKey("new_str_0067"))
        self:setLvSlider(self.m_model:getShowCueExpNum(),self.m_model:getShowNextExpNum())
    else
        self:setLvSlider(self.m_model:getShowCueExpNum(),self.m_model:getShowNextExpNum())
        self:setTextByLanKey("next_up_text",Language:getTextByKey("new_str_0066").." "..self.m_model:getPreviewLevel())
    end
    for k,v in pairs(pro_tab) do
        ResourceUtil:ReturnItem(v)
    end
    pro_tab = {}
    local tit = nil
    local next_lv = 0
    if self.m_model:isFull() and self.m_model:getShowCueExpNum() >= self.m_model:getShowNextExpNum() then
        next_lv = self.m_model:getPreviewLevel()
        tit = GameUtil:createEqpLevelUp_Cell("new_str_0066",cur_eqp_data.lv, next_lv) --Title 强化等级
    elseif self.m_model:isFull() and self.m_model:getShowCueExpNum() < self.m_model:getShowNextExpNum() then
        next_lv = self.m_model:getPreviewLevel() - 1
        tit = GameUtil:createEqpLevelUp_Cell("new_str_0066",cur_eqp_data.lv, next_lv ) --Title 强化等级
    else    
        tit = GameUtil:createEqpLevelUp_Cell("new_str_0066",cur_eqp_data.lv) --Title 强化等级
    end
    tit.transform:SetParent(pro_parent.transform,false)
    table.insert(pro_tab, tit)
    local attrs = UserDataManager:appendAttrs(UserDataManager:getEquipAttrsByData(cur_eqp_data, cur_eqp_cfg))
    local atrs_tab = {}
    for k,v in pairs(attrs) do
        table.insert(atrs_tab, {name = k, num = v})
    end
    for i = 1, #atrs_tab do
        local atr_data = atrs_tab[i]
        if self.m_model:isFull() and cur_eqp_data.lv < next_lv then
            local pp = GameUtil:createEqpLevelUp_Cell(atr_data.name, atr_data.num, self:getGrowth(cur_eqp_data.id, atr_data.name, next_lv))
            pp.transform:SetParent(pro_parent.transform,false)
            table.insert(pro_tab, pp)
        else
            local pp = GameUtil:createEqpLevelUp_Cell(atr_data.name, atr_data.num)
            pp.transform:SetParent(pro_parent.transform,false)
            table.insert(pro_tab, pp)
        end
    end
    for k,v in pairs(pro_tab) do
        local pro_luaBehaviour = UIUtil.findLuaBehaviour(v)
        if pro_luaBehaviour then
            LuaBehaviourUtil.setObjectVisible(pro_luaBehaviour, "bg", k%2 ~= 0)
        end
    end
    for i = 1 , 5 do --设置星级
        self:setObjectVisible("star_"..i,false)
    end
    if cur_eqp_data.lv > 0 then
        for i = 1 , cur_eqp_data.lv do 
            self:setObjectVisible("star_"..i,true)
        end
    end
    local btn_img = self:findImage("replace_btn")
    if next(self.m_model.m_check_list) == nil then
        btn_img.material = self.gray_img.material
    else
        btn_img.material = nil
    end
end

function M:updateAttrLoopScroll()
    local cur_eqp_data, cur_eqp_cfg = self.m_model:getEqpData()
    local attrs = UserDataManager:appendAttrs(UserDataManager:getEquipAttrsByData(cur_eqp_data, cur_eqp_cfg))
    pro_tab = {}
    local next_lv = 0
    if self.m_model:isFull() and self.m_model:getShowCueExpNum() >= self.m_model:getShowNextExpNum() then
        next_lv = self.m_model:getPreviewLevel()
    elseif self.m_model:isFull() and self.m_model:getShowCueExpNum() < self.m_model:getShowNextExpNum() then
        next_lv = self.m_model:getPreviewLevel() - 1
    end
    table.insert(pro_tab, {name = "new_str_0066", c_num = cur_eqp_data.lv, next_num = next_lv} )
    for k,v in pairs(attrs) do
        table.insert(pro_tab, {name = k, c_num = v})
    end
    if cur_eqp_data.affix and next(cur_eqp_data.affix) ~= nil then
        for i = 1, table.nums(cur_eqp_data.affix)  do
            local cur_data = cur_eqp_data.affix[tostring(i)]
            local attr_value = cur_data.value[1] or {}
            if next(attr_value) ~= nil then
                local name = GameUtil:getAttrsKey(attr_value[2])
                if i == 1 then
                    table.insert(pro_tab, {name = name, c_num = attr_value[3], affix_id = cur_data.id , ts = 1})
                else
                    table.insert(pro_tab, {name = name, c_num = attr_value[3], affix_id = cur_data.id})
                end
            end
        end
    end
    local all_cell_size = {}
    for i = 1, #pro_tab do
        local attr_data = pro_tab[i]
        if attr_data.affix_id and attr_data.affix_id > 0 then
            local affix_cfg = self.m_model:getEquipAffixData(attr_data.affix_id)
            if affix_cfg.unique == 1 then
                all_cell_size[i] = Vector2(301.2, 60)
            else
                all_cell_size[i] = Vector2(301.2, 30) 
            end
        else
            all_cell_size[i] = Vector2(301.2, 30)
        end
    end
    if self.attr_loop_scroll == nil then
        local loopscroll = self:findGameObject("attr_loopscroll")
        local params = {
            show_data = pro_tab,
            all_cell_size = all_cell_size,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateCell(index, cell_object, cell_data)
            end
        }
        self.attr_loop_scroll = LoopScrollViewUtil.new(params)
    else
        self.attr_loop_scroll:reloadData(pro_tab)
    end
end

function M:updateCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    if luaBehaviour then
        local key = cell_data.name 
        local num = cell_data.c_num 
        local num2 = cell_data.next_num or 0 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num2", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_last", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_new", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unique_text", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg", index%2 ~= 0)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", false) 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_top_img", false)
        if cell_data.affix_id and cell_data.affix_id > 0 then
            local affix_cfg = self.m_model:getEquipAffixData(cell_data.affix_id)
            if affix_cfg.unique == 1 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title", false)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "unique_text", affix_cfg.affix_des)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unique_text", true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_top_img", true)
                return
            end
            if cell_data.ts and cell_data.ts == 1 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", true)
            end
        end

        if key == "new_str_0066" then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title", "new_str_0066")
            local last_obj = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_last", true)
            local new_obj = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_new", false)
            for i = 1,5 do
                UIUtil.setObjectVisible(last_obj.transform, num >= i, "star_"..i)
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num", "new_str_0075", num)
            if new_obj and num2 and num2 > 0 and num2 > num then
                for i = 1,5 do
                    UIUtil.setObjectVisible(new_obj.transform, num2 >= i, "star_"..i)
                end
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num2", "new_str_0075", num2)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_new", true)
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num2", false)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title", GameUtil:getAttrsName(key))
            if GameUtil:attrTransition(key) == true then
                LuaBehaviourUtil.setText(luaBehaviour, "num", GameUtil:formatNum(num) .. "%")
            else
                LuaBehaviourUtil.setText(luaBehaviour, "num", GameUtil:formatNum(num))
            end
            if num2 and num2 > 0 then
                if GameUtil:attrTransition(key) == true then
                    LuaBehaviourUtil.setText(luaBehaviour, "num2", GameUtil:formatNum(num2) .. "%")
                else
                    LuaBehaviourUtil.setText(luaBehaviour, "num2", GameUtil:formatNum(num2))
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num2", true)
            end
        end
    end
end


--[[
    @desc: ---获得强化时的属性 
    强化增加的属性 = 装备的基础属性*强化成长率*强化次数
    eqp_id:装备id  type:属性类型 level属性的等级
]]
function M:getGrowth(eqp_id, type, level)
    local cur_num, rate = GameUtil:getEqpBaseTypeNum(eqp_id,type)
    local newNum = 0
    newNum = cur_num * (rate/100) * level
    if GameUtil:canPerAttrTransition(type) == true then
        return GameUtil:formatNum((newNum + cur_num )*100) 
    end
    return newNum + cur_num 
end

--更新需要消耗的金币
function M:updateNeedMoney()
    local need_money = self.m_model:getNeedMoney()
    local data_money = RewardUtil:getProcessRewardData(tab_money)
    self:setImg(data_money.icon_name, data_money.atlas_name, "cond")
    if need_money > data_money.user_num then
        self:setTextByLanKey("cond_num_text", "equip_str_033", GameUtil:formatValueToString(data_money.user_num),GameUtil:formatValueToString(need_money))
    else
        self:setText("cond_num_text",GameUtil:formatValueToString(data_money.user_num).."/"..GameUtil:formatValueToString(need_money))
    end
end

--更新选中装备信息
function M:setEqpCell()
    for k,v in pairs(eqp_list) do
        local eqp_num = self.m_model:checkNumInList(v.data)
        local luaBehaviour = UIUtil.findLuaBehaviour(v.obj)
        local count_text_bg_img = luaBehaviour:FindGameObject("count_text_bg_img")
        local sub_btn = luaBehaviour:FindGameObject("sub_btn")
        sub_btn:SetActive(false)
        if eqp_num > 0 then
            local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", eqp_num.."/"..v.data.user_num)
            sub_btn:SetActive(true)
        else    
            local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", v.data.user_num)
            sub_btn:SetActive(false)
        end
        count_text_bg_img:SetActive(true)
    end
    self:updateNeedMoney()
    self:setCurEqp()
end

function M:setLvSlider(cur_num, max_num)
    local lv_slider = self:findSlider("lv_slider")
    local end_value = cur_num/max_num
    if end_value < 0.01 then
        end_value = 0.01
    end
    self.record_value = self.m_model:getEqpNum()
    lv_slider.value = end_value
    self:setText("exp_num",cur_num.."/"..max_num) 
end

function M:PlaySliderAnim(last_lv, last_num)
    local lv_slider = self:findSlider("lv_slider")
    local last_max = self.m_model:getShowCurExpNumByNum(last_lv)
    local last_value = last_num/last_max
    lv_slider.value = last_value
    local cur_num = self.m_model:getShowCueExpNum() --当前经验
    local max_num = self.m_model:getShowNextExpNum() -- 当前上线
    self.cur_value = cur_num/max_num
    if self.m_model.cur_eqpdata.lv > last_lv then
        if (self.m_model.cur_eqpdata.lv - last_lv) > 2 then
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(DOTweenModuleUI.DOValue(lv_slider, 1, 0.5))
            sequence:OnComplete(handler(self, self.sequenceDoValer))
            self.m_sequence = sequence
        else
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(DOTweenModuleUI.DOValue(lv_slider, 1, 0.5))
            sequence:OnComplete(handler(self, self.DoTweenCallBack))
            self.m_sequence = sequence    
        end
    else
        DOTweenModuleUI.DOValue(lv_slider, self.cur_value, 0.5)
    end
end

function M:sequenceDoValer()
    local lv_slider = self:findSlider("lv_slider")
    lv_slider.value = 0
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(DOTweenModuleUI.DOValue(lv_slider, 1, 0.5))
    sequence:OnComplete(function ()
        lv_slider.value = 0
        DOTweenModuleUI.DOValue(lv_slider, self.cur_value, 0.5)
    end)
end

function M:DoTweenCallBack()
    local lv_slider = self:findSlider("lv_slider")
    lv_slider.value = 0
    DOTweenModuleUI.DOValue(lv_slider, self.cur_value, 0.5)
end

function M:creatFx()
    local pro_parent = self:findGameObject("icon_effect")
    local eqp_fx = self:v_creat_effect_prafabe("HeroInfo/UI_EquipmentLevelUp_001", pro_parent)
end

function M:v_creat_effect_prafabe(p_name, parent)
    local eqp_lizi = ResourceUtil:GetUIEffectItem(p_name, parent)
    self:setParticleRenderOrder(eqp_lizi)
    self.m_control:setOnceTimer(2, function()
        ResourceUtil:ReturnItem(eqp_lizi)
	end)
end

function M:setSubOrderlayer(obj)
    local count = obj.transform.childCount
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
	if count > 0 then
		for i=count-1,0,-1 do
            local sub_obj = obj.transform:GetChild(i).gameObject
            if sub_obj.transform.childCount > 0 then
                self:setSubOrderlayer(sub_obj)
            end
            local ParticleSystem = LuaBehaviour:FindParticleSystem(sub_obj.name)
            if ParticleSystem then
                ParticleSystem:GetComponent("Renderer").sortingOrder = self.m_sortOrder + 1
            end
		end
	end
end

function M:destroy()
    if self.m_sequence then
        self.m_sequence:Kill()
        self.m_sequence = nil
    end
    M.super.destroy(self)
end

return M