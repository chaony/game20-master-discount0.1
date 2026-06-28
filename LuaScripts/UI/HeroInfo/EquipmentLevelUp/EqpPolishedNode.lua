--- 洗练
local M = class("EqpPolishedNode",LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/EqpPolishedNode"
local pro_tab = {}
function M:onEnter()
    self.m_is_show_jinglian_btn = false
    self:refreshUI()    
    self:setBtns(true)
    self:setTextByLanKey("polished_text", "equip_str_020")
    self:setTextByLanKey("skip_anim_select_text", "piliang_xl_text")
    self:setTextByLanKey("polished_text2", "equip_str_043")
end

function M:refreshUI()
    self:updateLoopScroll()
    self:updateCons()
    self:setObjectVisible("all_polished_open_img", self.m_model.m_batch_polished == true)
    self:setObjectVisible("all_polished_close_img", self.m_model.m_batch_polished == false)
    self:setCurEqp()
end

--更新装备信息
function M:setCurEqp()
    local cur_eqp_data, cur_eqp_cfg = self.m_model:getEqpData()
	self.m_icon_node = self:findGameObject("icon_node")
    if cur_eqp_cfg then
        self.m_is_show_jinglian_btn = cur_eqp_cfg.pos == 1
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
    local color = GlobalConfig.QUALITY_COMMON_SETTING[cur_eqp_cfg.quality]
    self:setTextColor("equip_text",color.RGBA)
    local pro_parent = self:findGameObject("pro_parent")
    for k,v in pairs(pro_tab) do
        ResourceUtil:ReturnItem(v)
    end
    pro_tab = {}
    local new_eqp_data = table.copy(cur_eqp_data)
    local attrs = UserDataManager:appendAttrs(UserDataManager:getEquipAttrsByData(new_eqp_data, cur_eqp_cfg))
    local atrs_tab = {}
    for k,v in pairs(attrs) do
        table.insert(atrs_tab, {name = k, num = v})
    end
    for i = 1, #atrs_tab do
        local atr_data = atrs_tab[i]
        local pp = GameUtil:createEqpLevelUp_Cell(atr_data.name, atr_data.num)
        pp.transform:SetParent(pro_parent.transform,false)
        table.insert(pro_tab, pp)
    end
    for k,v in pairs(pro_tab) do
        local pro_luaBehaviour = UIUtil.findLuaBehaviour(v)
        if pro_luaBehaviour then
            LuaBehaviourUtil.setObjectVisible(pro_luaBehaviour, "bg", k%2 ~= 0)
        end
    end
    local affix_combat = math.ceil(UserDataManager:getEquipAffixCombat(cur_eqp_data))
    if affix_combat > 0 then
        self:setTextByLanKey("affix_combat", "equip_str_026", affix_combat)
        self:setObjectVisible("affix_combat", true)
    else
        self:setObjectVisible("affix_combat", false)    
    end
end

--[[	
	属性列表
]]
function M:updateLoopScroll()
    local data, unique_data = self.m_model:getPolishedAttrs()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if click_name == "lock_btn" then
                    self:updateMsg("lock_attr", cell_data)
                end
			end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
    if unique_data then
        self:setObjectVisible("core_attr_text", true)
        local str = Language:getTextByKey(unique_data.cfg.affix_des)
        self:setTextByLanKey("core_attr_text", str)
    else
        self:setObjectVisible("core_attr_text", false)    
    end
end

function M:updateCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    if luaBehaviour then
        local affix_data = cell_data.data
        local affix_cfg = cell_data.cfg
        if affix_data then
            local attr = affix_data.value[1]
            if next(attr) ~= nil then
                local atk_key = GameUtil:getAttrsKey(attr[2])
                local atk_name = GameUtil:getAttrsName(atk_key)
                local scope_attr = ""
                local cur_attr = ""
                if GameUtil:attrTransition(atk_key) == true then
                    if GameUtil:canPerAttrTransition(atk_key) == true then
                        scope_attr = GameUtil:formatNum(affix_cfg[1]*100).."%~"..GameUtil:formatNum(affix_cfg[2]*100).."%"
                        cur_attr = GameUtil:formatNum(attr[3]*100).."%" 
                    else
                        scope_attr = affix_cfg[1].."%~"..affix_cfg[2].."%"
                        cur_attr = attr[3].."%"    
                    end
                else
                    if GameUtil:canPerAttrTransition(atk_key) == true then
                        scope_attr = GameUtil:formatNum(affix_cfg[1]*100).."~".. GameUtil:formatNum(affix_cfg[2]*100)
                        cur_attr = GameUtil:formatNum(attr[3]*100)
                    else
                        scope_attr = affix_cfg[1].."~"..affix_cfg[2]
                        cur_attr = attr[3]
                    end
                end
                local cell_title = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", atk_name)
                local scope_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "scope_text", " [".. scope_attr.."]" )
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "orig_num", cur_attr)
                local atr_quality = GameUtil:checkAttrsQuality(affix_data.id)
                cell_title.color = atr_quality
                scope_text.color = atr_quality
            end
            if cell_data.data.lock == 1 then
                local lock_img = LuaBehaviourUtil.setImg(luaBehaviour, "lock_btn", "a_zbxl_jinsuo", "mystic_ui")
            else
                local lock_img = LuaBehaviourUtil.setImg(luaBehaviour, "lock_btn", "a_zbxl_suo_open", "active_ui")
            end
        end
    end
end

function M:setBtns(bl)
    if bl == true then
        self:setObjectVisible("polished_btn", true)
        self:setObjectVisible("cons_parent", true)
        self:setObjectVisible("save_btn", false)
        self:setObjectVisible("waive_btn", false)
        self:setObjectVisible("save_tips_text", true)
    else
        self:setObjectVisible("save_btn", true)
        self:setObjectVisible("waive_btn", true)
        self:setObjectVisible("save_tips_text", true)
        self:setObjectVisible("polished_btn", false)
        self:setObjectVisible("cons_parent", false)
    end
end

function M:updateCons()
    for i = 1, 2 do
        local extra_ui_name = i == 2 and "2" or ""
        local consItem = self.m_model:polishCons(i == 2) 
        self:setImg(consItem.icon_name, consItem.atlas_name, "money_iocn" .. extra_ui_name)
        if consItem.user_num < consItem.data_num then
            self:setTextByLanKey("cons_num_text" .. extra_ui_name, "equip_str_033" ,tostring(consItem.user_num), tostring(consItem.data_num))
        else
            self:setTextByLanKey("cons_num_text" .. extra_ui_name, tostring(consItem.user_num).."/"..tostring(consItem.data_num))
        end
        local polished_btn = self:findImage("polished_btn" .. extra_ui_name)
        local polished_text = self:findText("polished_text" .. extra_ui_name)
        local flag = false
        if i == 1 then
            flag = self.m_model:checkCanLock() == false
        end
        if consItem.data_num > consItem.user_num or self.m_model:checkCanPoloshed() == false or flag then
            polished_btn.color = Color.New(0.5,0.5,0.5)
            polished_text.color = Color( 143/255, 147/255, 156/255)
        else
            polished_btn.color = GlobalConfig.COMMON_COLLOR.COMMON_1
            polished_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
        end
    end
    self:setTextByLanKey("save_tips_text", "equip_str_042")
end

function M:onButtonClick(obj, name)
    if name == "money_iocn" or name == "money_iocn2" then
        local data_reward = self.m_model:polishCons(name == "money_iocn2")
        self:openView("Item.ItemDetail", {show_data = data_reward, display = true}, nil, true)
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M