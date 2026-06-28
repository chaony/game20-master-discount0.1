local M = class("EquipAwakenView",LikeOO.OOPopBase)

M.m_uiName = "EquipAwaken/EquipAwaken"
M.m_iphoneXAdapter = true
--装备觉醒
M.TAG_TAB = {
    {pos = 0, img = "a_zbjx_quanbu"}, --全部 /
    {pos = 1, img = "a_zbjx_wuqi"}, --武器
    {pos = 2, img = "a_zbjx_maozi"}, --头
    {pos = 3, img = "a_zbjx_yifu"}, --身体
    {pos = 4, img = "a_zbjx_xiezi"}, --脚
    {pos = 5, img = "a_zbjx_kuzi"}, --裤子
}


function M:onEnter()
    self.right_img = self:findGameObject("right_img")
    self.m_local_x = self.right_img.transform.localPosition.x or 268
    self:showTips(false)
    self.main_anim = self.m_ui_obj:GetComponent("Animator")
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 23})
    self.m_gray_image = self:findImage("gray_img")
    self:setTextByLanKey("close_title_text", "art_str_004")
    self:setTextByLanKey("awaken_btn_text", "equip_str_022")
    self:refreshUI()
    if self.main_anim then
        self.main_anim:CrossFade("EquipAwaken_enter",1)
    end
    self:setTextByLanKey("tips_des_text", "equip_str_039")
    self:setTextByLanKey("tips_title_text", "equip_str_040")
    self:setTextByLanKey("art_text", "equipAwaken_art_text")
    self:setTextByLanKey("left_title_text", "equipAwaken_left_title_text")
end

function M:refreshUI()
    self:setObjectVisible("left_obj", true)
    self:setObjectVisible("awaken_btn", true)
    self:setObjectVisible("art_btn", true)
    self:setObjectVisible("tips_btn", true)
    self:setObjectVisible("UI_EquipAwaken_BF001", false)
    self:setObjectVisible("UI_EquipAwaken_JQ002", false)
    self:setObjectVisible("UI_EquipAwaken_JQ001", false)
    self:updateTagLoopScroll()
    self:updateLoopScroll()
    self:refreshRightConstItems()
    self:refreshRedPoint()
    --快速导航
    self:setObjectVisible("guide_btn", true)
    UIUtil.setLocalPosition(self.right_img.transform, self.m_local_x)
    self:RefreshThronesPhase()
end

function M:refreshRedPoint()
    local red_flag = RedPointUtil:isFuncRedPointById(258)
    self:setObjectVisible("art_btn_red_point", red_flag == true)
end


function M:switchPos()
    self:updateTagLoopScroll()
    self:updateLoopScroll()
    self:refreshRightConstItems()
end


function M:updateTagLoopScroll()
    local data = self.TAG_TAB
    if self.tag_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("equip_tag_scroll")
        local params = {
            show_data = data,
            ui_name = self.m_uiName,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateTagCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				self:updateMsg("tag_btn", cell_data.pos)
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
        if self.m_model.tag_index == cell_data.pos then
            LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", cell_data.img.."_xuanzhong", "coach_ui")
        else
            LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", cell_data.img.."_weixuan", "coach_ui")   
        end
    end
end

function M:updateLoopScroll()
    local data = self.m_model.m_equips
    if self.m_model.tag_index and self.m_model.tag_index > 0 then
        data = self.m_model:getFilterEquips() 
    end
    if next(data) == nil then
        self:setObjectVisible("CommonTipsNode", true)
    else
        self:setObjectVisible("CommonTipsNode", false)    
    end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("equip_scroll")
        local params = {
            show_data = data,
            one_line_count = 4, -- 行或列的数量
            pos_center = true,
            loop_scroll_object = loopscroll,
            ui_name = self.m_uiName,
            update_cell = function(index, cell_object, cell_data)
                self:updateCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
			
			end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

function M:updateCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    if luaBehaviour then
        local itemObj = luaBehaviour:FindGameObject("ItemNode")
        local equip_data = cell_data.equ_data
        local equip_cfg = cell_data.equ_cfg
        local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.EQUIPS,equip_data.id,equip_data.race,cell_data.equ_id})
        GameUtil:updateItemElementByData(itemObj, data, true, false, function ()
            self:updateMsg("select_eqp", index)
        end,false,false,nil,false,false)
        if cell_data.hero_id then
            GameUtil:updateItemEquipInfo(itemObj, equip_data, nil, cell_data.hero_id)
        end
        if index == self.m_model.select_index then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", false)   
        end
    end
end

function M:refreshRightConstItems()
    local prent_cur_eqp = self:findGameObject("prent_item_4")
    UIUtil.destroyAllChild(prent_cur_eqp.transform)
    local cur_equip_data = self.m_model:getCurEquip()
    if cur_equip_data then
        for i = 1,4 do
            self:setObjectVisible("prent_item_"..i, true)  
        end
        local equip_data = cur_equip_data.equ_data
        local equip_cfg = cur_equip_data.equ_cfg
        local cur_obj =
        GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS,equip_data.id,1,equip_data.oid},false, false, function ()
            if cur_equip_data.hero_id then
                static_rootControl:openView("HeroInfo.EquipmentPop", {equip_id = equip_data.oid, heroid = cur_equip_data.hero_id, pos = cur_equip_data.pos, hide_btns = false})
            else
                static_rootControl:openView("HeroInfo.EquipmentPop", {equip_id = equip_data.oid, hide_btns = false}) 
            end
        end)
        GameUtil:updateItemEquipInfo(cur_obj, equip_data, equip_cfg)
        cur_obj.transform:SetParent(prent_cur_eqp.transform, false)
        self:updateConsts(equip_cfg.awake_cost)
        self:setTextByLanKey("cur_equip_text", equip_cfg.name)
        self:setObjectVisible("cur_equip_text", true)
    else
        for i = 1,4 do
            self:setObjectVisible("prent_item_"..i, true)  
        end
        self:setObjectVisible("cur_equip_text", false)
        self:updateConsts()
    end
    local awaken_img = self:findImage("awaken_btn")
    if self.m_model:canAwakenIng() == true then
        awaken_img.color = Color(1,1,1)
    else
        awaken_img.color = Color(0.5,0.5,0.5)   
    end
end

function M:updateConsts()
    local cur_equip_data = self.m_model:getCurEquip()
    if not cur_equip_data then return end
    local equip_data = cur_equip_data.equ_data
    local equip_cfg = cur_equip_data.equ_cfg
    local data = ConfigManager:getCommonValueById(535)
    if equip_cfg.pos ~= 1 then
        data = ConfigManager:getCommonValueById(536)
    end
    if data and next(data) ~= nil then
        for k,v in pairs(data) do
            local prent_item = self:findGameObject("prent_item_"..k)
            UIUtil.destroyAllChild(prent_item.transform)
            local item = GameUtil:createItemElement(v, true, true)
            item.transform:SetParent(prent_item.transform)
            item.transform.localPosition = Vector3.New(0,0,0)
            local Item_LuaBehaviour = UIUtil.findLuaBehaviour(item)
            if Item_LuaBehaviour then
                local itemData = RewardUtil:getProcessRewardData(v)
                local count_text = Item_LuaBehaviour:FindText("count_text")
                local item_img = Item_LuaBehaviour:FindImage("item_img")
                local quality_img = Item_LuaBehaviour:FindImage("quality_img")
                if itemData.user_num >= itemData.data_num then
                    count_text.color = Color.New(1,1,1)
                    item_img.material = nil
                    quality_img.material = nil
                else
                    count_text.color = Color.New(1,0,0)    
                    item_img.material = self.m_gray_image.material
                    quality_img.material = self.m_gray_image.material
                end
            end
        end
    end
end

--播放觉醒动效
function M:playAwakenAnim(callback)
    self:lockTouch()
    self:setObjectVisible("left_obj", false)
    self:setObjectVisible("awaken_btn", false)
    self:setObjectVisible("art_btn", false)
    self:setObjectVisible("tips_btn", false)
    self:setObjectVisible("thrones_phase_btn", false)
    if self.main_anim then
        self.main_anim:CrossFade("EquipAwaken_compound",1)
        self.m_local_x = self.right_img.transform.localPosition.x or 268
        self.right_img.transform:DOLocalMoveX(0, 0.5)
    end
    self.m_control:setOnceTimer(0.2, function ()
        self:setObjectVisible("UI_EquipAwaken_JQ002", true)
        self:setObjectVisible("UI_EquipAwaken_JQ001", true)
    end)
    self.m_control:setOnceTimer(4.9, function ()
        self:setObjectVisible("UI_EquipAwaken_BF001", true)
    end)
    self.m_control:setOnceTimer(4.95, function ()
        if callback then
            callback()
        end
        self:unlockTouch()
    end)
end

function M:playExit()
    if self.main_anim then
        self.main_anim:CrossFade("EquipAwaken_exit",0.15)
        self.right_img.transform:DOLocalMoveX(self.m_local_x, 0.1)
    end
end

function M:showTips(bl)
    self:setObjectVisible("tips_node", bl)
    self:setObjectVisible("tips_close_btn", bl)
end

function M:RefreshThronesPhase()
    local thronePhase = self.m_model:getThronesPhase()
    local thronePhaseData = self.m_model:getCurThronesPhaseData()

    if next(thronePhase) then
        local curPhase = thronePhaseData[thronePhase.lv]
        local nextPhase = thronePhaseData[thronePhase.lv + 1]
        self:setObjectVisible("thrones_phase_btn", true)
        local exp = thronePhase.exp
        local nextExp = nextPhase ~= nil and  nextPhase.exp or exp
        local slider = self:findSlider("thrones_phase_bar")
        slider.value = exp / nextExp
        self:setText("thrones_phase_value", exp.."/"..nextExp)
        self:setTextByLanKey("thrones_phase_text", curPhase.name)
        self:setImg(curPhase.icon, "item_icon","thrones_phase_Ico")
    else
        self:setObjectVisible("thrones_phase_btn", false)
    end
end

function M:showThronesTips(bl)
    self:setObjectVisible("thrones_info", bl == true)
    if bl then
        local addAttr = ConfigManager:getCommonValueById(837,{500,300})
        local thronePhase = self.m_model:getThronesPhase()
        local lv = thronePhase ~= nil and thronePhase.lv or 0
        local thronePhaseData = self.m_model:getCurThronesPhaseData()
        self:setTextByLanKey("thrones_title","equip_throne_tittle")
        self:setTextByLanKey("thrones_tip_text_1","equip_throne_add_weapon", addAttr[1])
        self:setTextByLanKey("thrones_tip_text_2","equip_throne_add_equip", addAttr[2])
        local nameStr = "<color=#FFFFFF>"
        local descStr = "<color=#FFFFFF>"
        local gray = false
        local index = #thronePhaseData
        for l, v in pairs(thronePhaseData) do
            if l > lv and not gray then
                index = l - 1
                gray = true
                nameStr = nameStr .. "</color><color=#AAAAAA>"
                descStr = descStr .. "</color><color=#AAAAAA>"
            end
            nameStr = nameStr .. v.name .. "\n"
            descStr = descStr .. v.effect_tips .. "\n"
        end
        nameStr = nameStr .. "</color>"
        descStr = descStr .. "</color>"
        local nameText = self:setText("thrones_info_name_text", nameStr)
        self:setText("thrones_info_desc_text", descStr)
        nameText:GetComponent('ContentSizeFitter'):SetLayoutVertical();
        local nameText_rect = nameText.transform:GetComponent('RectTransform')
        local size_value = nameText_rect.sizeDelta;
        local pos = nameText_rect.transform.localPosition;
        pos.y = size_value.y * index / #thronePhaseData
        nameText_rect.transform.localPosition = pos
    end
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end

return M